library angular.routing;

import 'dart:html';

import 'package:di/di.dart';
import 'package:angular/angular.dart';
import 'package:route_hierarchical/client.dart';
export 'package:route_hierarchical/client.dart';

part 'routing.dart';
part 'ng_view.dart';
part 'ng_bind_route.dart';

class NgRoutingModule extends Module {
  NgRoutingModule({bool usePushState: true}) {
    type(NgRoutingUsePushState);
    factory(Router, (injector) {
      var useFragment = !injector.get(NgRoutingUsePushState).usePushState;
      return new Router(useFragment: useFragment,
                        windowImpl: injector.get(Window));
    });
    type(_RoutingHelper);
    value(RouteProvider, null);
    value(RouteInitializer, null);

    // directives
    type(NgViewDirective);
    type(NgBindRouteDirective);
  }
}

/**
 * Allows configuration of [Router.useFragment]. By default [usePushState] is
 * true, so router will be listen to [Window.onPopState] and route URLs like
 * "http://host:port/foo/bar?baz=qux". Both path and query parts of the URL
 * are used by the router. If [usePushState] is false, router will listen to
 * [Window.onHashChange] and route URLs like
 * "http://host:port/path#/foo/bar?baz=qux". Everything after hash (#) is used
 * by the router.
 */
class NgRoutingUsePushState {
  final bool usePushState;
  NgRoutingUsePushState(): usePushState = true;
  NgRoutingUsePushState.value(bool this.usePushState);
}
