part of angular.routing;

/**
 * A factory of route to template bindings.
 */
class ViewFactory {
  NgRoutingHelper locationService;

  ViewFactory(this.locationService);

  call(String templateUrl) =>
      (RouteEvent event) =>
          locationService._route(event.route, templateUrl, fromEvent: true);
}

/**
 * An interface that must be implemented by the user of routing library and
 * should include the route initialization.
 *
 * The [init] method will be called by the framework once the router is
 * instantiated but before [NgBindRouteDirective] and [NgViewDirective].
 */
abstract class RouteInitializer {
  void init(Router router, ViewFactory viewFactory);
}

/**
 * A singleton helper service that handles routing initialization, global
 * events and view registries.
 */
@NgInjectableService()
class NgRoutingHelper {
  final Router router;
  final NgApp _ngApp;
  List<NgViewDirective> portals = <NgViewDirective>[];
  Map<String, String> _templates = new Map<String, String>();

  NgRoutingHelper(RouteInitializer initializer, this.router, this._ngApp) {
    if (initializer == null) {
      window.console.error('No RouteInitializer implementation provided.');
      return;
    };

    initializer.init(router, new ViewFactory(this));
    router.onRouteStart.listen((RouteStartEvent routeEvent) {
      routeEvent.completed.then((success) {
        if (success) {
          portals.forEach((NgViewDirective p) => p._maybeReloadViews());
        }
      });
    });

    router.listen(appRoot: _ngApp.root);
  }

  _reloadViews({Route startingFrom}) {
    var alreadyActiveViews = [];
    var activePath = router.activePath;
    if (startingFrom != null) {
      activePath = activePath.skip(_routeDepth(startingFrom));
    }
    for (Route route in activePath) {
      var templateUrl = _templates[_routePath(route)];
      if (templateUrl == null) continue;

      NgViewDirective view = portals.lastWhere((NgViewDirective v) {
        return _routePath(route) != _routePath(v._route) &&
            _routePath(route).startsWith(_routePath(v._route));
      }, orElse: () => null);
      if (view != null && !alreadyActiveViews.contains(view)) {
        view._show(templateUrl, route);
        alreadyActiveViews.add(view);
        break;
      }
    }
  }

  _route(Route route, String template, {bool fromEvent}) {
    _templates[_routePath(route)] = template;
  }

  _registerPortal(NgViewDirective ngView) {
    portals.add(ngView);
  }

  _unregisterPortal(NgViewDirective ngView) {
    portals.remove(ngView);
  }
}

String _routePath(Route route) {
  var path = [];
  var p = route;
  while (p.parent != null) {
    path.insert(0, p.name);
    p = p.parent;
  }
  return path.join('.');
}

int _routeDepth(Route route) {
  var depth = 0;
  var p = route;
  while (p.parent != null) {
    depth++;
    p = p.parent;
  }
  return depth;
}
