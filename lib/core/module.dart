library angular.core;

import 'dart:async' as async;
import 'dart:collection';
import 'dart:mirrors';
import 'package:intl/intl.dart';

import 'package:di/di.dart';

import 'package:angular/core/parser/parser.dart';
import 'package:angular/core/parser/lexer.dart';
import 'package:angular/utils.dart';

import 'package:angular/core/service.dart';
export 'package:angular/core/service.dart';

import 'package:angular/change_detection/watch_group.dart';
export 'package:angular/change_detection/watch_group.dart';
import 'package:angular/change_detection/change_detection.dart';
import 'package:angular/change_detection/dirty_checking_change_detector.dart';
import 'package:angular/core/parser/utils.dart';
import 'package:angular/core/parser/syntax.dart';

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
    type(ExceptionHandler);
    type(FilterMap);
    type(Interpolate);
    type(RootScope);
    factory(Scope, (injector) => injector.get(RootScope));
    value(ScopeStats, new ScopeStats());
    value(GetterCache, new GetterCache({}));
    value(Object, {}); // RootScope context
    type(AstParser);
    type(NgZone);

    type(Parser, implementedBy: DynamicParser);
    type(ParserBackend, implementedBy: DynamicParserBackend);
    type(DynamicParser);
    type(DynamicParserBackend);
    type(Lexer);
    type(ClosureMap);
  }
}
