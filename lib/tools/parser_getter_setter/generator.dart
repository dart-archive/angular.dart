import 'package:angular/core/parser/parser_library.dart';
import 'package:angular/tools/reserved_dart_keywords.dart';

class _AST implements ParserAST {
  bool get assignable => true;
}

class DartGetterSetterGen implements ParserBackend {
  Map<String, bool> identifiers = {};

  profiled(value, perf, text)  => new _AST();

  binaryFn(left, String fn, right) => new _AST();
  unaryFn(String fn, right)  => new _AST();
  assignment(left, right, evalError)  => new _AST();
  multipleStatements(List statements)  => new _AST();
  arrayDeclaration(List elementFns)  => new _AST();
  objectIndex(obj, indexFn, evalError)  => new _AST();
  object(List keyValues)  => new _AST();
  fromOperator(String op) => new _AST();
  value(v) => new _AST();
  zero() => new _AST();
  functionCall(fn, fnName, List argsFn, evalError) => new _AST();


  fieldAccess(object, String field) {
    identifiers[field] = true;
    return new _AST();
  }

  getterSetter(String key)  {
    key.split('.').forEach((i) => identifiers[i] = true);
    return new _AST();
  }
}

class ParserGetterSetter {

  DynamicParser parser;
  DartGetterSetterGen backend;

  ParserGetterSetter(DynamicParser this.parser, ParserBackend this.backend);

  generateParser(List<String> exprs) {
    exprs.forEach((expr) {
      try {
        parser(expr);
      } catch (e) { }
    });

    print(generateCode(backend.identifiers.keys.toList()));
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
