library ng_specs;


import 'dart:html';
import 'package:unittest/unittest.dart' as unit;
import 'package:angular/debug.dart';
import 'dart:mirrors' as mirror;
import 'package:angular/angular.dart';
import 'package:di/di.dart';

export 'package:unittest/unittest.dart';
export 'package:angular/debug.dart';
export 'package:angular/angular.dart';
export 'dart:html';
export 'jasmine_syntax.dart';
export 'package:di/di.dart';

es(String html) {
  var div = new DivElement();
  div.innerHtml = html;
  return div.nodes;
}

e(String html) => es(html).first;

Expect expect(actual, [unit.Matcher matcher]) {
  if (?matcher) {
    unit.expect(actual, matcher);
  }
  return new Expect(actual);
}

class Expect {
  var actual;
  Expect(this.actual);

  toEqual(expected) => unit.expect(actual, unit.equals(expected));
  toBe(expected) => unit.expect(actual,
      unit.predicate((actual) => identical(expected, actual)));
  toThrow(exception) => unit.expect(actual, unit.throwsA(unit.contains(exception)));
  toBeFalsy() => unit.expect(actual, unit.isFalse);
  toBeTruthy() => unit.expect(actual, unit.isTrue);
  toBeNull() => unit.expect(actual, unit.isNull);
  toBeNotNull() => unit.expect(actual, unit.isNotNull);
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
      _list.addAll(es(selector));
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

class SpecInjector {
  var injector;

  inject(Function fn) {
    var stack = null;
    try {
      throw '';
    } catch (e, s) {
      stack = s;
    }
    return () {
      if (injector == null) {
        injector = new Injector([new Module()..value(Expando, new Expando('specExpando'))]);
      }
      try {
        injector.invoke(fn);
      } catch (e, s) {
        var msg;
        if (e is mirror.MirroredUncaughtExceptionError) {
          msg = e.exception_string + "\n ORIGINAL Stack trace:\n" + e.stacktrace.toString();
        } else {
          msg = e.toString();
        }
        var frames = stack.toString().split('\n');
        frames.removeAt(0);
        var declaredAt = frames.join('\n');
        throw msg + "\n DECLARED AT:\n" + declaredAt;
      }
    };

  }

  reset() { injector = null; }
}


