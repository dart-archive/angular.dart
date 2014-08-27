library angular.core_internal;

import 'dart:async' as async;
import 'dart:collection';
import 'dart:math';
import 'package:intl/intl.dart';

import 'package:di/di.dart';
import 'package:di/annotations.dart';

import 'package:angular/core/parser/parser.dart';
import 'package:angular/core/parser/lexer.dart';
import 'package:angular/utils.dart';
import 'package:angular/ng_tracing.dart';

import 'package:angular/core/annotation_src.dart';

import 'package:angular/cache/module.dart';
import 'package:angular/change_detection/watch_group.dart';
export 'package:angular/change_detection/watch_group.dart';
import 'package:angular/change_detection/ast_parser.dart';
import 'package:angular/change_detection/change_detection.dart';
import 'package:angular/change_detection/dirty_checking_change_detector.dart';
import 'package:angular/core/formatter.dart';
export 'package:angular/core/formatter.dart';
import 'package:angular/core/parser/utils.dart';
import 'package:angular/core/registry.dart';
import 'package:angular/core/static_keys.dart';

part "exception_handler.dart";
part "interpolate.dart";
part "scope.dart";
part "zone.dart";


class CoreModule extends Module {
  CoreModule() {
    bind(ScopeDigestTTL);

    bind(ExceptionHandler);
    bind(FormatterMap);
    bind(Interpolate);
    bind(RootScope);
    bind(Scope, toInstanceOf: RootScope);
    bind(ClosureMap, toFactory: () => throw "Must provide dynamic/static ClosureMap.");
    bind(ScopeStats);
    bind(ScopeStatsEmitter);
    bind(ScopeStatsConfig);
    bind(Object, toValue: {}); // RootScope context

    bind(Parser, toInstanceOf: DynamicParser);
    bind(ParserBackend, toInstanceOf: DynamicParserBackend);
    bind(DynamicParser);
    bind(DynamicParserBackend);
    bind(Lexer);
    bind(ASTParser);
  }
}
