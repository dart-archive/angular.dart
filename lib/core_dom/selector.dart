part of angular.core.dom;

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
 * </pre>
 *
 *
 */
typedef List<DirectiveRef> DirectiveSelector(dom.Node node);

class _Directive {
  final Type type;
  final NgAnnotation annotation;

  _Directive(Type this.type, NgAnnotation this.annotation);

  toString() => annotation.selector;
}


class _ContainsSelector {
  final NgAnnotation annotation;
  final RegExp regexp;

  _ContainsSelector(this.annotation, String regexp) : regexp = new RegExp(regexp);
}

RegExp _SELECTOR_REGEXP = new RegExp(r'^(?:([\w\-]+)|(?:\.([\w\-]+))|(?:\[([\w\-\*]+)(?:=([^\]]*))?\]))');
RegExp _COMMENT_COMPONENT_REGEXP = new RegExp(r'^\[([\w\-]+)(?:\=(.*))?\]$');
RegExp _CONTAINS_REGEXP = new RegExp(r'^:contains\(\/(.+)\/\)$'); //
RegExp _ATTR_CONTAINS_REGEXP = new RegExp(r'^\[\*=\/(.+)\/\]$'); //

class _SelectorPart {
  final String element;
  final String className;
  final String attrName;
  final String attrValue;

  const _SelectorPart.fromElement(String this.element)
      : className = null, attrName = null, attrValue = null;

  const _SelectorPart.fromClass(String this.className)
      : element = null, attrName = null, attrValue = null;


  const _SelectorPart.fromAttribute(String this.attrName, String this.attrValue)
      : element = null, className = null;

  toString() =>
    element == null
      ? (className == null
         ? (attrValue == '' ? '[$attrName]' : '[$attrName=$attrValue]')
         : '.$className')
      : element;
}


class _ElementSelector {
  String name;

  Map<String, _Directive> elementMap = new Map<String, _Directive>();
  Map<String, _ElementSelector> elementPartialMap = new Map<String, _ElementSelector>();

  Map<String, _Directive> classMap = new Map<String, _Directive>();
  Map<String, _ElementSelector> classPartialMap = new Map<String, _ElementSelector>();

  Map<String, Map<String, _Directive>> attrValueMap = new Map<String, Map<String, _Directive>>();
  Map<String, Map<String, _ElementSelector>> attrValuePartialMap = new Map<String, Map<String, _ElementSelector>>();

  _ElementSelector(this.name);

  addDirective(List<_SelectorPart> selectorParts, _Directive directive) {
    var selectorPart = selectorParts.removeAt(0);
    var terminal = selectorParts.isEmpty;
    var name;
    if ((name = selectorPart.element) != null) {
      if (terminal) {
        elementMap[name] = directive;
      } else {
        elementPartialMap
            .putIfAbsent(name, () => new _ElementSelector(name))
            .addDirective(selectorParts, directive);
      }
    } else if ((name = selectorPart.className) != null) {
      if (terminal) {
        classMap[name] = directive;
      } else {
        classPartialMap
            .putIfAbsent(name, () => new _ElementSelector(name))
            .addDirective(selectorParts, directive);
      }
    } else if ((name = selectorPart.attrName) != null) {
      if (terminal) {
        attrValueMap
            .putIfAbsent(name, () => new Map<String, _Directive>())
            [selectorPart.attrValue] = directive;
      } else {
        attrValuePartialMap
            .putIfAbsent(name, () => new Map<String, _ElementSelector>())
            .putIfAbsent(selectorPart.attrValue, () => new _ElementSelector(name))
            .addDirective(selectorParts, directive);
      }
    } else {
      throw "Unknown selector part '$selectorPart'.";
    }
  }

  List<_ElementSelector> selectNode(List<DirectiveRef> refs, List<_ElementSelector> partialSelection,
             dom.Node node, String nodeName) {
    if (elementMap.containsKey(nodeName)) {
      _Directive directive = elementMap[nodeName];
      refs.add(new DirectiveRef(node, directive.type, directive.annotation));
    }
    if (elementPartialMap.containsKey(nodeName)) {
      if (partialSelection == null) partialSelection = new List<_ElementSelector>();
      partialSelection.add(elementPartialMap[nodeName]);
    }
    return partialSelection;
  }

  List<_ElementSelector> selectClass(List<DirectiveRef> refs, List<_ElementSelector> partialSelection,
         dom.Node node, String className) {
    if (classMap.containsKey(className)) {
      var directive = classMap[className];
      refs.add(new DirectiveRef(node, directive.type, directive.annotation));
    }
    if (classPartialMap.containsKey(className)) {
      if (partialSelection == null) partialSelection = new List<_ElementSelector>();
      partialSelection.add(classPartialMap[className]);
    }
    return partialSelection;
  }

  List<_ElementSelector> selectAttr(List<DirectiveRef> refs, List<_ElementSelector> partialSelection,
         dom.Node node, String attrName, String attrValue) {

    String matchingKey = _matchingKey(attrValueMap.keys, attrName);

    if (matchingKey != null) {
      Map<String, _Directive> valuesMap = attrValueMap[matchingKey];
      if (valuesMap.containsKey('')) {
        _Directive directive = valuesMap[''];
        refs.add(new DirectiveRef(node, directive.type, directive.annotation, attrValue));
      }
      if (attrValue != '' && valuesMap.containsKey(attrValue)) {
        _Directive directive = valuesMap[attrValue];
        refs.add(new DirectiveRef(node, directive.type, directive.annotation, attrValue));
      }
    }
    if (attrValuePartialMap.containsKey(attrName)) {
      Map<String, _ElementSelector> valuesPartialMap = attrValuePartialMap[attrName];
      if (valuesPartialMap.containsKey('')) {
        if (partialSelection == null) partialSelection = new List<_ElementSelector>();
        partialSelection.add(valuesPartialMap['']);
      }
      if (attrValue != '' && valuesPartialMap.containsKey(attrValue)) {
        if (partialSelection == null) partialSelection = new List<_ElementSelector>();
        partialSelection.add(valuesPartialMap[attrValue]);
      }
    }
    return partialSelection;
  }

  String _matchingKey(Iterable<String> keys, String attrName) {
    return keys.firstWhere(
        (key) => new RegExp('^${key.replaceAll('*', r'[\w\-]+')}\$').hasMatch(attrName),
        orElse: () => null);
  }

  toString() => 'ElementSelector($name)';
}

List<_SelectorPart> _splitCss(String selector, Type type) {
  List<_SelectorPart> parts = [];
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

/**
 * Factory method for creating a [DirectiveSelector].
 */
DirectiveSelector directiveSelectorFactory(DirectiveMap directives) {

  _ElementSelector elementSelector = new _ElementSelector('');
  List<_ContainsSelector> attrSelector = [];
  List<_ContainsSelector> textSelector = [];
  directives.forEach((NgAnnotation annotation, Type type) {
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
      elementSelector.addDirective(selectorParts, new _Directive(type, annotation));
    } else {
      throw new ArgumentError('Unsupported Selector: $selector');
    }
  });

  return (dom.Node node) {
    List<DirectiveRef> directiveRefs = [];
    List<_ElementSelector> partialSelection = null;
    Map<String, bool> classes = new Map<String, bool>();
    Map<String, String> attrs = new Map<String, String>();

    switch(node.nodeType) {
      case 1: // Element
        dom.Element element = node;
        String nodeName = element.tagName.toLowerCase();
        Map<String, String> attrs = {};

        // Select node
        partialSelection = elementSelector.selectNode(directiveRefs, partialSelection, element, nodeName);

        // Select .name
        if ((element.classes) != null) {
          for(var name in element.classes) {
            classes[name] = true;
            partialSelection = elementSelector.selectClass(directiveRefs, partialSelection, element, name);
          }
        }

        // Select [attributes]
        element.attributes.forEach((attrName, value){
          attrs[attrName] = value;
          for(var k = 0, kk = attrSelector.length; k < kk; k++) {
            _ContainsSelector selectorRegExp = attrSelector[k];
            if (selectorRegExp.regexp.hasMatch(value)) {
              // this directive is matched on any attribute name, and so
              // we need to pass the name to the directive by prefixing it to the
              // value. Yes it is a bit of a hack.
              directives[selectorRegExp.annotation].forEach((type) {
                directiveRefs.add(new DirectiveRef(
                    node, type, selectorRegExp.annotation, '$attrName=$value'));
              });
            }
          }

          partialSelection = elementSelector.selectAttr(directiveRefs, partialSelection, node, attrName, value);
        });

        while(partialSelection != null) {
          List<_ElementSelector> elementSelectors = partialSelection;
          partialSelection = null;
          elementSelectors.forEach((_ElementSelector elementSelector) {
            classes.forEach((className, _) {
              partialSelection = elementSelector.selectClass(directiveRefs, partialSelection, node, className);
            });
            attrs.forEach((attrName, value) {
              partialSelection = elementSelector.selectAttr(directiveRefs, partialSelection, node, attrName, value);
            });
          });
        }
        break;
      case 3: // Text Node
        for(var value = node.nodeValue, k = 0, kk = textSelector.length; k < kk; k++) {
          var selectorRegExp = textSelector[k];

          if (selectorRegExp.regexp.hasMatch(value)) {
            directives[selectorRegExp.annotation].forEach((type) {
              directiveRefs.add(new DirectiveRef(node, type, selectorRegExp.annotation, value));
            });
          }
        }
        break;
      }

      directiveRefs.sort(_priorityComparator);
      return directiveRefs;
    };
}

int _directivePriority(NgAnnotation annotation) {
  if (annotation is NgDirective) {
    return (annotation.children == NgAnnotation.TRANSCLUDE_CHILDREN) ? 2 : 1;
  } else if (annotation is NgComponent) {
    return 0;
  }
  throw "Unexpected Type: ${annotation}.";
}

int _priorityComparator(DirectiveRef a, DirectiveRef b) =>
  _directivePriority(b.annotation) - _directivePriority(a.annotation);
