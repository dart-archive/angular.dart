library ng_specs;


import 'dart:html';
import 'package:unittest/unittest.dart' as unit;
import 'debug.dart';
import 'dart:mirrors' as mirror;

export 'package:unittest/unittest.dart';
export 'debug.dart';
export '../src/angular.dart';
export 'dart:html';
export 'jasmineSyntax.dart';
export 'package:di/di.dart';

es(String html) {
  var div = new DivElement();
  div.innerHtml = html;
  return div.nodes;
}

e(String html) => es(html).first;

expect(actual, [unit.Matcher matcher]) {
  if (?matcher) {
    return unit.expect(actual, matcher);
  } else {
    return new Expect(actual);
  }
}

class Expect {
  var actual;
  Expect(this.actual);

  toEqual(expected) => unit.expect(actual, unit.equals(expected));
  toBe(expected) => unit.expect(actual,
      unit.predicate((actual) => identical(expected, actual)));
}

$(selector) {
  return new JQuery(selector);
}

class JQuery implements List<Node> {
  List<Node> _list = [];

  JQuery([selector]) {
    if (!?selector) {
      // do nothing;
    } else if (selector is String) {
      print(selector);
      Iterable<Node> nodes = es(selector);
      print(nodes);
      _list.addAll(nodes);
    } else if (selector is Node) {
      add(selector);
    } else {
      throw new ArgumentError();
    }
  }

  noSuchMethod(Invocation invocation) => mirror.reflect(_list).delegate(invocation);

  _toHtml(node, [bool outer = false]) {
    if (node is Comment) {
      return '<!--${node.text}-->';
    } else {
      return outer ? node.outerHtml : node.innerHtml;
    }
  }

  accessor(Function getter, Function setter, [value]) {
    // TODO(dart): ?value does not work, since value was passed. :-(
    var setterMode = ?value && value != null;
    var result = setterMode ? this : '';
    _list.forEach((node) {
      if (setterMode) {
        setter(node, value);
      } else {
        result = '$result${getter(node)}';
      }
    });
    return result;
  }

  html([String html]) => accessor((n) => _toHtml(n), (n, v) => n.innerHtml = v, html);
  text([String text]) => accessor((n) => n.text, (n, v) => n.text = v, text);
  contents() => fold(new JQuery(), (jq, node) => jq..addAll(node.nodes));
  toString() => fold('', (html, node) => '$html${_toHtml(node, true)}');
  eq(num childIndex) => $(this[childIndex]);
}

class Logger implements List {
  List<Node> _list = [];

  noSuchMethod(Invocation invocation) => mirror.reflect(_list).delegate(invocation);
}


