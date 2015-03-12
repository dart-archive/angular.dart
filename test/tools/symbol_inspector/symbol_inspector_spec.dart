library angular.tools.symbol_inspector;

import 'package:angular/tools/symbol_inspector/symbol_inspector.dart';
import 'simple_library.dart';

import 'package:unittest/unittest.dart' hide expect;
import 'package:guinness/guinness.dart';

Symbol symbolForName(libraryInfo, String name) =>
    libraryInfo.names.firstWhere(
            (x) => unwrapSymbol(x.qualified) == name).qualified;

void main() => describe('symbol inspector', () {
  it('should extract symbols', () {
    LibraryInfo libraryInfo = getSymbolsFromLibrary("simple_library");

    expect(libraryInfo.names.map((x) => unwrapSymbol(x.qualified)),
        unorderedEquals([
          'simple_library.A',
          'simple_library.TypedefType',
          'simple_library.MethodReturnType',
          'simple_library.TypedefReturnType',
          'simple_library.GetterType',
          'simple_library.ParamType',
          'simple_library.StaticFieldType',
          'simple_library.FieldType',
          'simple_library.TypedefParam',
          'simple_library.ConsParamType',
          'simple_library.ClosureReturn',
          'simple_library.ClosureParam',
          'simple_library.Generic'
        ]));
  });

  it('should extract all used symbols for a class', () {
    LibraryInfo libraryInfo = getSymbolsFromLibrary("simple_library");

    expect(libraryInfo.symbolsUsedForName[symbolForName(libraryInfo, 'simple_library.A')]
            .map(unwrapSymbol), unorderedEquals([
        'simple_library.A',
        'simple_library.FieldType',
        'simple_library.StaticFieldType',
        'simple_library.GetterType',
        'simple_library.ParamType',
        'simple_library.MethodReturnType',
        'simple_library.ConsParamType',
        'simple_library.ClosureReturn',
        'simple_library.ClosureParam',
        'void'
    ]));
  });

  it('should extract all used symbols for a typedef', () {
    LibraryInfo libraryInfo = getSymbolsFromLibrary("simple_library");

    expect(libraryInfo.symbolsUsedForName[symbolForName(libraryInfo, 'simple_library.TypedefType')]
            .map(unwrapSymbol), unorderedEquals([
        'simple_library.TypedefParam',
        'simple_library.TypedefReturnType',
        'simple_library.TypedefType'
    ]));
  });

  it('should not extract generic types', () {
    LibraryInfo libraryInfo = getSymbolsFromLibrary("simple_library");

    expect(libraryInfo.symbolsUsedForName[symbolForName(libraryInfo, 'simple_library.Generic')]
    .map(unwrapSymbol), unorderedEquals([
        'simple_library.Generic'
    ]));
  });

  describe('assert', () {
    var SIMPLE_LIBRARY_SYMBOLS = [
        "simple_library.ClosureParam",
        "simple_library.StaticFieldType",
        "simple_library.FieldType",
        "simple_library.ConsParamType",
        "simple_library.A",
        "simple_library.TypedefType",
        "simple_library.MethodReturnType",
        "simple_library.TypedefReturnType",
        "simple_library.GetterType",
        "simple_library.ParamType",
        "simple_library.Generic",
        "simple_library.ClosureReturn",
        "simple_library.TypedefParam"
    ];
    it('should assert symbol names are correct', () {
      assertSymbolNamesAreOk(SIMPLE_LIBRARY_SYMBOLS,
          getSymbolsFromLibrary(("simple_library")));
    });

    it('should throw if the list is missing symbols', () {
      expect(() => assertSymbolNamesAreOk([],
              getSymbolsFromLibrary(("simple_library"))),
          throwsA(contains("These symbols are exported thru the angular "
                           "library, but it shouldn't be")));
    });

    it('should throw if the list has unused symbols', () {
      expect(() => assertSymbolNamesAreOk(SIMPLE_LIBRARY_SYMBOLS..add('hello'),
              getSymbolsFromLibrary(("simple_library"))),
          throwsA(contains("These whitelisted symbols are not used")));
    });
  });
});