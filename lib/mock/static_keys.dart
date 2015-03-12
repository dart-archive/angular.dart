library angular.mock.static_keys;

import 'package:di/di.dart';
import 'package:angular/mock/module.dart';

export 'package:angular/core_dom/static_keys.dart' show DIRECTIVE_MAP_KEY;

Key MOCK_HTTP_BACKEND_KEY = new Key(MockHttpBackend);