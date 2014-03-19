import 'package:angular/core/parser/parser.dart';
import 'package:angular/utils.dart' show isReservedWord;
import 'dart:math';

class DartGetterSetterGen extends ParserBackend {
  final Set<String> properties = new Set<String>();
  final Map<int, Map<String, Iterable>> calls =
      new Map<int, Map<String, Iterable>>();

  bool isAssignable(expression) => true;

  registerAccess(String name) {
    if (isReservedWord(name)) return;
    properties.add(name);
  }

  registerCall(String name, CallArguments arguments) {
    if (isReservedWord(name)) return;
    Map<String, Iterable> map = calls.putIfAbsent(arguments.arity,
        () => new Map<String, Iterable>());
    if (arguments.named.isEmpty) {
      map[name] = map[''] = null;
    } else {
      Iterable names = arguments.named.keys;
      String suffix = names.join(',');
      map["$name:$suffix"] = map[":$suffix"] = names;
    }
  }

  newAccessScope(String name)
      => registerAccess(name);
  newAccessMember(var object, String name)
      => registerAccess(name);
  newCallScope(String name, CallArguments arguments)
      => registerCall(name, arguments);
  newCallMember(var object, String name, CallArguments arguments)
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

  generateClosureMap(Set<String> properties,
                     Map<int, Map<String, Iterable>> calls) {
    return '''
class StaticClosureMap extends ClosureMap {
  Map<String, Getter> _getters = ${generateGetterMap(properties)};
  Map<String, Setter> _setters = ${generateSetterMap(properties)};
  List<Map<String, Function>> _functions = ${generateFunctionMap(calls)};

  Getter lookupGetter(String name)
      => _getters[name];
  Setter lookupSetter(String name)
      => _setters[name];
  Function lookupFunction(String name, CallArguments arguments) {
    int arity = arguments.arity;
    if (arity >= _functions.length) return null;
    Iterable named = arguments.named.keys;
    Map map = _functions[arity];
    return (named.isEmpty) ? map[name] : map["\$name:\${named.join(',')}"];
  }
}
''';
  }

  generateGetterMap(Iterable<String> keys) {
    var lines = keys.map((key) => 'r"${key}": (o) => o.$key');
    return '{\n   ${lines.join(",\n    ")}\n  }';
  }

  generateSetterMap(Iterable<String> keys) {
    var lines = keys.map((key) => 'r"${key}": (o,v) => o.$key = v');
    return '{\n   ${lines.join(",\n    ")}\n  }';
  }

  generateFunctionMap(Map<int, Map<String, Iterable>> calls) {
    var maxArity = calls.keys.reduce((x, y) => max(x, y));
    var maps = new Iterable.generate(maxArity, (arity) {
      Map names = calls[arity];
      if (names == null) {
        return '{\n    }';
      } else {
        var args = new List.generate(arity, (e) => "a$e").join(',');
        var p = args.isEmpty ? '' : ',$args';
        var lines = [];
        names.forEach((String name, Iterable names) {
          if (name == "") {
            lines.add('r"": (f$p) => f($args)');
          } else if (names == null) {
            lines.add('r"$name": (o$p) => o.$name($args)');
          } else {
            int positionals = arity - names.length;
            var pos = new List.generate(positionals, (e) => "a$e").join(',');
            if (pos.isNotEmpty) pos = '$pos,';
            int index = positionals;
            var n = names.map((e) => "$e:a${index++}").join(',');
            if (name.startsWith(':')) {
              lines.add('r"$name": (f$p) => f(${pos}${n})');
            } else {
              var shortName = name.substring(0, name.indexOf(':'));
              lines.add('r"$name": (o$p) => o.$shortName(${pos}${n})');
            }
          }
        });
        return '{\n    ${lines.join(",\n    ")}\n  }';
      }
    });

    return '[${maps.join(",")}]';
  }
}
