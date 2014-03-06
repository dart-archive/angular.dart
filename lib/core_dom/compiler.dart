part of angular.core.dom;

abstract class Compiler implements Function {
  ViewFactory call(List<dom.Node> elements, DirectiveMap directives);
}
