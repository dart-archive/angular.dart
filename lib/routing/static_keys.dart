library angular.routing.static_keys;

import 'package:di/di.dart';
import 'package:angular/routing/module.dart';

export 'package:angular/core_dom/static_keys.dart' show WINDOW_KEY, DIRECTIVE_MAP_KEY;

Key NG_BIND_ROUTE_KEY = new Key(NgBindRoute);
Key NG_ROUTING_USE_PUSH_STATE_KEY = new Key(NgRoutingUsePushState);
Key NG_VIEW_KEY = new Key(NgView);
Key ROUTE_PROVIDER_KEY = new Key(RouteProvider);
Key ROUTE_INITIALIZER_FN_KEY = new Key(RouteInitializerFn);
Key NG_ROUTING_HELPER_KEY = new Key(NgRoutingHelper);