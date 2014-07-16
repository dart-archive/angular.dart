library angular.core.parser_dynamic;

@MirrorsUsed(targets: const [ DynamicClosureMap ], metaTargets: const [] )
import 'dart:mirrors';
import 'package:angular/core/parser/parser.dart';

class DynamicClosureMap implements ClosureMap {
  final Map<String, Symbol> symbols = {};
  Getter lookupGetter(String name) {
    var symbol = new Symbol(name);
    return (o) => reflect(o).getField(symbol).reflectee;
  }

  Setter lookupSetter(String name) {
    var symbol = new Symbol(name);
    return (o, value) {
      reflect(o).setField(symbol, value);
      return value;
    };
  }

  MethodClosure lookupFunction(String name, CallArguments arguments) {
    var symbol = new Symbol(name);
    return (o, posArgs, namedArgs) {
      var sNamedArgs = {};
      namedArgs.forEach((name, value) {
        var symbol = symbols.putIfAbsent(name, () => new Symbol(name));
        sNamedArgs[symbol] = value;
      });
      return reflect(o).invoke(symbol, posArgs, sNamedArgs).reflectee;
    };
  }

  Symbol lookupSymbol(String name) => new Symbol(name);
}
