part of angular;

@NgDirective(
    selector: '[ng-show]',
    map: const {'ng-show': '=.show'})
class NgShowAttrDirective {
  static String NG_SHOW_CLASS = 'ng-show';

  dom.Node node;

  NgShowAttrDirective(dom.Node this.node);

  set show(value) {
    if (toBool(value)) {
      node.classes.add(NG_SHOW_CLASS);
    } else {
      node.classes.remove(NG_SHOW_CLASS);
    }
  }
}
