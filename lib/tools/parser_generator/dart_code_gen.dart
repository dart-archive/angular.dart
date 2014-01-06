library dart_code_gen;

import 'package:angular/tools/reserved_dart_keywords.dart';
import 'package:angular/core/parser/new_syntax.dart';

escape(String s) =>
    s.replaceAll('\"', '\\\"')
     .replaceAll(r'$', r'\$')
     .replaceAll('\n', '\\n');

class DartCodeGen extends Visitor {
  static const int STATE_EVAL = 0;
  static const int STATE_EVAL_HOLDER = 1;
  static const int STATE_ASSIGN = 2;
  int state = STATE_EVAL;

  static Map<String, String> getters = new Map<String, String>();
  static Map<String, String> getterNames = new Map<String, String>();

  static Map<String, String> holders = new Map<String, String>();
  static Map<String, String> holderNames = new Map<String, String>();

  static Map<String, String> setters = new Map<String, String>();
  static Map<String, String> setterNames = new Map<String, String>();

  static String generateForExpression(Expression expression, bool assign) {
    DartCodeGen visitor = new DartCodeGen();
    return assign
        ? visitor.assign(expression)('value')
        : visitor.evaluate(expression);
  }

  bool get isEvaluating => state == STATE_EVAL;
  bool get isEvaluatingHolder => state == STATE_EVAL_HOLDER;
  bool get isAssigning => state == STATE_ASSIGN;

  String computeGetterName(String key) {
    String result = getterNames[key];
    if (result != null) return result;
    return (getterNames[key] = '_$key');
  }

  String computeHolderName(String key) {
    String result = holderNames[key];
    if (result != null) return result;
    return (holderNames[key] = '_x\$$key');
  }

  String computeSetterName(String key) {
    String result = setterNames[key];
    if (result != null) return result;
    return (setterNames[key] = '_set\$$key');
  }

  String lookupGetter(String key) {
    String getterName = computeGetterName(key);
    if (getters.containsKey(key)) return getterName;
    getters[key] = isReserved(key)
        ? getterTemplateForReserved(getterName, key)
        : getterTemplate(getterName, key);
    return getterName;
  }

  String lookupHolder(String key) {
    String holderName = computeHolderName(key);
    if (holders.containsKey(key)) return holderName;
    holders[key] = isReserved(key)
        ? holderTemplateForReserved(holderName, key)
        : holderTemplate(holderName, key);
    return holderName;
  }

  String lookupSetter(String key) {
    String setterName = computeSetterName(key);
    if (setters.containsKey(key)) return setterName;
    setters[key] = isReserved(key)
        ? setterTemplateForReserved(setterName, key)
        : setterTemplate(setterName, key);
    return setterName;
  }

  String evaluate(Expression expression, {bool toBool: false}) {
    int old = state;
    state = STATE_EVAL;
    String result = visit(expression);
    if (toBool) result = "toBool($result)";
    state = old;
    return result;
  }

  String evaluateHolder(Expression expression) {
    int old = state;
    state = STATE_EVAL_HOLDER;
    String result = visit(expression);
    state = old;
    return result;
  }

  Function assign(Assignable target) {
    int old = state;
    state = STATE_ASSIGN;
    Function result = visit(target);
    state = old;
    return result;
  }

  visitChain(Chain chain) {
    StringBuffer buffer = new StringBuffer();
    buffer.writeln("var result, last;");
    for (int i = 0; i < chain.expressions.length; i++) {
      String expression = evaluate(chain.expressions[i]);
      buffer.writeln('last = $expression;');
      buffer.writeln('if (last != null) result = last;');
    }
    buffer.write('return result;');
    return "$buffer";
  }

  visitFilter(Filter filter) {
    List expressions = [ filter.expression ]..addAll(filter.arguments);
    String arguments = expressions.map((e) => evaluate(e)).join(', ');
    String name = escape(filter.name);
    return 'filters("$name")($arguments)';
  }

  visitAssign(Assign expression) {
    String value = evaluate(expression.value);
    return assign(expression.target)(value);
  }

  visitConditional(Conditional conditional) {
    String condition = evaluate(conditional.condition, toBool: true);
    String yes = evaluate(conditional.yes);
    String no = evaluate(conditional.no);
    return "$condition ? $yes : $no";
  }

  visitAccessScope(AccessScope access) {
    if (isAssigning) {
      String setter = lookupSetter(access.name);
      return (value) => '$setter(scope, $value)';
    } else {
      String getter = isEvaluatingHolder
          ? lookupHolder(access.name)
          : lookupGetter(access.name);
      return '$getter(scope)';
    }
  }

  visitAccessMember(AccessMember access) {
    String object = !isEvaluating
        ? evaluateHolder(access.object)
        : evaluate(access.object);
    if (isAssigning) {
      String setter = lookupSetter(access.name);
      return (value) => '$setter($object, $value)';
    } else {
      String getter = isEvaluatingHolder
          ? lookupHolder(access.name)
          : lookupGetter(access.name);
      return '$getter($object)';
    }
  }

  visitAccessKeyed(AccessKeyed access) {
    String object = evaluate(access.object);
    String key = evaluate(access.key);
    return (isAssigning)
        ? (value) => 'objectIndexSetField($object, $key, $value, evalError)'
        : 'objectIndexGetField($object, $key, evalError)';
  }

  visitCallScope(CallScope call) {
    String arguments = call.arguments.map((e) => evaluate(e)).join(', ');
    String getter = lookupGetter(call.name);
    return 'safeFunctionCall($getter(scope), "${call.name}", evalError)($arguments)';
  }

  visitCallFunction(CallFunction call) {
    String function = evaluate(call.function);
    String arguments = call.arguments.map((e) => evaluate(e)).join(', ');
    return 'safeFunctionCall($function, "${call.function}", evalError)($arguments)';
  }

  visitCallMember(CallMember call) {
    String object = evaluate(call.object);
    String arguments = call.arguments.map((e) => evaluate(e)).join(', ');
    String getter = lookupGetter(call.name);
    return 'safeFunctionCall($getter($object), "${call.name}", evalError)($arguments)';
  }

  visitBinary(Binary binary) {
    String operation = binary.operation;
    bool logical = (operation == '||') || (operation == '&&');
    String left = evaluate(binary.left, toBool: logical);
    String right = evaluate(binary.right, toBool: logical);
    if (operation == '+') {
      return 'autoConvertAdd($left, $right)';
    } else {
      return '($left $operation $right)';
    }
  }

  visitPrefix(Prefix prefix) {
    String operation = prefix.operation;
    bool logical = (operation == '!');
    String expression = evaluate(prefix.expression, toBool: logical);
    return '$operation$expression';
  }

  visitLiteral(Literal literal) {
    return '$literal';
  }

  visitLiteralString(LiteralString literal) {
    return 'r$literal';
  }

  visitLiteralArray(LiteralArray literal) {
    if (literal.elements.isEmpty) return '[]';
    StringBuffer buffer = new StringBuffer();
    for (int i = 0; i < literal.elements.length; i++) {
      if (i != 0) buffer.write(', ');
      buffer.write(evaluate(literal.elements[i]));
    }
    return "[ $buffer ]";
  }

  visitLiteralObject(LiteralObject literal) {
    if (literal.keys.isEmpty) return '{}';
    StringBuffer buffer = new StringBuffer();
    List<String> keys = literal.keys;
    for (int i = 0; i < keys.length; i++) {
      if (i != 0) buffer.write(', ');
      buffer.write("'${keys[i]}': ");
      buffer.write(evaluate(literal.values[i]));
    }
    return "{ $buffer }";
  }
}


// ------------------------------------------------------------------
// Templates for generated getters.
// ------------------------------------------------------------------
String getterTemplate(String name, String key) => """
$name(o) {
  if (o == null) return null;
  return (o is Map) ? o["${escape(key)}"] : o.$key;
}
""";

String getterTemplateForReserved(String name, String key) => """
$name(o) {
  if (o == null) return null;
  return (o is Map) ? o["${escape(key)}"] : null;
}
""";


// ------------------------------------------------------------------
// Templates for generated holders (getters for assignment).
// ------------------------------------------------------------------
String holderTemplate(String name, String key) => """
$name(o) {
  if (o == null) return null;
  if (o is Map) {
    var key = "${escape(key)}";
    var result = o[key];
    return (result == null) ? result = o[key] = {} : result;
  } else {
    var result = o.$key;
    return (result == null) ? result = o.$key = {} : result;
  }
}
""";

String holderTemplateForReserved(String name, String key) => """
$name(o) {
  if (o == null) return null;
  if (o is !Map) return {};
  var key = "${escape(key)}";
  var result = o[key];
  return (result == null) ? result = o[key] = {} : result;
}
""";


// ------------------------------------------------------------------
// Templates for generated setters.
// ------------------------------------------------------------------
String setterTemplate(String name, String key) => """
$name(o, v) {
  if (o is Map) o["${escape(key)}"] = v; else o.$key = v;
  return v;
}
""";

String setterTemplateForReserved(String name, String key) => """
$name(o, v) {
  if (o is Map) o["${escape(key)}"] = v;
  return v;
}
""";
