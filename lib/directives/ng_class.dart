part of angular;

@NgDirective(
    selector: '[ng-class]',
    map: const {'ng-class': '=.value'})
class NgClassAttrDirective {
  dom.Node node;
  var previousSet = [];

  NgClassAttrDirective(dom.Node this.node);

  set value(current) {
    var currentSet;

    if (current == null) {
      currentSet = [];
    } else {
      currentSet = current.split(' ');
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

    previousSet = currentSet;
  }
}
