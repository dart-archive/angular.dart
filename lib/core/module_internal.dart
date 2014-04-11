library angular.core_internal;

import 'dart:async' as async;
import 'dart:collection';
import 'dart:math';
import 'package:intl/intl.dart';

import 'package:di/di.dart';

import 'package:angular/core/parser/parser.dart';
import 'package:angular/core/parser/lexer.dart';
import 'package:angular/utils.dart';

import 'package:angular/core/annotation_src.dart';

import 'package:angular/change_detection/watch_group.dart';
export 'package:angular/change_detection/watch_group.dart';
import 'package:angular/change_detection/change_detection.dart';
import 'package:angular/change_detection/dirty_checking_change_detector.dart';
import 'package:angular/core/parser/utils.dart';
import 'package:angular/core/parser/syntax.dart';
import 'package:angular/core/registry.dart';

part "cache.dart";
part "exception_handler.dart";
part "filter.dart";
part "interpolate.dart";
part "scope.dart";
part "zone.dart";


class CoreModule extends Module {
  CoreModule() {
    type(ScopeDigestTTL);

    type(MetadataExtractor);
    type(Cache);
    type(ExceptionHandler);
    type(FormatterMap);
    type(Interpolate);
    type(RootScope);
    factory(Scope, (injector) => injector.get(RootScope));
    factory(ClosureMap, (_) => throw "Must provide dynamic/static ClosureMap.");
    type(ScopeStats);
    type(ScopeStatsEmitter);
    factory(ScopeStatsConfig, (i) => new ScopeStatsConfig());
    value(Object, {}); // RootScope context
    type(VmTurnZone);

    type(Parser, implementedBy: DynamicParser);
    type(ParserBackend, implementedBy: DynamicParserBackend);
    type(DynamicParser);
    type(DynamicParserBackend);
    type(Lexer);
  }
}
