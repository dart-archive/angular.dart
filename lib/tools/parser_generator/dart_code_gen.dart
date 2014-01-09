library dart_code_gen;

import 'package:angular/tools/reserved_dart_keywords.dart';
import 'package:angular/core/parser/syntax.dart';

escape(String s) => s.replaceAllMapped(new RegExp(r'(\"|\$|\n)'), (m) {
  var char = m[1];
  if (char == '\n') char = 'n';
  return "\\$char";
});

class DartCodeGen {
  final HelperMap getters = new HelperMap('_',
      getterTemplate, getterTemplateForReserved);
  final HelperMap holders = new HelperMap('_ensure\$',
      holderTemplate, holderTemplateForReserved);
  final HelperMap setters = new HelperMap('_set\$',
      setterTemplate, setterTemplateForReserved);

  String generate(Expression expression, bool assign) {
    var v = new DartCodeGenVisitor(getters, holders, setters);
    return assign ? v.assign(expression)('value') : v.evaluate(expression);
  }
}

class DartCodeGenVisitor extends Visitor {
  static const int STATE_EVAL = 0;
  static const int STATE_EVAL_HOLDER = 1;
  static const int STATE_ASSIGN = 2;
  int state = STATE_EVAL;

  final HelperMap getters;
  final HelperMap holders;
  final HelperMap setters;

  DartCodeGenVisitor(this.getters, this.holders, this.setters);

  bool get isEvaluating => state == STATE_EVAL;
  bool get isEvaluatingHolder => state == STATE_EVAL_HOLDER;
  bool get isAssigning => state == STATE_ASSIGN;

  String lookupGetter(String key) => getters.lookup(key);
  String lookupHolder(String key) => holders.lookup(key);
  String lookupSetter(String key) => setters.lookup(key);

  String lookupAccessor(String key) {
    switch (state) {
      case STATE_EVAL: return lookupGetter(key);
      case STATE_EVAL_HOLDER: return lookupHolder(key);
      case STATE_ASSIGN: return lookupSetter(key);
    }
  }

  String toBool(String value)
      => 'toBool($value)';
  String safeCallFunction(String function, String name, String arguments)
      => 'ensureFunction($function, "$name")($arguments)';

  String evaluate(Expression expression, {bool convertToBool: false}) {
    int old = state;
    try {
      state = STATE_EVAL;
      String result = visit(expression);
      if (convertToBool) result = toBool(result);
      return result;
    } finally {
      state = old;
    }
  }

  String evaluateHolder(Expression expression) {
    int old = state;
    try {
      state = STATE_EVAL_HOLDER;
      return visit(expression);
    } finally {
      state = old;
    }
  }

  Function assign(Expression target) {
    int old = state;
    try {
      state = STATE_ASSIGN;
      return visit(target);
    } finally {
      state = old;
    }
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
    String condition = evaluate(conditional.condition, convertToBool: true);
    String yes = evaluate(conditional.yes);
    String no = evaluate(conditional.no);
    return "$condition ? $yes : $no";
  }

  visitAccessScope(AccessScope access) {
    String accessor = lookupAccessor(access.name);
    return isAssigning
        ? (value) => '$accessor(scope, $value)'
        : '$accessor(scope)';
  }

  visitAccessMember(AccessMember access) {
    String object = !isEvaluating
        ? evaluateHolder(access.object)
        : evaluate(access.object);
    String accessor = lookupAccessor(access.name);
    return isAssigning
        ? (value) => '$accessor($object, $value)'
        : '$accessor($object)';
  }

  visitAccessKeyed(AccessKeyed access) {
    String object = evaluate(access.object);
    String key = evaluate(access.key);
    return (isAssigning)
        ? (value) => 'setKeyed($object, $key, $value)'
        : 'getKeyed($object, $key)';
  }

  visitCallScope(CallScope call) {
    String arguments = call.arguments.map((e) => evaluate(e)).join(', ');
    String getter = lookupGetter(call.name);
    return safeCallFunction('$getter(scope)', call.name, arguments);
  }

  visitCallFunction(CallFunction call) {
    String function = evaluate(call.function);
    String arguments = call.arguments.map((e) => evaluate(e)).join(', ');
    return safeCallFunction(function, "${call.function}", arguments);
  }

  visitCallMember(CallMember call) {
    String object = evaluate(call.object);
    String arguments = call.arguments.map((e) => evaluate(e)).join(', ');
    String getter = lookupGetter(call.name);
    return safeCallFunction('$getter($object)', call.name, arguments);
  }

  visitBinary(Binary binary) {
    String operation = binary.operation;
    bool logical = (operation == '||') || (operation == '&&');
    String left = evaluate(binary.left, convertToBool: logical);
    String right = evaluate(binary.right, convertToBool: logical);
    if (operation == '+') {
      return 'autoConvertAdd($left, $right)';
    } else {
      return '($left $operation $right)';
    }
  }

  visitPrefix(Prefix prefix) {
    String operation = prefix.operation;
    bool logical = (operation == '!');
    String expression = evaluate(prefix.expression, convertToBool: logical);
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

class HelperMap {
  final Map<String, String> helpers = new Map<String, String>();
  final Map<String, String> names = new Map<String, String>();

  final String prefix;
  final Function template;
  final Function templateForReserved;

  HelperMap(this.prefix, this.template, this.templateForReserved);

  String lookup(String key) {
    String name = _computeName(key);
    if (helpers.containsKey(key)) return name;
    helpers[key] = isReserved(key)
        ? templateForReserved(name, key)
        : template(name, key);
    return name;
  }

  String _computeName(String key) {
    String result = names[key];
    if (result != null) return result;
    return names[key] = "$prefix$key";
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
