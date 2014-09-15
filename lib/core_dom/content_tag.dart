part of angular.core.dom_internal;

abstract class _ContentStrategy {
  void attach();
  void detach();
  void insert(Iterable<dom.Node> nodes);
}

/**
 * A null implementation of the content tag that is used by Shadow DOM components.
 * The distribution is handled by the browser, so Angular does nothing.
 */
class _ShadowDomContent implements _ContentStrategy {
  void attach(){}
  void detach(){}
  void insert(Iterable<dom.Node> nodes){}
}

/**
 * An implementation of the content tag that is used by transcluding components.
 * It is used when the content tag is not a direct child of another component,
 * and thus does not affect redistribution.
 */
class _RenderedTranscludingContent implements _ContentStrategy {
  final SourceLightDom _sourceLightDom;
  final Content _content;

  static final dom.ScriptElement _beginScriptTemplate =
      new dom.ScriptElement()..type = "ng/content";

  static final dom.ScriptElement _endScriptTemplate =
      new dom.ScriptElement()..type = "ng/content";

  dom.ScriptElement _beginScript;
  dom.ScriptElement _endScript;

  Iterable<dom.Node> _currNodes;

  _RenderedTranscludingContent(this._content, this._sourceLightDom);

  void attach(){
    _replaceContentElementWithScriptTags();
    _sourceLightDom.redistribute();
  }

  void detach(){
    _removeScriptTags();
    _sourceLightDom.redistribute();
  }

  void insert(Iterable<dom.Node> nodes){
    final p = _endScript.parent;
    if (p != null && ! _equalToCurrNodes(nodes)) {
      _currNodes = nodes.toList();
      p.insertAllBefore(nodes, _endScript);
    }
  }

  bool _equalToCurrNodes(Iterable<dom.Node> nodes) =>
      const IterableEquality().equals(_currNodes, nodes);

  void _replaceContentElementWithScriptTags() {
    _beginScript = _beginScriptTemplate.clone(true);
    _endScript = _endScriptTemplate.clone(true);

    final el = _content.element;
    el.parent.insertBefore(_beginScript, el);
    el.parent.insertBefore(_endScript, el);
    el.remove();
  }

  void _removeScriptTags() {
    _removeNodesBetweenScriptTags();
    _beginScript.remove();
    _endScript.remove();
  }

  void _removeNodesBetweenScriptTags() {
    final p = _beginScript.parent;
    for (var next = _beginScript.nextNode;
        next.nodeType != dom.Node.ELEMENT_NODE || next.attributes["ng/content"] != null;
        next = _beginScript.nextNode) {
      p.nodes.remove(next);
    }
  }
}

/**
 * An implementation of the content tag that is used by transcluding components.
 * It is used when the content tag is a direct child of another component,
 * and thus does not get rendered but only affect the distribution of its parent component.
 */
class _IntermediateTranscludingContent implements _ContentStrategy {
  final SourceLightDom _sourceLightDom;
  final DestinationLightDom _destinationLightDom;
  final Content _content;

  _IntermediateTranscludingContent(this._content, this._sourceLightDom, this._destinationLightDom);

  void attach(){
    _sourceLightDom.redistribute();
  }

  void detach(){
    _sourceLightDom.redistribute();
  }

  void insert(Iterable<dom.Node> nodes){
    _content.element.nodes = nodes;
    _destinationLightDom.redistribute();
  }
}

@Decorator(selector: 'content')
class Content implements AttachAware, DetachAware {
  dom.Element element;

  @NgAttr('select')
  String select;

  final SourceLightDom _sourceLightDom;
  final DestinationLightDom _destinationLightDom;
  var _strategy;

  Content(this.element, this._sourceLightDom, this._destinationLightDom, View view) {
    view.addContent(this);
  }

  void attach() => strategy.attach();
  void detach() => strategy.detach();
  void insert(Iterable<dom.Node> nodes) => strategy.insert(nodes);

  _ContentStrategy get strategy {
    if (_strategy == null) _strategy = _createContentStrategy();
    return _strategy;
  }

  _ContentStrategy _createContentStrategy() {
    if (_sourceLightDom == null) {
      return new _ShadowDomContent();
    } else if (_destinationLightDom != null && _destinationLightDom.hasRoot(element)) {
      return new _IntermediateTranscludingContent(this, _sourceLightDom, _destinationLightDom);
    } else {
      return new _RenderedTranscludingContent(this, _sourceLightDom);
    }
  }
}
