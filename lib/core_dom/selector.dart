part of angular.core.dom_internal;

/**
 * DirectiveSelector is a function which given a node it will return a
 * list of [DirectiveRef]s which are triggered by this node.
 *
 * DirectiveSelector is used by the [Compiler] during the template walking
 * to extract the [DirectiveRef]s.
 *
 * DirectiveSelector can be created using the [DirectiveSelectorFactory].
 *
 * The DirectiveSelector supports CSS selectors which do not cross
 * element boundaries only. The selectors can have any mix of element-name,
 * class-names and attribute-names.
 *
 * Examples:
 *
 *  * element
 *  * .class
 *  * [attribute]
 *  * [attribute=value]
 *  * element[attribute1][attribute2=value]
 *  * :contains(/abc/)
 */
class DirectiveSelector {
  static const _ON_DASH_ = 'on-';
  static const _BIND_PREFIX_ = 'bind-';
  static const _BIND_SUFFIX_ = '<';

  NodeBinderBuilder _nodeBinderBuilder;
  DirectiveMap _directives;
  Interpolate _interpolate;
  _ElementSelector _elementSelector;

  // TODO(misko): remove hard coded and replace with real change event list.
  List<String> nodeChangeEvents = ['change', 'input'];

  DirectiveSelector(this._interpolate, this._nodeBinderBuilder, this._directives) {
    _elementSelector = new _ElementSelector('');
    _directives.forEach((Directive annotation, Type type) {
      var match;
      if (annotation.selector == null) {
        throw new ArgumentError('Missing selector annotation for $type');
      }
      annotation.selector.split(',').forEach((selector) {
        selector = selector.trim();
        if (selector.isNotEmpty) {
          List<_SelectorPart> selectorParts;

          if ((selectorParts = _splitCss(selector, type)) != null){
            _elementSelector.addDirective(selectorParts, type, annotation);
          } else {
            throw new ArgumentError('Unsupported Selector: $selector');
          }
        }
      });
    });
  }

  NodeBinder matchElement(dom.Element element) {
    var directives = <Type, Directive>{};
    var bindings = <String, String>{};
    var onEvents = <String>[];
    var attrs = {};
    var partialSelection = <_ElementSelector>[];
    var classes = new Set<String>();
    var nodeName = element.tagName.toLowerCase();

    // Set default attribute
    if (nodeName == 'input' && !element.attributes.containsKey('type')) {
      element.attributes['type'] = 'text';
    }

    // Select node
    _elementSelector.selectNode(directives, partialSelection, nodeName);

    // Select .name
    if ((element.classes) != null) {
      for (var name in element.classes) {
        classes.add(name);
        _elementSelector.selectClass(directives, partialSelection, name);
      }
    }

    // Select [attributes]
    var attributes = element.attributes;
    var interpolationAttrs = [];
    attributes.forEach((attrName, value) {

      if (attrName.startsWith(_ON_DASH_)) {
        onEvents.add(attrName.substring(_ON_DASH_.length));
      } else if (attrName.startsWith(_BIND_PREFIX_)) {
        attrName = attrName.substring(_BIND_PREFIX_.length);
        bindings[attrName] = value;
        attrs[attrName] = value;
      } else if (attrName.endsWith(_BIND_SUFFIX_)) {
        attrName = attrName.substring(0, attrName.length - _BIND_SUFFIX_.length);
        bindings[attrName] = value;
        attrs[attrName] = value;
      } else {
        String interpolation = _interpolate.call(value, true);
        if (interpolation != null && interpolation.isNotEmpty) {
          interpolationAttrs.add(attrName);
          bindings[attrName] = interpolation;
        } else {
          attrs[attrName] = value;
        }
      }

      _elementSelector.selectAttr(directives, partialSelection, attrName, value);
    });

    // Move interpolations into bindings.
    for(String key in interpolationAttrs) {
      attributes.remove(key);
      attributes[_BIND_PREFIX_ + key] = bindings[key];
    }

    while (partialSelection.isNotEmpty) {
      _ElementSelector elementSelector = partialSelection.removeAt(0);
      for(String className in classes) {
        elementSelector.selectClass(directives, partialSelection, className);
      };
      attrs.forEach((attrName, value) {
        elementSelector.selectAttr(directives, partialSelection, attrName, value);
      });
    }
    return _nodeBinderBuilder.build(
        element, nodeChangeEvents, attrs, bindings, onEvents, directives);
  }

  void matchText(NodeBinder parentNodeBinder, int index, dom.Text textNode) {
    var interpolation = _interpolate.call(textNode.text, true);
    if (interpolation != null) {
      textNode.text = ''; // clear template
      parentNodeBinder.addChildTextInterpolation(index, interpolation);
    }
  }
}

/**
 * Factory for creating a [DirectiveSelector].
 */
@Injectable()
class DirectiveSelectorFactory {
  Interpolate _interpolate;
  NodeBinderBuilder _nodeBinderBuilder;

  DirectiveSelectorFactory(this._interpolate, this._nodeBinderBuilder);

  DirectiveSelector selector(DirectiveMap directives) =>
      new DirectiveSelector(_interpolate, _nodeBinderBuilder, directives);
}

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

class _ElementSelector {
  final String name;

  var elementMap = <String, Map<Type, Directive>>{};
  var elementPartialMap = <String, _ElementSelector>{};

  var classMap = <String, Map<Type, Directive>>{};
  var classPartialMap = <String, _ElementSelector>{};

  var attrValueMap = <String, Map<String, Map<Type, Directive>>>{};
  var attrValuePartialMap = <String, Map<String, _ElementSelector>>{};

  _ElementSelector(this.name);

  addDirective(List<_SelectorPart> selectorParts, Type type, Directive annotation) {
    var selectorPart = selectorParts.removeAt(0);
    var terminal = selectorParts.isEmpty;
    var name;
    if ((name = selectorPart.element) != null) {
      if (terminal) {
        elementMap.putIfAbsent(name, () => <Type, Directive>{})[type] = annotation;
      } else {
        elementPartialMap
            .putIfAbsent(name, () => new _ElementSelector(name))
            .addDirective(selectorParts, type, annotation);
      }
    } else if ((name = selectorPart.className) != null) {
      if (terminal) {
        classMap.putIfAbsent(name, () => <Type, Directive>{})[type] = annotation;
      } else {
        classPartialMap
            .putIfAbsent(name, () => new _ElementSelector(name))
            .addDirective(selectorParts, type, annotation);
      }
    } else if ((name = selectorPart.attrName) != null) {
      if (terminal) {
        attrValueMap
            .putIfAbsent(name, () => <String, Map<Type, Directive>>{})
            .putIfAbsent(selectorPart.attrValue, () => <Type, Directive>{})
            [type] = annotation;
      } else {
        attrValuePartialMap
            .putIfAbsent(name, () => <String, _ElementSelector>{})
            .putIfAbsent(selectorPart.attrValue, () => new _ElementSelector(name))
            .addDirective(selectorParts, type, annotation);
      }
    } else {
      throw "Unknown selector part '$selectorPart'.";
    }
  }



  selectNode(Map<Type, Directive> directives,
             List<_ElementSelector> partialSelection,
             String nodeName) {
    if (elementMap.containsKey(nodeName)) {
      directives.addAll(elementMap[nodeName]);
    }
    if (elementPartialMap.containsKey(nodeName)) {
      partialSelection.add(elementPartialMap[nodeName]);
    }
  }

  selectClass(Map<Type, Directive> directives,
              List<_ElementSelector> partialSelection,
              String className) {
    if (classMap.containsKey(className)) {
      directives.addAll(classMap[className]);
    }
    if (classPartialMap.containsKey(className)) {
      partialSelection.add(classPartialMap[className]);
    }
  }

  selectAttr(Map<Type, Directive> directives,
             List<_ElementSelector> partialSelection,
             String attrName,
             String attrValue) {

    Map<String, Map<Type, Directive>> valuesMap = attrValueMap[attrName];
    if (valuesMap != null) {
      var directiveMap = valuesMap[''];
      if (directiveMap != null) directives.addAll(directiveMap);
      if (attrValue != '') {
        var directiveMap = valuesMap[attrValue];
        if (directiveMap != null) directives.addAll(directiveMap);
      }
    }
    Map<String, _ElementSelector> valuesPartialMap = attrValuePartialMap[attrName];
    if (valuesPartialMap != null) {
      var selector = valuesPartialMap[''];
      if (selector != null) partialSelection.add(selector);
      if (attrValue != '') {
        var selector = valuesPartialMap[attrValue];
        if (selector != null) partialSelection.add(selector);
      }
    }
  }

  toString() => 'ElementSelector($name)';
}

var _SELECTOR_REGEXP = new RegExp(
    r'^(?:([-\w]+)|(?:\.([-\w]+))|(?:\[([-\w*]+)(?:=([^\]]*))?\]))');

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
