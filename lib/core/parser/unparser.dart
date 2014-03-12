library angular.core.parser.unparser;

import 'package:angular/core/parser/syntax.dart';

class Unparser extends Visitor {
  final StringBuffer buffer;
  Unparser(this.buffer);

  static String unparse(Expression expression) {
    StringBuffer buffer = new StringBuffer();
    Unparser unparser = new Unparser(buffer);
    unparser.visit(expression);
    return "$buffer";
  }

  void write(String string) {
    buffer.write(string);
  }

  void writeArguments(List<Expression> arguments) {
    write('(');
    for (int i = 0; i < arguments.length; i++) {
      if (i != 0) write(',');
      visit(arguments[i]);
    }
    write(')');
  }

  void visitChain(Chain chain) {
    for (int i = 0; i < chain.expressions.length; i++) {
      if (i != 0) write(';');
      visit(chain.expressions[i]);
    }
  }

  void visitFilter(Filter filter) {
    write('(');
    visit(filter.expression);
    write('|${filter.name}');
    for (int i = 0; i < filter.arguments.length; i++) {
      write(' :');
      visit(filter.arguments[i]);
    }
    write(')');
  }

  void visitAssign(Assign assign) {
    visit(assign.target);
    write('=');
    visit(assign.value);
  }

  void visitConditional(Conditional conditional) {
    visit(conditional.condition);
    write('?');
    visit(conditional.yes);
    write(':');
    visit(conditional.no);
  }

  void visitAccessScope(AccessScope access) {
    write(access.name);
  }

  void visitAccessMember(AccessMember access) {
    visit(access.object);
    write('.${access.name}');
  }

  void visitAccessKeyed(AccessKeyed access) {
    visit(access.object);
    write('[');
    visit(access.key);
    write(']');
  }

  void visitCallScope(CallScope call) {
    write(call.name);
    writeArguments(call.arguments);
  }

  void visitCallFunction(CallFunction call) {
    visit(call.function);
    writeArguments(call.arguments);
  }

  void visitCallMember(CallMember call) {
    visit(call.object);
    write('.${call.name}');
    writeArguments(call.arguments);
  }

  void visitPrefix(Prefix prefix) {
    write('(${prefix.operation}');
    visit(prefix.expression);
    write(')');
  }

  void visitBinary(Binary binary) {
    write('(');
    visit(binary.left);
    write(binary.operation);
    visit(binary.right);
    write(')');
  }

  void visitLiteralPrimitive(LiteralPrimitive literal) {
    write("${literal.value}");
  }

  void visitLiteralArray(LiteralArray literal) {
    write('[');
    for (int i = 0; i < literal.elements.length; i++) {
      if (i != 0) write(',');
      visit(literal.elements[i]);
    }
    write(']');
  }

  void visitLiteralObject(LiteralObject literal) {
    write('{');
    List<String> keys = literal.keys;
    for (int i = 0; i < keys.length; i++) {
      if (i != 0) write(',');
      write("'${keys[i]}':");
      visit(literal.values[i]);
    }
    write('}');
  }

  void visitLiteralString(LiteralString literal) {
    String escaped = literal.value.replaceAll("'", "\\'");
    write("'$escaped'");
  }
}
