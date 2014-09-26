library angular.object_parser;
import 'dart:convert' show JSON;
import 'package:di/di.dart';
import 'package:di/annotations.dart';

part 'json_parser.dart';

class ParserModule extends Module {
  ParserModule() {
    bind(ObjectParser, toImplementation: JsonParser);
  }
}
@Injectable()
abstract class ObjectParser {
  String decode(Object source);
  dynamic encode(String source);
}
