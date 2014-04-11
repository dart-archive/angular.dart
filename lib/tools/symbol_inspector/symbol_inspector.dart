library angular.tools.symbol_inspector;

import 'dart:mirrors';

class QualifiedSymbol {
  Symbol symbol;
  Symbol qualified;
  Symbol libraryName;

  QualifiedSymbol(this.symbol, this.qualified, this.libraryName);

  toString() => "QS($qualified)";
}

class LibraryInfo {
  List<QualifiedSymbol> names;
  Map<Symbol, List<Symbol>> symbolsUsedForName;

  LibraryInfo(this.names, this.symbolsUsedForName);
}

Iterable<Symbol> _getUsedSymbols(DeclarationMirror decl, seenDecls, path, onlyType) {

  if (seenDecls.containsKey(decl.qualifiedName)) return [];
  seenDecls[decl.qualifiedName] = true;

  if (decl.isPrivate) return [];
  path = "$path -> $decl";

  var used = [];

  if (decl is TypedefMirror) {
    var tddecl = decl as TypedefMirror;
    used.addAll(_getUsedSymbols(tddecl.referent, seenDecls, path, onlyType));
  }
  if (decl is FunctionTypeMirror) {
    var ftdecl = decl as FunctionTypeMirror;

    ftdecl.parameters.forEach((ParameterMirror p) {
      used.addAll(_getUsedSymbols(p.type, seenDecls, path, onlyType));
    });
    used.addAll(_getUsedSymbols(ftdecl.returnType, seenDecls, path, onlyType));
  }
  else if (decl is TypeMirror) {
    var tdecl = decl as TypeMirror;
    used.add(tdecl.qualifiedName);
  }


  if (!onlyType) {
    if (decl is ClassMirror) {
      var cdecl = decl as ClassMirror;
      cdecl.declarations.forEach((s, d) {
        try {
          used.addAll(_getUsedSymbols(d, seenDecls, path, false));
        } catch (e, s) {
          print("Got error [$e] when visiting $d\n$s");
        }
      });

    }

    if (decl is MethodMirror) {
      var mdecl = decl as MethodMirror;
      if (mdecl.parameters != null)
        mdecl.parameters.forEach((p) {
          used.addAll(_getUsedSymbols(p.type, seenDecls, path, true));
        });
      used.addAll(_getUsedSymbols(mdecl.returnType, seenDecls, path, true));
    }

    if (decl is VariableMirror) {
      var vdecl = decl as VariableMirror;
      used.addAll(_getUsedSymbols(vdecl.type, seenDecls, path, true));
    }
  }

  // Strip out type variables.
  if (decl is TypeMirror) {
    var tdecl = decl as TypeMirror;
    var typeVariables = tdecl.typeVariables.map((tv) => tv.qualifiedName);
    used = used.where((x) => !typeVariables.contains(x));
  }

  return used;
}

getSymbolsFromLibrary(String libraryName) {
// Set this to true to see how symbols are exported from angular.
  var SHOULD_PRINT_SYMBOL_TREE = false;

// TODO(deboer): Add types once Dart VM 1.2 is deprecated.
  LibraryInfo extractSymbols(/* LibraryMirror */ lib, [String printPrefix = ""]) {
    List<QualifiedSymbol> names = [];
    Map<Symbol, List<Symbol>> used = {};

    if (SHOULD_PRINT_SYMBOL_TREE) print(printPrefix + unwrapSymbol(lib.qualifiedName));
    printPrefix += "  ";
    lib.declarations.forEach((symbol, decl) {
      if (SHOULD_PRINT_SYMBOL_TREE) print(printPrefix + unwrapSymbol(symbol));
      names.add(new QualifiedSymbol(symbol, decl.qualifiedName, lib.qualifiedName));
      used[decl.qualifiedName] = _getUsedSymbols(decl, {}, "", false);
    });

    lib.libraryDependencies.forEach((/* LibraryDependencyMirror */ libDep) {
      LibraryMirror target = libDep.targetLibrary;
      if (!libDep.isExport) return;

      var childInfo = extractSymbols(target, printPrefix);
      var childNames = childInfo.names;

      // If there was a "show" or "hide" on the exported library, filter the results.
      // This API needs love :-(
      var showSymbols = [], hideSymbols = [];
      libDep.combinators.forEach((/* CombinatorMirror */ c) {
        if (c.isShow) {
          showSymbols.addAll(c.identifiers);
        }
        if (c.isHide) {
          hideSymbols.addAll(c.identifiers);
        }
      });

      // I don't think you can show and hide from the same library
      assert(showSymbols.isEmpty || hideSymbols.isEmpty);
      if (!showSymbols.isEmpty) {
        childNames = childNames.where((symAndLib) {
          return showSymbols.contains(symAndLib.symbol);
        });
      }
      if (!hideSymbols.isEmpty) {
        childNames = childNames.where((symAndLib) {
          return !hideSymbols.contains(symAndLib.symbol);
        });
      }

      names.addAll(childNames);
      used.addAll(childInfo.symbolsUsedForName);
    });
    return new LibraryInfo(names, used);
  };

  var lib = currentMirrorSystem().findLibrary(new Symbol(libraryName));
  try {
    return extractSymbols(lib);
  } catch (e,s) { print("EE: $e\nSS: $s"); }
}

var _SYMBOL_NAME = new RegExp('"(.*)"');
unwrapSymbol(sym) => _SYMBOL_NAME.firstMatch(sym.toString()).group(1);
