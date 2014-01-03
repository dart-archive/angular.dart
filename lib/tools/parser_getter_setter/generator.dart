import 'package:angular/core/parser/new_parser.dart';
import 'package:angular/tools/reserved_dart_keywords.dart';

class DartGetterSetterGen extends ParserBackend {
  Set<String> identifiers = new Set<String>();
  access(String name) => identifiers.add(name);
  newAccessScope(String name) => access(name);
  newAccessMember(var object, String name) => access(name);
  newCallScope(String name, List arguments) => access(name);
  newCallMember(var object, String name, List arguments) => access(name);
}

class ParserGetterSetter {
  final Parser parser;
  ParserGetterSetter(this.parser);

  generateParser(List<String> exprs) {
    exprs.forEach((expr) {
      try {
        parser.parse(expr);
      } catch (e) { }
    });

    DartGetterSetterGen backend = parser.backend;
    print(generateCode(backend.identifiers));
  }

  generateCode(Iterable<String> keys) {
    keys = keys.where((key) => !isReserved(key));
    return '''
class StaticGetterSetter extends GetterSetter {
  Map<String, Function> _getters = ${generateGetterMap(keys)};
  Map<String, Function> _setters = ${generateSetterMap(keys)};

  Function getter(String key) {
    return _getters.containsKey(key) ? _getters[key] : super.getter(key);
  }

  Function setter(String key) {
    return _setters.containsKey(key) ? _setters[key] : super.setter(key);
  }
}
''';
  }

  generateGetterMap(Iterable<String> keys) {
    var lines = keys.map((key) => 'r"${key}": (s) => s.$key');
    return '{\n   ${lines.join(",\n    ")}\n  }';
  }

  generateSetterMap(Iterable<String> keys) {
    var lines = keys.map((key) => 'r"${key}": (s, v) => s.$key = v');
    return '{\n   ${lines.join(",\n    ")}\n  }';
  }
}
