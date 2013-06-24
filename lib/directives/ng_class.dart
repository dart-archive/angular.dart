part of angular;


class NgClassAttrDirective {
  String expression;
  dom.Element node;

  NgClassAttrDirective(dom.Node this.node, DirectiveValue value) {
    expression = value.value;
  }

  attach(Scope scope) {
    scope.$watch(expression, (current, previous, __) {
      var previousSet;
      var currentSet;

      if (current == null) {
        currentSet = [];
      } else {
        currentSet = current.split(' ');
      }

      if (previous == null) {
        previousSet = [];
      } else {
        previousSet = previous.split(' ');
      }

      previousSet.forEach((cls) {
        if (!currentSet.contains(cls)) {
          node.classes.remove(cls);
        }
      });

      currentSet.forEach((cls) {
        if (!previousSet.contains(cls)) {
          node.classes.add(cls);
        }
      });
    });
  }
}
