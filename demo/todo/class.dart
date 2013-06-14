import 'package:angular/debug.dart';
import 'package:angular/angular.dart';
import 'dart:mirrors';
import 'package:di/di.dart';
import 'dart:html' as dom;


class NgClassAttrDirective {
  String expression;
  dom.Element node;

  NgClassAttrDirective(dom.Node this.node, DirectiveValue value) {
    expression = value.value;
  }

  attach(Scope scope) {
    scope.$watch(expression, (value, previous, __) {
      // TODO(vojta): this is lame; allow array of classes, etc...
      node.classes.remove(previous);
      node.classes.add(value);
    });
  }
}
