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
 * parent ng-bind-route or ng-view directive.
 *
 * ng-bind-route overrides [RouteProvider] instance published by ng-view,
 * however it does not effect view resolution by nested ng-view(s).
 */
@Decorator(
    visibility: Directive.CHILDREN_VISIBILITY,
    selector: '[ng-bind-route]',
    module: NgBindRoute.module,
    map: const {'ng-bind-route': '@routeName'})
class NgBindRoute implements RouteProvider {
  Router _router;
  String routeName;
  Injector _injector;

  static final Module _module = new Module()
      ..factory(RouteProvider,
                (i) => i.get(NgBindRoute),
                visibility: Directive.CHILDREN_VISIBILITY);
  static module() => _module;

  // We inject NgRoutingHelper to force initialization of routing.
  NgBindRoute(this._router, this._injector, NgRoutingHelper _);

  /// Returns the parent [RouteProvider].
  RouteProvider get _parent => _injector.parent.get(RouteProvider);

  Route get route => routeName.startsWith('.') ?
      _parent.route.getRoute(routeName.substring(1)) :
      _router.root.getRoute(routeName);

  Map<String, String> get parameters {
    var res = <String, String>{};
    var p = route;
    while (p != null) {
      res.addAll(p.parameters);
      p = p.parent;
    }
    return res;
  }
}
