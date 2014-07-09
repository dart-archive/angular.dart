part of angular.core.dom_internal;
class ShadowlessShadowRoot implements dom.ShadowRoot {
  dom.Element _element;
  ShadowlessShadowRoot(this._element);
  _notSupported() { throw new UnsupportedError("Not supported"); }
  dom.Element get activeElement => _notSupported();
  dom.Element get host => _notSupported();
  String get innerHtml => _notSupported();
  void set innerHtml(String value) => _notSupported();
  dom.ShadowRoot get olderShadowRoot => _notSupported();
  bool get _resetStyleInheritance => _notSupported();
  void set _resetStyleInheritance(bool value) => _notSupported();
  List<dom.StyleSheet> get styleSheets => _notSupported();
  dom.Node clone(bool deep) => _notSupported();
  dom.Element elementFromPoint(int x, int y) => _notSupported();
  dom.Element getElementById(String elementId) => _notSupported();
  List<dom.Node> getElementsByClassName(String className) => _notSupported();
  List<dom.Node> getElementsByTagName(String tagName) => _notSupported();
  dom.Selection getSelection() => _notSupported();
  bool get resetStyleInheritance { _notSupported(); }
  void set resetStyleInheritance(bool value) { _notSupported(); }
  bool get applyAuthorStyles { _notSupported(); }
  void set applyAuthorStyles(bool value) { _notSupported(); }
  List<dom.Element> get children => _notSupported();
  void set children(List<dom.Element> value) { _notSupported(); }
  dom.ElementList querySelectorAll(String selectors)  => _notSupported();
  void setInnerHtml(String html, {dom.NodeValidator validator, dom.NodeTreeSanitizer treeSanitizer}) { _notSupported(); }
  void appendText(String text) { _notSupported(); }
  void appendHtml(String text) { _notSupported(); }
  dom.Element query(String relativeSelectors) { _notSupported(); }
  dom.ElementList queryAll(String relativeSelectors) { _notSupported(); }
  dom.Element querySelector(String selectors) => _notSupported();
  List<dom.Node> get nodes => _notSupported();
  void set nodes(Iterable<dom.Node> value) { _notSupported(); }
  void remove() { _notSupported(); }
  dom.Node replaceWith(dom.Node otherNode) { _notSupported(); }
  dom.Node insertAllBefore(Iterable<dom.Node> newNodes, dom.Node refChild) { _notSupported(); }
  void _clearChildren() { _notSupported(); }
  String get baseUri => _notSupported();
  List<dom.Node> get childNodes => _notSupported();
  dom.Node get firstChild => _notSupported();
  dom.Node get lastChild => _notSupported();
  String get _localName => _notSupported();
  String get _namespaceUri => _notSupported();
  dom.Node get nextNode => _notSupported();
  String get nodeName => _notSupported();
  int get nodeType => _notSupported();
  String get nodeValue => _notSupported();
  dom.Document get ownerDocument => _notSupported();
  dom.Element get parent => _notSupported();
  dom.Node get parentNode => _notSupported();
  dom.Node get previousNode => _notSupported();
  String get text => _notSupported();
  void set text(String value) => _notSupported();
  dom.Node append(dom.Node newChild) => _notSupported();
  bool contains(dom.Node other) => _notSupported();
  bool hasChildNodes() => _notSupported();
  dom.Node insertBefore(dom.Node newChild, dom.Node refChild) => _notSupported();
  dom.Node _removeChild(dom.Node oldChild) => _notSupported();
  dom.Node _replaceChild(dom.Node newChild, dom.Node oldChild) => _notSupported();
  dom.Events get on => _notSupported();
  void addEventListener(String type, dom.EventListener listener, [bool useCapture]) => _notSupported();
  bool dispatchEvent(dom.Event event) => _notSupported();
  void removeEventListener(String type, dom.EventListener listener, [bool useCapture]) => _notSupported();
}
