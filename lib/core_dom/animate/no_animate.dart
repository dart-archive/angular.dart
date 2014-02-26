part of angular.core.dom;

/**
 * The [NoAnimate] service provides a NoOp implementation of [NgAnimate]. All
 * operations are immediately executed and a [NoOpAnimation] is returned.
 */
class NoAnimate implements NgAnimate {
  Animation addClass(dom.Element element, String cssClass) {
    element.classes.add(cssClass);
    return new NoOpAnimation();
  }

  Animation removeClass(dom.Element element, String cssClass) {
    element.classes.remove(cssClass);
    return new NoOpAnimation();
  }

  Animation show(dom.Element element, String cssClass) {
    element.classes.remove(cssClass);
    return new NoOpAnimation();
  }

  Animation hide(dom.Element element, String cssClass) {
    element.classes.add(cssClass);
    return new NoOpAnimation();
  }

  Animation insert(Iterable<dom.Node> nodes, dom.Node parent,
                         { dom.Node insertBefore }) {
    util.domInsert(nodes, parent, insertBefore: insertBefore);
    return new NoOpAnimation();
  }

  Animation remove(Iterable<dom.Node> nodes) {
    util.domRemove(nodes.toList(growable: false));
    return new NoOpAnimation();
  }

  Animation move(Iterable<dom.Node> nodes, dom.Node parent,
                       { dom.Node insertBefore }) {
    util.domMove(nodes, parent, insertBefore: insertBefore);
    return new NoOpAnimation();
  }
}
