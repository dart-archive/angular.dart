library angular.core;

import 'dart:async' as async;
import 'dart:convert' show JSON;
import 'dart:collection';
import 'dart:mirrors';

import 'package:di/di.dart';
import 'package:perf_api/perf_api.dart';
import 'package:meta/meta.dart';

import 'parser/parser_library.dart';
import '../utils.dart';


part "cache.dart";
part "directive.dart";
part "exception_handler.dart";
part "filter.dart";
part "interpolate.dart";
part "registry.dart";
part "scope.dart";
part "zone.dart";


class NgCoreModule extends Module {
  NgCoreModule() {
    type(ScopeDigestTTL);

    type(MetadataExtractor);
    type(Cache);
    type(DirectiveMap);
    type(ExceptionHandler);
    type(FilterMap);
    type(Interpolate);
    type(Scope);
    type(NgZone);

    type(Parser, implementedBy: DynamicParser);
    type(DynamicParser);
    type(Lexer);
    type(ParserBackend);
    type(GetterSetter);
  }
}
