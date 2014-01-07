import 'package:angular/core/parser/new_syntax.dart';
import 'package:angular/tools/reserved_dart_keywords.dart';

class DartGetterSetterGen extends ParserBackend {
  final Set<String> properties = new Set<String>();
  final Map<String, Set<int>> calls = new Map<String, Set<int>>();

  registerAccess(String name) {
    if (isReserved(name)) return;
    properties.add(name);
  }

  registerCall(String name, List arguments) {
    if (isReserved(name)) return;
    Set<int> arities = calls.putIfAbsent(name, () => new Set<int>());
    arities.add(arguments.length);
  }

  newAccessScope(String name)
      => registerAccess(name);
  newAccessMember(var object, String name)
      => registerAccess(name);
  newCallScope(String name, List arguments)
      => registerCall(name, arguments);
  newCallMember(var object, String name, List arguments)
      => registerCall(name, arguments);
}

class ParserGetterSetter {
  final Parser parser;
  ParserGetterSetter(this.parser);

  generateParser(List<String> exprs) {
    exprs.forEach((expr) {
      try {
        parser.parse(expr);
      } catch (e) {
        // Ignore exceptions.
      }
    });

    DartGetterSetterGen backend = parser.backend;
    print(generateClosureMap(backend.properties, backend.calls));
  }

  generateClosureMap(Set<String> properties, Map<String, Set<int>> calls) {
    return '''
class StaticClosureMap extends ClosureMap {
  Map<String, Function> _getters = ${generateGetterMap(properties)};
  List<Map<String, Function>> _functions = ${generateFunctionMap(calls)};
  lookupGetter(String name) => _getters[name];
  lookupFunction(String name, int arity) {
    return (arity < _functions.length)
        ? _functions[arity][name]
        : null;
  }
}
''';
  }

  generateGetterMap(Iterable<String> keys) {
    var lines = keys.map((key) => 'r"${key}": (s) => s.$key');
    return '{\n   ${lines.join(",\n    ")}\n  }';
  }

  generateFunctionMap(Map<String, Set<int>> calls) {
    List<Set> arities = [];
    for (String name in calls.keys) {
      for (int arity in calls[name]) {
        if (arity >= arities.length) arities.length = arity + 1;
        Set<String> names = arities[arity];
        if (names == null) arities[arity] = names = new Set();
        names.add(name);
      }
    }
    var maps = [];
    for (int i = 0; i < arities.length; i++) {
      Set<String> names = arities[i];
      if (names == null) {
        maps.add('{\n    }');
      } else {
        var args = i == 0 ? '' : new List.generate(i, (e) => "a$e").join(',');
        var p = args.isEmpty ? '' : ',$args';
        var lines = names.map((name) => 'r"$name": (s$p) => s.$name($args)');
        maps.add('{\n    ${lines.join(",\n    ")}\n  }');
      }
    }
    return '[${maps.join(",")}]';
  }
}
