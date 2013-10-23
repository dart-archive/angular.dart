library angular.core.parser;

import 'dart:mirrors';

import '../../utils.dart';
import '../module.dart';


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
