library dart_code_gen;

import 'package:angular/tools/reserved_dart_keywords.dart';
import 'package:angular/core/parser/parser_library.dart';
import 'package:angular/core/parser/new_syntax.dart' as np;
import 'source.dart';

class NewDartCodeGen extends np.Visitor {
  bool assigning = false;
  bool holder = false;

  static Map<String, String> getters = new Map<String, String>();
  static Map<String, String> getterNames = new Map<String, String>();

  static Map<String, String> holders = new Map<String, String>();
  static Map<String, String> holderNames = new Map<String, String>();

  static Map<String, String> setters = new Map<String, String>();
  static Map<String, String> setterNames = new Map<String, String>();

  static String generateForExpression(np.Expression expression, bool assign) {
    NewDartCodeGen visitor = new NewDartCodeGen();
    return assign
        ? visitor.visitForAssign(expression)('value')
        : visitor.visitForValue(expression);
  }

  String computeGetterName(String name) {
    String result = getterNames[name];
    if (result != null) return result;
    return (getterNames[name] = '_$name');
  }

  String computeHolderName(String name) {
    String result = holderNames[name];
    if (result != null) return result;
    return (holderNames[name] = '_x\$$name');
  }

  String computeSetterName(String name) {
    String result = setterNames[name];
    if (result != null) return result;
    return (setterNames[name] = '_set\$$name');
  }

  String lookupGetter(String name) {
    String getterName = computeGetterName(name);
    if (getters.containsKey(name)) return getterName;
    String key = escape(name);
    String field = isReserved(name) ? "null" : "o.$name";
    StringBuffer buffer = new StringBuffer()
        ..writeln('$getterName(o) {')
        ..writeln('  if (o == null) return null;')
        ..writeln('  return (o is Map) ? o["$key"] : $field;')
        ..writeln('}');
    getters[name] = "$buffer";
    return getterName;
  }

  String lookupHolder(String name) {
    String holderName = computeHolderName(name);
    if (holders.containsKey(name)) return holderName;
    String key = escape(name);
    StringBuffer buffer = new StringBuffer()
        ..writeln('$holderName(o) {')
        ..writeln('  if (o == null) return null;')
        ..writeln('  if (o is Map) {')
        ..writeln('    var key = "$key";')
        ..writeln('    var result = o[key];')
        ..writeln('    return (result == null) ? result = o[key] = {} : result;')
        ..writeln('  } else {');
    if (isReserved(name)) {
      buffer.writeln('    return {};');
    } else {
      buffer.writeln('    var result = o.$name;');
      buffer.writeln('    return (result == null) ? result = o.$name = {} : result;');
    }
    buffer.writeln('  }');
    buffer.writeln('}');
    holders[name] = "$buffer";
    return holderName;
  }

  String lookupSetter(String name) {
    String setterName = computeSetterName(name);
    if (setters.containsKey(name)) return setterName;
    String key = escape(name);
    String fieldUpdate = isReserved(name) ? "" : " else o.$name = v;";
    StringBuffer buffer = new StringBuffer()
        ..writeln('$setterName(o, v) {')
        ..writeln('  if (o is Map) o["$key"] = v;$fieldUpdate')
        ..writeln('  return v;')
        ..writeln('}');
    setters[name] = "$buffer";
    return setterName;
  }

  Function visitForAssign(np.Assignable target) {
    bool old = assigning;
    assigning = true;
    Function result = visit(target);
    assigning = old;
    return result;
  }

  String visitForValue(np.Expression expression, {bool toBool: false}) {
    bool old = assigning;
    assigning = false;
    String result = visit(expression);
    if (toBool) result = "toBool($result)";
    assigning = old;
    return result;
  }

  String visitForHolder(np.Expression expression) {
    bool old = holder;
    holder = true;
    String result = visitForValue(expression);
    holder = old;
    return result;
  }

  visitChain(np.Chain chain) {
    StringBuffer buffer = new StringBuffer();
    buffer.writeln("var result, last;");
    for (int i = 0; i < chain.expressions.length; i++) {
      String expression = visitForValue(chain.expressions[i]);
      buffer.writeln('last = $expression;');
      buffer.writeln('if (last != null) result = last;');
    }
    buffer.writeln('return result;');
    return "$buffer";
  }

  visitFilter(np.Filter filter) {
    List expressions = [ filter.expression ]..addAll(filter.arguments);
    String arguments = expressions.map((e) => visitForValue(e)).join(', ');
    String name = escape(filter.name);
    return 'filters("$name")($arguments)';
  }

  visitAssign(np.Assign expression) {
    String value = visitForValue(expression.value);
    return visitForAssign(expression.target)(value);
  }

  visitConditional(np.Conditional conditional) {
    String condition = visitForValue(conditional.condition, toBool: true);
    String yes = visitForValue(conditional.yes);
    String no = visitForValue(conditional.no);
    return "$condition ? $yes : $no";
  }

  visitAccessScope(np.AccessScope access) {
    if (assigning) {
      String setter = lookupSetter(access.name);
      return (value) => '$setter(scope, $value)';
    } else {
      String getter = holder
          ? lookupHolder(access.name)
          : lookupGetter(access.name);
      return '$getter(scope)';
    }
  }

  visitAccessMember(np.AccessMember access) {
    String object = assigning || holder
        ? visitForHolder(access.object)
        : visitForValue(access.object);
    if (assigning) {
      String setter = lookupSetter(access.name);
      return (value) => '$setter($object, $value)';
    } else {
      String getter = holder
          ? lookupHolder(access.name)
          : lookupGetter(access.name);
      return '$getter($object)';
    }
  }

  visitAccessKeyed(np.AccessKeyed access) {
    String object = visitForValue(access.object);
    String key = visitForValue(access.key);
    return (assigning)
        ? (value) => 'objectIndexSetField($object, $key, $value, evalError)'
        : 'objectIndexGetField($object, $key, evalError)';
  }

  visitCallScope(np.CallScope call) {
    String arguments = call.arguments.map((e) => visitForValue(e)).join(', ');
    String getter = lookupGetter(call.name);
    return 'safeFunctionCall($getter(scope), "${call.name}", evalError)($arguments)';
  }

  visitCallFunction(np.CallFunction call) {
    String function = visitForValue(call.function);
    String arguments = call.arguments.map((e) => visitForValue(e)).join(', ');
    return 'safeFunctionCall($function, "${call.function}", evalError)($arguments)';
  }

  visitCallMember(np.CallMember call) {
    String object = visitForValue(call.object);
    String arguments = call.arguments.map((e) => visitForValue(e)).join(', ');
    String getter = lookupGetter(call.name);
    return 'safeFunctionCall($getter($object), "${call.name}", evalError)($arguments)';
  }

  visitBinary(np.Binary binary) {
    String operation = binary.operation;
    bool logical = (operation == '||') || (operation == '&&');
    String left = visitForValue(binary.left, toBool: logical);
    String right = visitForValue(binary.right, toBool: logical);
    if (operation == '+') {
      return 'autoConvertAdd($left, $right)';
    } else {
      return '($left $operation $right)';
    }
  }

  visitPrefix(np.Prefix prefix) {
    String operation = prefix.operation;
    bool logical = (operation == '!');
    String expression = visitForValue(prefix.expression, toBool: logical);
    return '$operation$expression';
  }

  visitLiteral(np.Literal literal) {
    return '$literal';
  }

  visitLiteralString(np.LiteralString literal) {
    return 'r$literal';
  }

  visitLiteralArray(np.LiteralArray literal) {
    if (literal.elements.isEmpty) return '[]';
    StringBuffer buffer = new StringBuffer();
    for (int i = 0; i < literal.elements.length; i++) {
      if (i != 0) buffer.write(', ');
      buffer.write(visitForValue(literal.elements[i]));
    }
    return "[ $buffer ]";
  }

  visitLiteralObject(np.LiteralObject literal) {
    if (literal.keys.isEmpty) return '{}';
    StringBuffer buffer = new StringBuffer();
    List<String> keys = literal.keys;
    for (int i = 0; i < keys.length; i++) {
      if (i != 0) buffer.write(', ');
      buffer.write("'${keys[i]}': ");
      buffer.write(visitForValue(literal.values[i]));
    }
    return "{ $buffer }";
  }
}



Code VALUE_CODE = new Code("value");

typedef CodeAssign(Code c);

class Code implements ParserAST, Expression {
  String id;
  String _exp;
  String simpleGetter;
  CodeAssign _assign;

  Code(this._exp, [this._assign, this.simpleGetter]) {
    id = _exp == null ? simpleGetter : _exp;
    if (id == null) {
        throw 'id is null';
    }
  }

  String get exp {
    if (_exp == null) {
      throw "Can not be used in an expression: $id";
    }
    return _exp;
  }

  get assignable => _assign != null;

  // methods from Expression
  Expression fieldHolder;
  String fieldName;
  bool get isFieldAccess => null;
  void set exp(String s) => throw new UnimplementedError();
  ParsedGetter get eval => throw new UnimplementedError();
  ParsedSetter get assign => throw new UnimplementedError();
  List get parts => throw new UnimplementedError();
  set parts(List p) => throw new UnimplementedError();
  bind(context, [localsWrapper]) => throw new UnimplementedError();

  Source toSource(SourceBuilder _) {
    return _('new Expression', _.parens(
      _('(scope)', _.body(
          'return $exp;'
      )),
      assignable ? _('(scope, value)', _.body(
        'return ${_assign(VALUE_CODE).exp};'
      )) : 'null'
    ));
  }
}

class ThrowCode extends Code {
  ThrowCode(code): super('throw $code');
  Source toSource(SourceBuilder _) {
    return _('new Expression', _.parens(
        _('(scope)', _.body()..source.addAll(exp.split('\n'))),
        assignable ? _('(scope, value)', _.body()) : 'null'
    ));
  }
}

class MultipleStatementCode extends Code {
  MultipleStatementCode(code): super(code);

  Source toSource(SourceBuilder _) {
    return _('new Expression', _.parens(
        _('(scope)', _.body()..source.addAll(exp.split('\n'))),
        assignable ? _('(scope, value)', _.body()) : 'null'
    ));
  }
}

escape(String s) => s.replaceAll('\'', '\\\'').replaceAll(r'$', r'\$');

class GetterSetterGenerator {
  static RegExp LAST_PATH_PART = new RegExp(r'(.*)\.(.*)');
  static RegExp NON_WORDS = new RegExp(r'\W');


  String functions = "// GETTER AND SETTER FUNCTIONS\n\n";
  var _keyToGetterFnName = {};
  var _keyToSetterFnName = {};
  var nextUid = 0;

  _flatten(key) => key.replaceAll(NON_WORDS, '_');

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

    var fnName = "_${_flatten(key)}";

    var keys = key.split('.');
    var lines = [
        "$fnName(s) { // for $key"];
    _(line) => lines.add('  $line');
    for(var i = 0; i < keys.length; i++) {
      var k = keys[i];
      var sk = isReserved(k) ? "null" : "s.$k";
      if (i == 0) {
        _('if (s != null ) s = s is Map ? s["${escape(k)}"] : $sk;');
      } else {
        _('if (s != null ) s = s is Map ? s["${escape(k)}"] : $sk;');
      }
    }
    _('return s;');
    lines.add('}\n\n');

    functions += lines.join('\n');

    _keyToGetterFnName[key] = fnName;
    return fnName;
  }

  setter(String key) {
    if (_keyToSetterFnName.containsKey(key)) {
      return _keyToSetterFnName[key];
    }

    var fnName = "_set_${_flatten(key)}";

    var lines = [
        "$fnName(s, v) { // for $key"];
    _(line) => lines.add('  $line');
    var keys = key.split('.');
    _(keys.length == 1 ? 'var n = s;' : 'var n;');
    var k = keys[0];
    var sk = isReserved(k) ? "null" : "s.$k";
    var nk = isReserved(k) ? "null" : "n.$k";
    if (keys.length > 1) {
      // locals
      _('n = s is Map ? s["${escape(k)}"] : $sk;');
      _('if (n == null) n = s is Map ? (s["${escape(k)}"] = {}) : ($sk = {});');
    }
    for(var i = 1; i < keys.length - 1; i++) {
      k = keys[i];
      sk = isReserved(k) ? "null" : "s.$k";
      nk = isReserved(k) ? "null" : "n.$k";
      // middle
      _('s = n; n = n is Map ? n["${escape(k)}"] : $nk;');
      _('if (n == null) n = s is Map ? (s["${escape(k)}"] = {}) : (${isReserved(k) ? "null" : "$sk = {}"});');
    }
    k = keys[keys.length - 1];
    sk = isReserved(k) ? "null" : "s.$k";
    nk = isReserved(k) ? "null" : "n.$k";
    _('if (n is Map) n["${escape(k)}"] = v; else ${isReserved(k) ? "null" : "$nk = v"};');
    // finish
    _('return v;');
    lines.add('}\n\n');

    functions += lines.join('\n');

    _keyToSetterFnName[key] = fnName;
    return fnName;
  }
}

class DartCodeGen implements ParserBackend {
  static Code ZERO = new Code("0");

  GetterSetterGenerator _getterGen;

  DartCodeGen(this._getterGen);

  setter(String path) => throw new UnimplementedError();
  getter(String path) => throw new UnimplementedError();

  // Returns the Dart code for a particular operator.
  _op(fn) => fn == "undefined" ? "null" : fn;

  Code ternaryFn(Code cond, Code trueBranch, Code falseBranch) =>
    new Code("toBool(${cond.exp}) ? ${trueBranch.exp} : ${falseBranch.exp}");

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
    left._assign(right);

  Code multipleStatements(List<Code >statements) {
    var code = "var ret, last;\n";
    code += statements.map((Code s) =>
        "last = ${s.exp};\nif (last != null) { ret = last; }\n").join('\n');
    code += "return ret;\n";
    return new MultipleStatementCode(code);
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
      return new Code("$setterFnName(${object.exp}, ${right.exp})");
    };
    return new Code("$getterFnName/*field:$field*/(${object.exp})", assign);
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
      return new Code("${setterFnName}(scope, ${right.exp})", null, setterFnName);
    };

    return new Code("$getterFnName(scope)", assign, getterFnName);
  }

  String _value(v) =>
      v is String ? "r\'${escape(v)}\'" : "$v";

  Code value(v) => new Code(_value(v));

  Code zero() => ZERO;

  Code filter(String filterName,
              Code leftHandSide,
              List<Code> parameters,
              Function evalError) {
    return new Code(
        'filters(\'${filterName}\')(${
            ([leftHandSide]..addAll(parameters))
              .map((Code p) => p.exp).join(', ')})');
  }
}

