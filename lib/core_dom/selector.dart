part of angular.core.dom_internal;

/**
 * DirectiveSelector is a function which given a node it will return a
 * list of [DirectiveRef]s which are triggered by this node.
 *
 * DirectiveSelector is used by the [Compiler] during the template walking
 * to extract the [DirectiveRef]s.
 *
 * DirectiveSelector can be created using the [directiveSelectorFactory]
 * method.
 *
 * The DirectiveSelector supports CSS selectors which do not cross
 * element boundaries only. The selectors can have any mix of element-name,
 * class-names and attribute-names.
 *
 * Examples:
 *
 * <pre>
 *   element
 *   .class
 *   [attribute]
 *   [attribute=value]
 *   element[attribute1][attribute2=value]
 *   :contains(/abc/)
 * </pre>
 *
 *
 */
class _Directive {
  final Type type;
  final AbstractNgAnnotation annotation;

  _Directive(this.type, this.annotation);

  toString() => annotation.selector;
}


class _ContainsSelector {
  final AbstractNgAnnotation annotation;
  final RegExp regexp;

  _ContainsSelector(this.annotation, String regexp)
      : regexp = new RegExp(regexp);
}

var _SELECTOR_REGEXP = new RegExp(r'^(?:([-\w]+)|(?:\.([-\w]+))|'
    r'(?:\[([-\w*]+)(?:=([^\]]*))?\]))');
var _COMMENT_COMPONENT_REGEXP = new RegExp(r'^\[([-\w]+)(?:\=(.*))?\]$');
var _CONTAINS_REGEXP = new RegExp(r'^:contains\(\/(.+)\/\)$'); //
var _ATTR_CONTAINS_REGEXP = new RegExp(r'^\[\*=\/(.+)\/\]$'); //

class _SelectorPart {
  final String element;
  final String className;
  final String attrName;
  final String attrValue;

  const _SelectorPart.fromElement(this.element)
      : className = null, attrName = null, attrValue = null;

  const _SelectorPart.fromClass(this.className)
      : element = null, attrName = null, attrValue = null;

  const _SelectorPart.fromAttribute(this.attrName, this.attrValue)
      : element = null, className = null;

  toString() =>
    element == null
      ? (className == null
         ? (attrValue == '' ? '[$attrName]' : '[$attrName=$attrValue]')
         : '.$className')
      : element;
}

_addRefs(ElementBinderBuilder builder, List<_Directive> directives, dom.Node node,
         [String attrValue]) {
  directives.forEach((directive) {
    builder.addDirective(new DirectiveRef(node, directive.type, directive.annotation, attrValue));
  });
}

class _ElementSelector {
  final String name;

  var elementMap = <String, List<_Directive>>{};
  var elementPartialMap = <String, _ElementSelector>{};

  var classMap = <String, List<_Directive>>{};
  var classPartialMap = <String, _ElementSelector>{};

  var attrValueMap = <String, Map<String, List<_Directive>>>{};
  var attrValuePartialMap = <String, Map<String, _ElementSelector>>{};

  _ElementSelector(this.name);

  addDirective(List<_SelectorPart> selectorParts, _Directive directive) {
    var selectorPart = selectorParts.removeAt(0);
    var terminal = selectorParts.isEmpty;
    var name;
    if ((name = selectorPart.element) != null) {
      if (terminal) {
        elementMap.putIfAbsent(name, () => []).add(directive);
      } else {
        elementPartialMap
            .putIfAbsent(name, () => new _ElementSelector(name))
            .addDirective(selectorParts, directive);
      }
    } else if ((name = selectorPart.className) != null) {
      if (terminal) {
        classMap
            .putIfAbsent(name, () => [])
            .add(directive);
      } else {
        classPartialMap
            .putIfAbsent(name, () => new _ElementSelector(name))
            .addDirective(selectorParts, directive);
      }
    } else if ((name = selectorPart.attrName) != null) {
      if (terminal) {
        attrValueMap
            .putIfAbsent(name, () => <String, List<_Directive>>{})
            .putIfAbsent(selectorPart.attrValue, () => [])
            .add(directive);
      } else {
        attrValuePartialMap
            .putIfAbsent(name, () => <String, _ElementSelector>{})
            .putIfAbsent(selectorPart.attrValue, () =>
                new _ElementSelector(name))
            .addDirective(selectorParts, directive);
      }
    } else {
      throw "Unknown selector part '$selectorPart'.";
    }
  }



  List<_ElementSelector> selectNode(ElementBinderBuilder builder,
                                    List<_ElementSelector> partialSelection,
                                    dom.Node node, String nodeName) {
    if (elementMap.containsKey(nodeName)) {
      _addRefs(builder, elementMap[nodeName], node);
    }
    if (elementPartialMap.containsKey(nodeName)) {
      if (partialSelection == null) {
        partialSelection = new List<_ElementSelector>();
      }
      partialSelection.add(elementPartialMap[nodeName]);
    }
    return partialSelection;
  }

  List<_ElementSelector> selectClass(ElementBinderBuilder builder,
                                     List<_ElementSelector> partialSelection,
                                     dom.Node node, String className) {
    if (classMap.containsKey(className)) {
      _addRefs(builder, classMap[className], node);
    }
    if (classPartialMap.containsKey(className)) {
      if (partialSelection == null) {
        partialSelection = new List<_ElementSelector>();
      }
      partialSelection.add(classPartialMap[className]);
    }
    return partialSelection;
  }

  List<_ElementSelector> selectAttr(ElementBinderBuilder builder,
                                    List<_ElementSelector> partialSelection,
                                    dom.Node node, String attrName,
                                    String attrValue) {

    String matchingKey = _matchingKey(attrValueMap.keys, attrName);

    if (matchingKey != null) {
      Map<String, List<_Directive>> valuesMap = attrValueMap[matchingKey];
      if (valuesMap.containsKey('')) {
        _addRefs(builder, valuesMap[''], node, attrValue);
      }
      if (attrValue != '' && valuesMap.containsKey(attrValue)) {
        _addRefs(builder, valuesMap[attrValue], node, attrValue);
      }
    }
    if (attrValuePartialMap.containsKey(attrName)) {
      Map<String, _ElementSelector> valuesPartialMap =
          attrValuePartialMap[attrName];
      if (valuesPartialMap.containsKey('')) {
        if (partialSelection == null) {
          partialSelection = new List<_ElementSelector>();
        }
        partialSelection.add(valuesPartialMap['']);
      }
      if (attrValue != '' && valuesPartialMap.containsKey(attrValue)) {
        if (partialSelection == null) {
            partialSelection = new List<_ElementSelector>();
        }
        partialSelection.add(valuesPartialMap[attrValue]);
      }
    }
    return partialSelection;
  }

  // A global cache for the _matchingKey RegExps.  The size is bounded by
  // the number of attribute directive selectors used in the application.
  static var _matchingKeyCache = <String, RegExp>{};

  String _matchingKey(Iterable<String> keys, String attrName) =>
      keys.firstWhere((key) =>
          _matchingKeyCache.putIfAbsent(key,
                  () => new RegExp('^${key.replaceAll('*', r'[\w\-]+')}\$'))
              .hasMatch(attrName), orElse: () => null);

  toString() => 'ElementSelector($name)';
}

List<_SelectorPart> _splitCss(String selector, Type type) {
  var parts = <_SelectorPart>[];
  var remainder = selector;
  var match;
  while (!remainder.isEmpty) {
    if ((match = _SELECTOR_REGEXP.firstMatch(remainder)) != null) {
      if (match[1] != null) {
        parts.add(new _SelectorPart.fromElement(match[1].toLowerCase()));
      } else if (match[2] != null) {
        parts.add(new _SelectorPart.fromClass(match[2].toLowerCase()));
      } else if (match[3] != null) {
        var attrValue = match[4] == null ? '' : match[4].toLowerCase();
        parts.add(new _SelectorPart.fromAttribute(match[3].toLowerCase(),
                                                  attrValue));
      } else {
        throw "Missmatched RegExp $_SELECTOR_REGEXP on $remainder";
      }
    } else {
      throw "Unknown selector format '$selector' for $type.";
    }
    remainder = remainder.substring(match.end);
  }
  return parts;
}


class DirectiveSelector {
  ElementBinderFactory _binderFactory;
  DirectiveMap _directives;
  var elementSelector;
  var attrSelector;
  var textSelector;

  DirectiveSelector(this._directives, this._binderFactory) {
    elementSelector = new _ElementSelector('');
    attrSelector = <_ContainsSelector>[];
    textSelector = <_ContainsSelector>[];
    _directives.forEach((AbstractNgAnnotation annotation, Type type) {
      var match;
      var selector = annotation.selector;
      List<_SelectorPart> selectorParts;
      if (selector == null) {
        throw new ArgumentError('Missing selector annotation for $type');
      }

      if ((match = _CONTAINS_REGEXP.firstMatch(selector)) != null) {
        textSelector.add(new _ContainsSelector(annotation, match.group(1)));
      } else if ((match = _ATTR_CONTAINS_REGEXP.firstMatch(selector)) != null) {
        attrSelector.add(new _ContainsSelector(annotation, match[1]));
      } else if ((selectorParts = _splitCss(selector, type)) != null){
        elementSelector.addDirective(selectorParts,
        new _Directive(type, annotation));
      } else {
        throw new ArgumentError('Unsupported Selector: $selector');
      }
    });
  }

  ElementBinder matchElement(dom.Node node) {
    assert(node is dom.Element);

    ElementBinderBuilder builder = _binderFactory.builder();
    List<_ElementSelector> partialSelection;
    var classes = <String, bool>{};
    Map<String, String> attrs = {};

    dom.Element element = node;
    String nodeName = element.tagName.toLowerCase();

    // Set default attribute
    if (nodeName == 'input' && !element.attributes.containsKey('type')) {
      element.attributes['type'] = 'text';
    }

    // Select node
    partialSelection = elementSelector.selectNode(builder,
    partialSelection, element, nodeName);

    // Select .name
    if ((element.classes) != null) {
      for (var name in element.classes) {
        classes[name] = true;
        partialSelection = elementSelector.selectClass(builder,
        partialSelection, element, name);
      }
    }

    // Select [attributes]
    element.attributes.forEach((attrName, value) {

      if (attrName.startsWith("on-")) {
        builder.onEvents[attrName] = value;
      }

      if (attrName.startsWith("bind-")) {
        builder.bindAttrs[attrName] = value;
      }

      attrs[attrName] = value;
      for (var k = 0; k < attrSelector.length; k++) {
        _ContainsSelector selectorRegExp = attrSelector[k];
        if (selectorRegExp.regexp.hasMatch(value)) {
          // this directive is matched on any attribute name, and so
          // we need to pass the name to the directive by prefixing it to
          // the value. Yes it is a bit of a hack.
          _directives[selectorRegExp.annotation].forEach((type) {
            builder.addDirective(new DirectiveRef(
                node, type, selectorRegExp.annotation, '$attrName=$value'));
          });
        }
      }

      partialSelection = elementSelector.selectAttr(builder,
      partialSelection, node, attrName, value);
    });

    while (partialSelection != null) {
      List<_ElementSelector> elementSelectors = partialSelection;
      partialSelection = null;
      elementSelectors.forEach((_ElementSelector elementSelector) {
        classes.forEach((className, _) {
          partialSelection = elementSelector.selectClass(builder,
          partialSelection, node, className);
        });
        attrs.forEach((attrName, value) {
          partialSelection = elementSelector.selectAttr(builder,
          partialSelection, node, attrName, value);
        });
      });
    }
    return builder.binder;
  }

  ElementBinder matchText(dom.Node node) {
    ElementBinderBuilder builder = _binderFactory.builder();

    var value = node.nodeValue;
    for (var k = 0; k < textSelector.length; k++) {
      var selectorRegExp = textSelector[k];
      if (selectorRegExp.regexp.hasMatch(value)) {
        _directives[selectorRegExp.annotation].forEach((type) {
          builder.addDirective(new DirectiveRef(node, type,
          selectorRegExp.annotation, value));
        });
      }
    }
    return builder.binder;
  }

  ElementBinder matchComment(dom.Node node) {
    return _binderFactory.builder().binder;
  }
}
/**
 * Factory for creating a [DirectiveSelector].
 */
@NgInjectableService()
class DirectiveSelectorFactory {
  ElementBinderFactory _binderFactory;

  DirectiveSelectorFactory(this._binderFactory);

  DirectiveSelector selector(DirectiveMap directives) {
    return new DirectiveSelector(directives, _binderFactory);
  }
}
