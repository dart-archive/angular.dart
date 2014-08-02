library angular.tools.common;

import 'dart:collection';

class DirectiveInfo {
  String selector;
  String template;
  List<String> expressions;
   _AttributeList _expressionAttrs;

  DirectiveInfo([this.selector, List<String> expAttrs, this.expressions]) {
    expressionAttrs = expAttrs;

    if (expressions == null) expressions = <String>[];
  }

  List<String> get expressionAttrs => _expressionAttrs;

  void set expressionAttrs(value) {
    if (value is _AttributeList) {
      _expressionAttrs = value;
    } else if (value == null) {
      _expressionAttrs = new _AttributeList();
    } else {
      assert(value is Iterable);
      _expressionAttrs = new _AttributeList()..addAll(value);
    }
  }
}

const String DIRECTIVE = 'DIRECTIVE';
const String COMPONENT = 'COMPONENT';

class DirectiveMetadata {
  String className;
  String type; // DIRECTIVE/COMPONENT
  String selector;
  String template;
  Map<String, String> attributeMappings;
  List<String> exportExpressionAttrs;
  List<String> exportExpressions;

  DirectiveMetadata([this.className, this.type, this.selector,
                     this.attributeMappings, this.exportExpressionAttrs,
                     this.exportExpressions]) {
    if (attributeMappings == null) {
      attributeMappings = <String, String>{};
    }
    if (exportExpressions == null) {
      exportExpressions = <String>[];
    }
    if (exportExpressionAttrs == null) {
      exportExpressionAttrs = <String>[];
    }
  }
}

/**
 * Extends list to always returned lowercase attribute name:
 *
 *   var l = new _AttributeList();
 *   l.add('fooBar');
 *   print(l[0]); // "foobar"
 *
 * It helps working with html5lib `Node` class which also lowercase attribute names.
 *
 * Note: attribute names are case-insensitive in HTML.
 */
class _AttributeList extends ListBase<String> {
  final List<String> _attributes = [];

  void set length(int len) {
    _attributes.length = len;
  }

  int get length => _attributes.length;

  String operator [](int index) => _attributes[index].toLowerCase();

  void operator []=(int index, String value) {
    _attributes[index] = value;
  }
}
