library angular.converter;
import 'dart:convert' show JSON;
import 'package:di/di.dart';
import 'package:di/annotations.dart';

part 'json_parser.dart';

class ConverterModule extends Module {
  ConverterModule() {
    bind(JsonParser);
  }
}
