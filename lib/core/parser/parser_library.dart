library angular.core.parser;

import 'dart:mirrors';

import 'package:angular/utils.dart';
import 'package:angular/core/module.dart';


part 'backend.dart';
part 'lexer.dart';
part 'parser.dart';
part 'static_parser.dart';

// Placeholder for DI.
// The parser you are looking for is DynamicParser
abstract class Parser {
  call(String text) {}
  primaryFromToken(Token token, parserError);
}
