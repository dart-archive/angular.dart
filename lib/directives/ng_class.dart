part of angular;


class NgClassAttrDirective {
  NgClassAttrDirective(dom.Node node, NodeAttrs attrs, Scope scope) {
    scope.$watch(attrs[this], (current, previous, __) {
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
