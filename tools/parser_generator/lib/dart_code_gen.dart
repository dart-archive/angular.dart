library dart_code_gen;

import 'package:angular/parser/parser_library.dart';  // For ParserBackend.

class Code implements ParserAST {
  String _exp;
  String _returnOnly;
  Function assign;
  Code(this._exp, [this.assign]);

  Code.returnOnly(this._returnOnly);

  returnExp() => _returnOnly != null ? _returnOnly : "return $exp;";

  get exp {
    if (_exp == null) { throw "Can not be used in an expression"; }
    return _exp;
  }
  get assignable => assign != null;
}

escape(String s) => s.replaceAll('\'', '\\\'').replaceAll(r'$', r'\$');

class GetterSetterGenerator {
  static RegExp LAST_PATH_PART = new RegExp(r'(.*)\.(.*)');

  // From https://www.dartlang.org/docs/spec/latest/dart-language-specification.html#h.huusvrzea3q
  static List<String> RESERVED_DART_KEYWORDS = [
      "assert", "break", "case", "catch", "class", "const", "continue",
      "default", "do", "else", "enum", "extends", "false", "final",
      "finally", "for", "if", "in", "is", "new", "null", "rethrow",
      "return", "super", "switch", "this", "throw", "true", "try",
      "var", "void", "while", "with"];
  isReserved(String key) => RESERVED_DART_KEYWORDS.contains(key);


  String functions = "// GETTER AND SETTER FUNCTIONS\n\n";
  var _keyToGetterFnName = {};
  var _keyToSetterFnName = {};
  var nextUid = 0;

  fieldGetter(String field, String obj) {
    var eKey = escape(field);

    var returnValue = isReserved(field) ? "undefined_ /* $field is reserved */" : "$obj.$field";

    return """
  if ($obj is Map) {
    if ($obj.containsKey('$eKey')) {
      val = $obj['$eKey'];
    } else {
      val = undefined_;
    }
  } else {
    val = $returnValue;
  }

""";
  }

  fieldSetter(String field, String obj) {
    var eKey = escape(field);

    var maybeField = isReserved(field) ? "/* $field is reserved */" : """
  $obj.$field = value;
  return value;
    """;

    return """
  if ($obj is Map) {
    $obj['$eKey'] = value;
    return value;
  }
  $maybeField
}
""";
  }

  call(String key) {
    if (_keyToGetterFnName.containsKey(key)) {
      return _keyToGetterFnName[key];
    }

    var uid = nextUid++;
    var fnName = "_getter_$uid";

    var f = "$fnName(scope, locals) { // for $key\n";
    f += "  var val;\n";
    var obj = "scope";

    var field = key;
    var pathSplit = LAST_PATH_PART.firstMatch(key);
    if (pathSplit != null) {
      var prefixFn = call(pathSplit[1]);
      field = pathSplit[2];
      f += """  var prefix = $prefixFn(scope, locals);
  if (prefix == null) return null;
""";
      obj = "prefix";
    } else {
      // Check for locals on scope keys only.

      // This try block is needed because we attempt to access locals.foo
      // If foo does not exist, we should fall through.
      f += "  try {\n";
      f += fieldGetter(field, "locals");
      f += "    if (val != undefined_) { return val; }\n";
      f += "  } catch (e) {}\n";
    }
    f += fieldGetter(field, obj);
    f += "  return val == undefined_ ? null : val;\n";
    f += "}";

    functions += f;

    _keyToGetterFnName[key] = fnName;
    return fnName;
  }

  setter(String key) {
    if (_keyToSetterFnName.containsKey(key)) {
      return _keyToSetterFnName[key];
    }

    var uid = nextUid++;
    var fnName = "_setter_$uid";

    var f = "$fnName(scope, locals, value) { // for $key\n";
    var obj = "scope";

    var field = key;
    var pathSplit = LAST_PATH_PART.firstMatch(key);
    if (pathSplit != null) {
      var prefixFn = call(pathSplit[1]);
      var prefixSetter = setter(pathSplit[1]);
      field = pathSplit[2];
      f += """  var prefix = $prefixFn(scope, locals);
  if (prefix == null) {
    prefix = {};
    $prefixSetter(scope, locals, prefix);
  }
""";
      obj = "prefix";
    }

    f += fieldSetter(field, obj);
    functions += f;

    _keyToSetterFnName[key] = fnName;
    return fnName;
  }
}


class DartCodeGen implements ParserBackend {
  static Code ZERO = new Code("0");

  GetterSetterGenerator _getterGen;

  DartCodeGen(GetterSetterGenerator this._getterGen);

  // Returns the Dart code for a particular operator.
  _op(fn) => fn == "undefined" ? "null" : fn;

  Code binaryFn(Code left, String fn, Code right) {
    if (fn == '+') {
      return new Code("autoConvertAdd(${left.exp}, ${right.exp})");
    }
    var leftExp = left.exp;
    var rightExp = right.exp;
    if (fn == '&&' || fn == '||') {
      leftExp = "toBool($leftExp)";
      rightExp = "toBool($rightExp)";
    }
    return new Code("(${leftExp} ${_op(fn)} ${rightExp})");
  }

  Code unaryFn(String fn, Code right) {
    var rightExp = right.exp;
    if (fn == '!') {
      rightExp = "toBool($rightExp)";
    }
    return new Code("${_op(fn)}${rightExp}");
  }

  Code assignment(Code left, Code right, evalError) =>
    left.assign(right);

  Code multipleStatements(List<Code >statements) {
    var code = "var ret, last;\n";
    code += statements.map((Code s) =>
        "last = ${s.exp};\nif (last != null) { ret = last; }\n").join('\n');
    code += "return ret;\n";
    return new Code.returnOnly(code);
  }

  Code functionCall(Code fn, fnName, List<Code> argsFn, evalError) =>
      new Code("safeFunctionCall(${fn.exp}, \'${escape(fnName)}\', evalError)(${argsFn.map((a) => a.exp).join(', ')})");

  Code arrayDeclaration(List<Code> elementFns) =>
    new Code("[${elementFns.map((Code e) => e.exp).join(', ')}]");

  Code objectIndex(Code obj, Code indexFn, evalError) {
    var assign = (Code right)  =>
        new Code("objectIndexSetField(${obj.exp}, ${indexFn.exp}, ${right.exp}, evalError)");

    return new Code("objectIndexGetField(${obj.exp}, ${indexFn.exp}, evalError)", assign);
  }

  Code fieldAccess(Code object, String field) {
    var getterFnName = _getterGen(field);
    var assign = (Code right) {
      var setterFnName = _getterGen.setter(field);
      return new Code("$setterFnName(${object.exp}, null, ${right.exp})");
    };
    return new Code("$getterFnName/*field:$field*/(${object.exp}, null)", assign);
  }

  Code object(List keyValues) =>
      new Code(
        "{${keyValues.map((k) => "${_value(k["key"])}: ${k["value"].exp}").join(', ')}}");

  profiled(value, perf, text) => value; // no profiling for now

  Code fromOperator(String op) => new Code(_op(op));

  Code getterSetter(String key) {
    var getterFnName = _getterGen(key);

    var assign = (Code right) {
      var setterFnName = _getterGen.setter(key);
      return new Code("${setterFnName}(scope, locals, ${right.exp})");
    };

    return new Code("$getterFnName/*$key*/(scope, locals)", assign);
  }

  String _value(v) =>
      v is String ? "r\'${escape(v)}\'" : "$v";

  Code value(v) => new Code(_value(v));

  Code zero() => ZERO;
}
