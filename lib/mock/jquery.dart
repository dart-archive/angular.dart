part of angular.mock;

// TODO(deboer): This belongs is a seperate unit testing package.

es(String html) {
  var div = new DivElement();
  div.setInnerHtml(html, treeSanitizer: new NullTreeSanitizer());
  return div.nodes;
}

e(String html) => es(html).first;



$(selector) {
  return new JQuery(selector);
}

// TODO(deboer): This class is not used in tests.
class GetterSetter {
  Getter getter(String key) => null;
  Setter setter(String key) => null;
}
var getterSetter = new GetterSetter();

class JQuery extends DelegatingList<Node> {
  JQuery([selector]) : super([]) {
    if (selector == null) {
      // do nothing;
    } else if (selector is String) {
      addAll(es(selector));
    } else if (selector is List) {
      addAll(selector);
    } else if (selector is Node) {
      add(selector);
    } else {
      throw selector;
    }
  }

  _toHtml(node, [bool outer = false]) {
    if (node is Comment) {
      return '<!--${node.text}-->';
    } else if (node is DocumentFragment) {
      var acc = '';
      node.childNodes.forEach((n) { acc += _toHtml(n, true); });
      return acc;
    } else if (node is Element) {
      // Remove all the "ng-binding" internal classes
      node = node.clone(true) as Element;
      node.classes.remove('ng-binding');
      node.querySelectorAll(".ng-binding").forEach((Element e) {
        e.classes.remove('ng-binding');
      });
      var htmlString = outer ? node.outerHtml : node.innerHtml;
      // Strip out empty class attributes.  This seems like a Dart bug...
      return htmlString.replaceAll(' class=""', '');
    } else {
      throw "JQuery._toHtml not implemented for node type [${node.nodeType}]";
    }
  }

  _renderedText(n, [bool notShadow = false]) {
    if (n is List) {
      return n.map((nn) => _renderedText(nn)).join("");
    }

    if (n is Comment) return '';

    if (!notShadow && n is Element && n.shadowRoot != null) {
      var shadowText = n.shadowRoot.text;
      var domText = _renderedText(n, true);
      return shadowText.replaceFirst("SHADOW-CONTENT", domText);
    }

    if (n.nodes == null || n.nodes.length == 0) return n.text;

    return n.nodes.map((cn) => _renderedText(cn)).join("");
  }

  accessor(Function getter, Function setter, [value, single=false]) {
    // TODO(dart): ?value does not work, since value was passed. :-(
    var setterMode = value != null;
    var result = setterMode ? this : '';
    forEach((node) {
      if (setterMode) {
        setter(node, value);
      } else {
        result = single ? getter(node) : '$result${getter(node)}';
      }
    });
    return result;
  }

  html([String html]) => accessor(
          (n) => _toHtml(n),
          (n, v) => n.setInnerHtml(v, treeSanitizer: new NullTreeSanitizer()),
          html);
  val([String text]) => accessor((n) => n.value, (n, v) => n.value = v);
  text([String text]) => accessor((n) => n.text, (n, v) => n.text = v, text);
  contents() => fold(new JQuery(), (jq, node) => jq..addAll(node.nodes));
  toString() => fold('', (html, node) => '$html${_toHtml(node, true)}');
  eq(num childIndex) => $(this[childIndex]);
  remove(_) => forEach((n) => n.remove());
  attr([String name, String value]) => accessor(
          (n) => n.attributes[name],
          (n, v) => n.attributes[name] = v,
          value,
          true);
  prop([String name]) => accessor(
          (n) => getterSetter.getter(name)(n),
          (n, v) => getterSetter.setter(name)(n, v),
          null,
          true);
  textWithShadow() => fold('', (t, n) => '${t}${_renderedText(n)}');
  find(selector) => fold(new JQuery(), (jq, n) => jq..addAll(
      (n is Element ? (n as Element).querySelectorAll(selector) : [])));
  hasClass(String name) => fold(false, (hasClass, node) =>
      hasClass || (node is Element && (node as Element).classes.contains(name)));
  addClass(String name) => forEach((node) =>
      (node is Element) ? (node as Element).classes.add(name) : null);
  removeClass(String name) => forEach((node) =>
      (node is Element) ? (node as Element).classes.remove(name) : null);
  css(String name, [String value]) => accessor(
          (Element n) => n.style.getPropertyValue(name),
          (Element n, v) => n.style.setProperty(name, value), value);
  children() => new JQuery(this[0].childNodes);
  shadowRoot() => new JQuery((this[0] as Element).shadowRoot);
}
