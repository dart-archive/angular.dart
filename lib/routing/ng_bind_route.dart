part of angular.routing;

/**
 * A directive that allows to bind child components/directives to a specific
 * route.
 *
 *     <div ng-bind-route="foo.bar">
 *       <my-component></my-component>
 *     </div>
 *
 * ng-bind-route directives can be nested.
 *
 *     <div ng-bind-route="foo">
 *       <div ng-bind-route=".bar">
 *         <my-component></my-component>
 *       </div>
 *     </div>
 *
 * The '.' prefix indicates that bar route is relative to the route in the
 * parent ng-bind-route directive.
 */
@NgDirective(
    visibility: NgDirective.CHILDREN_VISIBILITY,
    publishTypes: const [RouteProvider],
    selector: '[ng-bind-route]',
    map: const {
        'ng-bind-route': '@routeName'
    }
)
class NgBindRouteDirective implements RouteProvider {
  Router _router;
  String routeName;
  Injector _injector;

  NgBindRouteDirective(Router this._router, Injector this._injector);

  /// Returns the parent [RouteProvider].
  RouteProvider get _parent => _injector.parent.get(RouteProvider);

  Route get route => _router.root.getRoute(routePath);

  String get routePath {
    if (!routeName.startsWith('.')) {
      return routeName;
    }
    String parentPath;
    if (_parent == null) {
      parentPath = '';
    } else {
      parentPath = _parent.routePath + '.';
    }
    return parentPath + routeName.substring(1);
  }
}

/**
 * Class that can be injected to retrieve information about the current route.
 * For example:
 *
 *     @NgComponent(/* ... */)
 *     class MyComponent implement NgDetachAware {
 *       RouteHandle route;
 *
 *       MyComponent(RouteProvider routeProvider) {
 *         route = routeProvider.route;
 *         route.onRoute.listen((RouteEvent e) {
 *           // Do something when the route is activated.
 *         });
 *         route.onLeave.listen((RouteEvent e) {
 *           // Do something when the route is diactivated.
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
 * If user component is used outside of ng-bind-route directive then
 * injected [RouteProvider] will be null.
 */
abstract class RouteProvider {

  /**
   * Returns [Route] for [routePath].
   */
  Route get route;

  /**
   * Returns the name of the current route.
   */
  String get routeName;

  /**
   * Returns full path of the current route.
   */
  String get routePath;
}

