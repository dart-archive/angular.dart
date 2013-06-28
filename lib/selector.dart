part of angular;

typedef List<DirectiveRef> Selector(dom.Node node);

class SelectorInfo {
  String selector;
  RegExp regexp;

  SelectorInfo(this.selector, regexp) {
    this.regexp = new RegExp(regexp);
  }
}

RegExp _SELECTOR_REGEXP = new RegExp(r'^([\w\-]*)(?:\.([\w\-]*))?(?:\[([\w\-]*)(?:=(.*))?\])?$');
RegExp _COMMENT_COMPONENT_REGEXP = new RegExp(r'^\[([\w\-]+)(?:\=(.*))?\]$');
RegExp _CONTAINS_REGEXP = new RegExp(r'^:contains\(\/(.+)\/\)$'); //
RegExp _ATTR_CONTAINS_REGEXP = new RegExp(r'^\[\*=\/(.+)\/\]$'); //


Selector selectorFactory(List<String> selectors, [String startWith]) {

  Map<String, Map<String, Map<String, String>>> elementMap = {};
  Map<String, Map<String, String>> anyAttrMap = {};
  Map<String, String> anyClassMap = {};
  List<SelectorInfo> attrSelector = [];
  List<SelectorInfo> textSelector = [];

  selectors.forEach((selector) {
    var match;

    if (startWith != null) {
      if (selector.substring(0, startWith.length) == startWith) {
        selector = selector.substring(startWith.length);
      } else {
        throw new ArgumentError('Selector must start with: $startWith was: $selector');
      }
    }

    if ((match = _CONTAINS_REGEXP.firstMatch(selector)) != null) {
      textSelector.add(new SelectorInfo(selector, match.group(1)));
    } else if ((match = _ATTR_CONTAINS_REGEXP.firstMatch(selector)) != null) {
      attrSelector.add(new SelectorInfo(selector, match[1]));
    } else if ((match = _SELECTOR_REGEXP.firstMatch(selector)) != null){
      var elementName = match.group(1);
      var className = match.group(2);
      var attrName = match.group(3);
      var value = match.group(4);

      if (elementName == null) elementName = '';
      if (className == null) className = '';
      if (attrName == null) attrName = '';
      if (value == null) value = '';

      Map<String, Map<String, String>> elementAttrMap;
      Map<String, String> valueMap;

      if (elementName != '' && className == '') {
        elementAttrMap = elementMap.putIfAbsent(elementName, () => {});
        valueMap = elementAttrMap.putIfAbsent(attrName, () => {});
        valueMap[value] = selector;
      } else if (attrName != '' && className == '' && elementName == '') {
        valueMap = anyAttrMap.putIfAbsent(attrName, () => {});
        valueMap[value] = selector;
      } else if (className != '' && elementName == '' && attrName == '') {
        anyClassMap[className] = selector;
      } else {
        throw new ArgumentError('Unsupported Selector: $selector');
      }
    } else {
      throw new ArgumentError('Unsupported Selector: $selector');
    }
  });

  addAttrDirective(List<DirectiveRef> directives, dom.Node element,
                            Map<String, String>valueMap, String name, String value) {
    if (valueMap.containsKey('')) {
      directives.add(new DirectiveRef(element, valueMap[''], name, value));
    }
    if (value != '' && valueMap.containsKey(value)) {
      directives.add(new DirectiveRef(element, valueMap[value], name, value));
    }
  }

  Selector selector = (dom.Node node) {
    List<DirectiveRef> directiveInfos = [];
    dom.CssClassSet classNames;

    switch(node.nodeType) {
      case 1: // Element
        String nodeName = node.tagName;
        Map<String, Map<String, String>> elementAttrMap = elementMap[nodeName.toLowerCase()];

        // Select node
        if (elementAttrMap != null && elementAttrMap.containsKey('')) {
          var valueMap = elementAttrMap[''];
          if (valueMap.containsKey('')) {
            directiveInfos.add(new DirectiveRef(node, valueMap['']));
          }
        }

        // Select .name
        if ((classNames = node.classes) != null) {
          for(var name in classNames) {
            if (anyClassMap.containsKey(name)) {
              directiveInfos.add(new DirectiveRef(node, anyClassMap[name], 'class', name));
            }
          }
        }

        // Select [attributes]
        node.attributes.forEach((attrName, value){
          for(var k = 0, kk = attrSelector.length; k < kk; k++) {
            var selectorRegExp = attrSelector[k];
            if (selectorRegExp.regexp.hasMatch(value)) {
              // this directive is matched on any attribute name, and so
              // we need to pass the name to the directive by prefixing it to the
              // value. Yes it is a bit of a hack.
              directiveInfos.add(new DirectiveRef(
                  node, selectorRegExp.selector, attrName, '$attrName=$value'));
            }
          }

          if (elementAttrMap != null && elementAttrMap.containsKey(attrName)) {
            addAttrDirective(directiveInfos, node, elementAttrMap[attrName], attrName, value);
          }
          if (anyAttrMap.containsKey(attrName)) {
            addAttrDirective(directiveInfos, node, anyAttrMap[attrName], attrName, value);
          }
        });
        break;
      case 3: // Text Node
        for(var value = node.nodeValue, k = 0, kk = textSelector.length; k < kk; k++) {
          var selectorRegExp = textSelector[k];

          if (selectorRegExp.regexp.hasMatch(value)) {
            directiveInfos.add(new DirectiveRef(node, selectorRegExp.selector, '#text', value));
          }
        }
        break;
      }

      return directiveInfos;
    };
  return selector;
}
