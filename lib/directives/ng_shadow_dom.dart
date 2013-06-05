part of angular;

class NgShadowDomAttrDirective {
  NgShadowDomAttrDirective(BlockList list, dom.Element element) {
    var block = list.newBlock();
    var shadowRoot = element.createShadowRoot();
    for (var i = 0, ii = block.elements.length; i < ii; i++) {
      shadowRoot.append(block.elements[i]);
    }
  }

  attach(Scope scope) {}
}
