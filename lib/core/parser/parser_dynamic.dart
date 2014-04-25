library angular.core.parser_dynamic;

@MirrorsUsed(targets: const [ DynamicClosureMap ], metaTargets: const [] )
import 'dart:mirrors';
import 'package:angular/core/parser/parser.dart';

class DynamicClosureMap implements ClosureMap {
  final Map<String, Symbol> symbols = {};

  Getter lookupGetter(String name) {
    var symbol;
    return (o) {
      if (o is Map) {
        return o[name];
      } else {
        if (symbol == null) symbol = lookupSymbol(name);
        return reflect(o).getField(symbol).reflectee;
      }
    };
  }

  Setter lookupSetter(String name) {
    var symbol;
    return (o, value) {
      if (o is Map) {
        return o[name] = value;
      } else {
        if (symbol == null) symbol = lookupSymbol(name);
        reflect(o).setField(symbol, value);
        return value;
      }
    };
  }

  MethodClosure lookupFunction(String name, CallArguments arguments) {
    var symbol;
    return (o, posArgs, namedArgs) {
      var sNamedArgs = new Map.fromIterables(namedArgs.keys.map(lookupSymbol), namedArgs.values);
      if (o is Map) {
        var fn = o[name];
        if (fn is Function) {
          return Function.apply(fn, posArgs, sNamedArgs);
        } else {
          throw "Property '$name' is not of type function.";
        }
      } else {
        try {
          if (symbol == null) symbol = lookupSymbol(name);
          return reflect(o).invoke(symbol, posArgs, sNamedArgs).reflectee;
        } on NoSuchMethodError catch (e) {
          throw 'Undefined function $name';
        }
      }
    };
  }

  Symbol lookupSymbol(String name) => symbols.putIfAbsent(name, () => new Symbol(name));
}
