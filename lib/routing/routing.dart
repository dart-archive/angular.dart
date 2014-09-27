part of angular.routing;

/**
 * A factory of route to template bindings.
 */
class RouteViewFactory {
  NgRoutingHelper locationService;

  RouteViewFactory(this.locationService);

  Function call(String templateUrl) =>
      (RouteEnterEvent event) => _enterHandler(event, templateUrl);

  void _enterHandler(RouteEnterEvent event, String templateUrl,
                     {List<Module> modules, String templateHtml}) {
    locationService._route(event.route, templateUrl, templateHtml, modules);
  }

  void configure(Map<String, NgRouteCfg> config) {
    _configure(locationService.router.root, config);
  }

  void _configure(Route route, Map<String, NgRouteCfg> config) {
    config.forEach((name, cfg) {
      var modulesCalled = false;
      List<Module> newModules;
      route.addRoute(
          name: name,
          path: cfg.path,
          defaultRoute: cfg.defaultRoute,
          dontLeaveOnParamChanges: cfg.dontLeaveOnParamChanges,
          enter: (RouteEnterEvent e) {
            if (cfg.view != null || cfg.viewHtml != null) {
              _enterHandler(e, cfg.view, modules: newModules, templateHtml: cfg.viewHtml);
            }
            if (cfg.enter != null) {
              cfg.enter(e);
            }
          },
          preEnter: (RoutePreEnterEvent e) {
            if (cfg.modules != null && !modulesCalled) {
              modulesCalled = true;
              var modules = cfg.modules();
              if (modules is Future) {
                e.allowEnter(modules.then((List<Module> m) {
                  newModules = m;
                  return true;
                }));
              } else {
                newModules = modules;
              }
            }
            if (cfg.preEnter != null) {
              cfg.preEnter(e);
            }
          },
          preLeave: cfg.preLeave,
          leave: cfg.leave,
          mount: (Route mountRoute) {
            if (cfg.mount != null) {
              _configure(mountRoute, cfg.mount);
            }
          });
    });
  }
}

/**
 * Helper function to create a route configuration (`NgRouteCfg`):
 * - `path`: url section (`/path`),
 * - `view`: external template,
 * - `viewHtml`: inline template,
 * - `mount`: child routes,
 * - `defaultRoute`: set to `true` for the default route,
 * - `*EventHandler`: event handlers, see route.dart for details,
 * - `dontLeaveOnParamChanges`: do not leave the route when only parameters change
 */
NgRouteCfg ngRoute({String path,
                    String view,
                    String viewHtml,
                    Map<String, NgRouteCfg> mount,
                    modules(),
                    bool defaultRoute: false,
                    RoutePreEnterEventHandler preEnter,
                    RouteEnterEventHandler enter,
                    RoutePreLeaveEventHandler preLeave,
                    RouteLeaveEventHandler leave,
                    dontLeaveOnParamChanges: false}) {
  return new NgRouteCfg(path: path, view: view, viewHtml: viewHtml, mount: mount, modules: modules,
      defaultRoute: defaultRoute, preEnter: preEnter, preLeave: preLeave, enter: enter,
      leave: leave, dontLeaveOnParamChanges: dontLeaveOnParamChanges);
}

class NgRouteCfg {
  final String path;
  final String view;
  final String viewHtml;
  final Map<String, NgRouteCfg> mount;
  final Function modules;
  final bool defaultRoute;
  final bool dontLeaveOnParamChanges;
  final RouteEnterEventHandler enter;
  final RoutePreEnterEventHandler preEnter;
  final RoutePreLeaveEventHandler preLeave;
  final RouteLeaveEventHandler leave;

  NgRouteCfg({this.view, this.viewHtml, this.path, this.mount, this.modules, this.defaultRoute,
       this.enter, this.preEnter, this.preLeave, this.leave, this.dontLeaveOnParamChanges});
}

/**
 * An interface that must be implemented by the user of routing library and
 * should include the route initialization.
 *
 * The [init] method will be called by the framework once the router is
 * instantiated but before [NgBindRouteDirective] and [NgViewDirective].
 */
@Deprecated("use RouteInitializerFn instead")
abstract class RouteInitializer {
  void init(Router router, RouteViewFactory viewFactory);
}

/**
 * An typedef that must be implemented by the user of routing library and
 * should include the route initialization.
 *
 * The function will be called by the framework once the router is
 * instantiated but before [NgBindRouteDirective] and [NgViewDirective].
 */
typedef void RouteInitializerFn(Router router, RouteViewFactory viewFactory);

/**
 * A singleton helper service that handles routing initialization, global
 * events and view registries.
 */
@Injectable()
class NgRoutingHelper {
  final Router router;
  final _portals = <NgView>[];
  final _templates = <String, _View>{};

  NgRoutingHelper(RouteInitializer initializer, Injector injector, this.router,
                  Application ngApp) {
    // TODO: move this to constructor parameters when di issue is fixed:
    // https://github.com/angular/di.dart/issues/40
    RouteInitializerFn initializerFn = injector.getByKey(ROUTE_INITIALIZER_FN_KEY);
    if (initializer == null && initializerFn == null) {
      window.console.error('No RouteInitializer implementation provided.');
      return;
    };

    if (initializerFn != null) {
      initializerFn(router, new RouteViewFactory(this));
    } else {
      initializer.init(router, new RouteViewFactory(this));
    }

    // Check if we need to update `ng-view`s when a new route is activated
    router.onRouteStart.listen((RouteStartEvent routeEvent) {
      routeEvent.completed.then((success) {
        if (success) {
          _portals.forEach((NgView p) => p._maybeReloadViews());
        }
      });
    });

    // Make the router listen to URL change events and click events
    router.listen(appRoot: ngApp.element);
  }

  void _reloadViews({Route startingFrom}) {
    var activeViews = <NgView>[];
    Iterable<Route> activePath = router.activePath;
    if (startingFrom != null) {
      // only consider child routes of the `startingFrom` route
      activePath = activePath.skip(_routeDepth(startingFrom));
    }

    for (Route route in activePath) {
      var path = _routePath(route);
      var viewDef = _templates[path];
      if (viewDef == null) continue;

      NgView view = _portals.firstWhere(
          (NgView v) => path != _routePath(v._parentRoute) &&
                        path.startsWith(_routePath(v._parentRoute)),
          orElse: () => null);

      if (view != null && !activeViews.contains(view)) {
        view._show(viewDef, route);
        activeViews.add(view);
        break;
      }
    }
  }

  void _route(Route route, String template, String templateHtml, List<Module> modules) {
    _templates[_routePath(route)] = new _View(template, templateHtml, modules);
  }

  void _registerPortal(NgView ngView) {
    _portals.insert(0, ngView);
  }

  void _unregisterPortal(NgView ngView) {
    _portals.remove(ngView);
  }
}

class _View {
  final String template;
  final String templateHtml;
  final List<Module> modules;

  _View(this.template, this.templateHtml, this.modules);
}

/// Returns the route full path (ie `grand-parent.parent.current`)
String _routePath(Route route) {
  final path = <String>[];
  for (Route p = route; p.parent != null; p = p.parent) {
    path.insert(0, p.name);
  }
  return path.join('.');
}

/// Returns the route depth (ie 3 for `grand-parent.parent.current`)
int _routeDepth(Route route) {
  var depth = 0;
  for (Route p = route; p.parent != null; p = p.parent) {
    depth++;
  }
  return depth;
}
