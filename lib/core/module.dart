library angular.core;

import 'dart:async' as async;
import 'dart:collection';
import 'dart:convert' show JSON;
import 'dart:mirrors';

import 'package:di/di.dart';
import 'package:perf_api/perf_api.dart';

import 'package:angular/core/parser/parser.dart';
import 'package:angular/core/parser/lexer.dart';
import 'package:angular/utils.dart';

import 'package:angular/core/service.dart';
export 'package:angular/core/service.dart';

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
    type(FieldMetadataExtractor);
    type(Cache);
    type(DirectiveMap);
    type(ExceptionHandler);
    type(FilterMap);
    type(Interpolate);
    type(Scope);
    type(NgZone);

    type(Parser, implementedBy: DynamicParser);
    type(ParserBackend, implementedBy: DynamicParserBackend);
    type(DynamicParser);
    type(DynamicParserBackend);
    type(Lexer);
    type(ClosureMap);
  }
}
