part of angular.routing;

/**
 * A directive that works with the [Router] and loads the template associated
 * with the current route.
 *
 *     <ng-view></ng-view>
 *
 * [NgViewDirective] can work with [NgViewDirective] to define nested views
 * for hierarchical routes. For example:
 *
 *     void initRoutes(Router router, RouteViewFactory views) {
 *       views.configure({
 *          'library': ngRoute(
 *              path: '/library',
 *              view: 'library.html',
 *              mount: {
 *                  'all': ngRoute(
 *                      path: '/all',
 *                      view: 'book_list.html'),
 *                   'book': ngRoute(
 *                      path: '/:bookId',
 *                      mount: {
 *                          'overview': ngRoute(
 *                              path: '/overview',
 *                              defaultRoute: true,
 *                              view: 'book_overview.html'),
 *                          'read': ngRoute(
 *                              path: '/read',
 *                              view: 'book_read.html'),
 *                      })
 *              })
 *       });
 *
 * index.html:
 *
 *     <ng-view></ng-view>
 *
 * library.html:
 *
 *     <div>
 *       <h1>Library!</h1>
 *
 *       <ng-view></ng-view>
 *     </div>
 *
 * book_list.html:
 *
 *     <ul>
 *       <li><a href="/library/12345/overview">Book 12345</a>
 *       <li><a href="/library/23456/overview">Book 23456</a>
 *     </ul>
 */
@Decorator(
    selector: 'ng-view',
    module: NgView.module,
    visibility: Visibility.CHILDREN)
class NgView implements DetachAware, RouteProvider {
  static void module(DirectiveBinder binder) =>
      binder.bind(RouteProvider, toInstanceOf: NG_VIEW_KEY, visibility: Visibility.CHILDREN);

  final NgRoutingHelper _locationService;
  final ViewCache _viewCache;
  final Injector _appInjector;
  final DirectiveInjector _dirInjector;
  final Element _element;
  final Scope _scope;
  RouteHandle _parentRoute;

  View _view;
  Scope _childScope;
  Route _viewRoute;

  NgView(this._element, this._viewCache, this._dirInjector, this._appInjector,
         Router router, this._scope, this._locationService)
  {
    RouteProvider routeProvider = _dirInjector.getFromParentByKey(NG_VIEW_KEY);
    // Get the parent route
    // - from the parent `NgView` when it exists,
    // - from the router root otherwise.
    _parentRoute = routeProvider != null ?
        routeProvider.route.newHandle() :
        router.root.newHandle();
    _locationService._registerPortal(this);
    _maybeReloadViews();
  }

  /// Reload the child views when the `_parentRoute` is active
  void _maybeReloadViews() {
    if (_parentRoute.isActive) _locationService._reloadViews(startingFrom: _parentRoute);
  }

  void detach() {
    _parentRoute.discard();
    _locationService._unregisterPortal(this);
    _cleanUp();
  }

  void _show(_View viewDef, Route route) {
    assert(route.isActive);

    if (_viewRoute != null) return;
    _viewRoute = route;

    StreamSubscription _leaveSubscription;
    _leaveSubscription = route.onLeave.listen((_) {
      _leaveSubscription.cancel();
      _leaveSubscription = null;
      _viewRoute = null;
      _cleanUp();
    });

    Injector viewInjector = _appInjector;

    List<Module> modules = viewDef.modules;
    if (modules != null) viewInjector = createChildInjectorWithReload(_appInjector, modules);

    var newDirectives = viewInjector.getByKey(DIRECTIVE_MAP_KEY);

    var viewFuture = viewDef.templateHtml != null ?
        new Future.value(_viewCache.fromHtml(viewDef.templateHtml, newDirectives)) :
        _viewCache.fromUrl(viewDef.template, newDirectives, Uri.base);

    viewFuture.then((ViewFactory viewFactory) {
      _cleanUp();
      _childScope = _scope.createProtoChild();
      _view = viewFactory(_childScope, _dirInjector);
      _view.nodes.forEach((elm) => _element.append(elm));
    });
  }

  void _cleanUp() {
    if (_view == null) return;

    _view.nodes.forEach((node) => node.remove());
    _childScope.destroy();
    _view = null;
    _childScope = null;
  }

  /// implements `RouteProvider.route`
  Route get route => _viewRoute;

  /// implements `RouteProvider.routeName`
  String get routeName => _viewRoute.name;

  /// implements `RouteProvider.parameters`
  Map<String, String> get parameters {
    var res = new HashMap<String, String>();
    var p = _viewRoute;
    for (Route p = _viewRoute; p != null; p = p.parent) {
      res.addAll(p.parameters);
    }
    return res;
  }

  /**
   * Creates a child injector that allows loading new directives, formatters and
   * services from the provided modules.
   */
  static Injector createChildInjectorWithReload(Injector injector, List<Module> modules) {
    var modulesToAdd = new List<Module>.from(modules);
    modulesToAdd.add(new Module()
        ..bind(DirectiveMap)
        ..bind(FormatterMap));

    return new ModuleInjector(modulesToAdd, injector);
  }
}


/**
 * Class that can be injected to retrieve information about the current route.
 * For example:
 *
 *     @Component(/* ... */)
 *     class MyComponent implement DetachAware {
 *       RouteHandle route;
 *
 *       MyComponent(RouteProvider routeProvider) {
 *         _loadFoo(routeProvider.parameters['fooId']);
 *         route = routeProvider.route.newHandle();
 *         route.onEnter.listen((RouteEvent e) {
 *           // Do something when the route is activated.
 *         });
 *         route.onPreLeave.listen((RouteEvent e) {
 *           // Do something when the route is de-activated.
 *           e.allowLeave(allDataSaved());
 *         });
 *       }
 *
 *       detach() {
 *         // The route handle must be discarded.
 *         route.discard();
 *       }
 *
 *       Future<bool> allDataSaved() {
 *         // Check that all data is saved and confirm with the user if needed.
 *       }
 *     }
 *
 * If user component is used outside of `ng-view` directive then
 * injected [RouteProvider] will be null.
 */
abstract class RouteProvider {

  /**
   * Returns [Route] for current view.
   */
  Route get route;

  /**
   * Returns the name of the current route.
   */
  String get routeName;

  /**
   * Returns parameters for this route.
   */
  Map<String, String> get parameters;
}
