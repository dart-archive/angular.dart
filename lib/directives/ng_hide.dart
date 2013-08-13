part of angular;


@NgDirective(
    selector: '[ng-hide]',
    map: const {'ng-hide': '=.hide'} )
class NgHideAttrDirective {
  static String NG_HIDE_CLASS = 'ng-hide';

  dom.Node node;

  NgHideAttrDirective(dom.Node this.node);

  set hide(value) {
    if (toBool(value)) {
      node.classes.add(NG_HIDE_CLASS);
    } else {
      node.classes.remove(NG_HIDE_CLASS);
    }
  }
}
