import 'package:angular/core/parser/parser.dart';
import 'package:angular/tools/reserved_dart_keywords.dart';
import 'dart:math';

class DartGetterSetterGen extends ParserBackend {
  final Set<String> properties = new Set<String>();
  final Map<String, Set<int>> calls = new Map<String, Set<int>>();

  bool isAssignable(expression) => true;

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
  final ParserBackend backend;
  ParserGetterSetter(this.parser, this.backend);

  generateParser(List<String> exprs) {
    exprs.forEach((expr) {
      try {
        parser(expr);
      } catch (e) {
        // Ignore exceptions.
      }
    });

    DartGetterSetterGen backend = this.backend;
    print(generateClosureMap(backend.properties, backend.calls));
  }

  generateClosureMap(Set<String> properties, Map<String, Set<int>> calls) {
    return '''
class StaticClosureMap extends ClosureMap {
  Map<String, Getter> _getters = ${generateGetterMap(properties)};
  Map<String, Setter> _setters = ${generateSetterMap(properties)};
  List<Map<String, Function>> _functions = ${generateFunctionMap(calls)};

  Getter lookupGetter(String name)
      => _getters[name];
  Setter lookupSetter(String name)
      => _setters[name];
  lookupFunction(String name, int arity) 
      => (arity < _functions.length) ? _functions[arity][name] : null;
}
''';
  }

  generateGetterMap(Iterable<String> keys) {
    var lines = keys.map((key) => 'r"${key}": (o) => o.$key');
    return '{\n   ${lines.join(",\n    ")}\n  }';
  }

  generateSetterMap(Iterable<String> keys) {
    var lines = keys.map((key) => 'r"${key}": (o, v) => o.$key = v');
    return '{\n   ${lines.join(",\n    ")}\n  }';
  }

  generateFunctionMap(Map<String, Set<int>> calls) {
    Map<int, Set<String>> arities = {};
    calls.forEach((name, callArities) {
      callArities.forEach((arity){
        arities.putIfAbsent(arity, () => new Set<String>()).add(name);
      });
    });

    var maxArity = arities.keys.reduce((x, y) => max(x, y));

    var maps = new Iterable.generate(maxArity, (arity) {
      var names = arities[arity];
      if (names == null) {
        return '{\n    }';
      } else {
        var args = new List.generate(arity, (e) => "a$e").join(',');
        var p = args.isEmpty ? '' : ', $args';
        var lines = names.map((name) => 'r"$name": (o$p) => o.$name($args)');
        return '{\n    ${lines.join(",\n    ")}\n  }';
      }
    });

    return '[${maps.join(",")}]';
  }
}
