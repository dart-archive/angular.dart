library css_shim;

import 'package:angular/core/parser/characters.dart';

String shimCssText(String css, String tag) =>
    new _CssShim(tag).shimCssText(css);


/**
 * This is a shim for ShadowDOM css styling. It adds an attribute selector suffix
 * to each simple selector.
 *
 * So:
 *
 *    one, two {color: red;}
 *
 * Becomes:
 *
 *    one[tag], two[tag] {color: red;}
 *
 * It can handle the following selectors:
 * * `one::before`
 * * `one two`
 * * `one>two`
 * * `one+two`
 * * `one~two`
 * * `.one.two`
 * * `one[attr="value"]`
 * * `one[attr^="value"]`
 * * `one[attr$="value"]`
 * * `one[attr*="value"]`
 * * `one[attr|="value"]`
 * * `one[attr]`
 * * `[is=one]`
 *
 * It can handle :host:
 * * `:host`
 * * `:host(.x)`
 *
 * When the shim is not powerful enough, you can fall back on the polyfill-next-selector
 * directive.
 *
 *    polyfill-next-selector {content: 'x > y'}
 *    z {}
 *
 * Becomes:
 *
 *   x[tag] > y[tag]
 *
 * See http://www.polymer-project.org/docs/polymer/styling.html#at-polyfill
 *
 * This implementation is a simplified version of the shim provided by platform.js:
 * https://github.com/Polymer/platform-dev/blob/master/src/ShadowCSS.js
 */
class _CssShim {
  static final List SELECTOR_SPLITS = const [' ', '>', '+', '~'];
  static final RegExp POLYFILL_NEXT_SELECTOR_DIRECTIVE = new RegExp(
      r"polyfill-next-selector"
      r"[^}]*"
      r"content\:[\s]*"
      r"'([^']*)'"
      r"[^}]*}"
      r"([^{]*)",
      caseSensitive: false,
      multiLine: true
  );
  static final int NEXT_SELECTOR_CONTENT = 1;

  static final String HOST_TOKEN = '-host-element';
  static final RegExp COLON_SELECTORS = new RegExp(r'(' + HOST_TOKEN + r')(\(.*\)){0,1}(.*)',
      caseSensitive: false);
  static final RegExp SIMPLE_SELECTORS = new RegExp(r'([^:]*)(:*)(.*)', caseSensitive: false);
  static final RegExp IS_SELECTORS = new RegExp(r'\[is="([^\]]*)"\]', caseSensitive: false);

  // See https://github.com/Polymer/platform-dev/blob/master/src/ShadowCSS.js#L561
  static final String PAREN_SUFFIX = r')(?:\(('
      r'(?:\([^)(]*\)|[^)(]*)+?'
      r')\))?([^,{]*)';
  static final RegExp COLON_HOST = new RegExp('($HOST_TOKEN$PAREN_SUFFIX',
      caseSensitive: false, multiLine: true);

  final String tag;
  final String attr;

  _CssShim(String tag)
      : tag = tag, attr = "[$tag]";

  String shimCssText(String css) {
    final preprocessed = convertColonHost(applyPolyfillNextSelectorDirective(css));
    final rules = cssToRules(preprocessed);
    return scopeRules(rules);
  }

  String applyPolyfillNextSelectorDirective(String css) =>
      css.replaceAllMapped(POLYFILL_NEXT_SELECTOR_DIRECTIVE, (m) => m[NEXT_SELECTOR_CONTENT]);

  String convertColonHost(String css) {
    css = css.replaceAll(":host", HOST_TOKEN);

    String partReplacer(host, part, suffix) =>
        "$host${part.replaceAll(HOST_TOKEN, '')}$suffix";

    return css.replaceAllMapped(COLON_HOST, (m) {
      final base = HOST_TOKEN;
      final inParens = m.group(2);
      final rest = m.group(3);

      if (inParens != null && inParens.isNotEmpty) {
        return inParens.split(',')
            .map((p) => p.trim())
            .where((_) => _.isNotEmpty)
            .map((p) => partReplacer(base, p, rest))
            .join(",");
      } else {
        return "$base$rest";
      }
    });
  }

  List<_Rule> cssToRules(String css) =>
      new _Parser(css).parse();

  String scopeRules(List<_Rule> rules) =>
      rules.map(scopeRule).join("\n");

  String scopeRule(_Rule rule) {
    if (rule.hasNestedRules) {
      final selector = rule.selectorText;
      final rules = scopeRules(rule.rules);
      return '$selector {\n$rules\n}';
    } else {
      final scopedSelector = scopeSelector(rule.selectorText);
      final scopedBody = cssText(rule);
      return "$scopedSelector $scopedBody";
    }
  }

  String scopeSelector(String selector) {
    final parts = selector.split(",");
    final scopedParts = parts.fold([], (res, p) {
      res.add(scopeSimpleSelector(p.trim()));
      return res;
    });
    return scopedParts.join(", ");
  }

  String scopeSimpleSelector(String selector) {
    if (selector.contains(HOST_TOKEN)) {
      return replaceColonSelectors(selector);
    } else {
      return insertTag(selector);
    }
  }

  String cssText(_Rule rule) => rule.body;

  String replaceColonSelectors(String css) {
    return css.replaceAllMapped(COLON_SELECTORS, (m) {
      final selectorInParens = m[2] == null ? "" : m[2].substring(1, m[2].length - 1);
      final rest = m[3];
      return "$tag$selectorInParens$rest";
    });
  }

  String insertTag(String selector) {
    selector = handleIsSelector(selector);

    SELECTOR_SPLITS.forEach((split) {
      final parts = selector.split(split).map((p) => p.trim());
      selector = parts.map(insertAttrSuffixIntoSelectorPart).join(split);
    });

    return selector;
  }

  String insertAttrSuffixIntoSelectorPart(String p) {
    final shouldInsert = p.isNotEmpty && !SELECTOR_SPLITS.contains(p) && !p.contains(attr);
    return shouldInsert ? insertAttr(p) : p;
  }

  String insertAttr(String selector) {
    return selector.replaceAllMapped(SIMPLE_SELECTORS, (m) {
      final basePart = m[1];
      final colonPart = m[2];
      final rest = m[3];
      return m[0].isNotEmpty ? "$basePart$attr$colonPart$rest" : "";
    });
  }

  String handleIsSelector(String selector) =>
      selector.replaceAllMapped(IS_SELECTORS, (m) => m[1]);
}



class _Token {
  static final _Token EOF = new _Token(null);
  final String string;
  final String type;
  _Token(this.string, [this.type]);

  String toString() => "TOKEN[$string, $type]";
}

class _Lexer {
  int peek = 0;
  int index = -1;
  final String input;
  final int length;

  _Lexer(String input)
      : input = input, length = input.length {
    advance();
  }

  List<_Token> parse() {
    final res = [];
    var t = scanToken();
    while (t != _Token.EOF) {
      res.add(t);
      t = scanToken();
    }
    return res;
  }

  _Token scanToken() {
    skipWhitespace();

    if (peek == $EOF) return _Token.EOF;
    if (isBodyEnd(peek)) {
      advance();
      return new _Token("}", "rparen");
    }
    if (isMedia(peek)) return scanMedia();
    if (isSelector(peek)) return scanSelector();
    if (isBodyStart(peek)) return scanBody();

    return _Token.EOF;
  }

  bool isSelector(int v) => !isBodyStart(v) && v != $EOF;
  bool isBodyStart(int v) => v == $LBRACE;
  bool isBodyEnd(int v) => v == $RBRACE;
  bool isMedia(int v) => v == 64; //@ = 64

  void skipWhitespace() {
    while (isWhitespace(peek)) {
      if (++index >= length) {
        peek = $EOF;
        return null;
      } else {
        peek = input.codeUnitAt(index);
      }
    }
  }

  _Token scanSelector() {
    int start = index;
    advance();
    while (isSelector(peek)) advance();
    String string = input.substring(start, index);
    return new _Token(string, "selector");
  }

  _Token scanBody() {
    int start = index;
    advance();
    while (!isBodyEnd(peek)) advance();
    advance();
    String string = input.substring(start, index);
    return new _Token(string, "body");
  }

  _Token scanMedia() {
    int start = index;
    advance();

    while (!isBodyStart(peek)) advance();
    String string = input.substring(start, index);

    advance(); //skip {

    return new _Token(string, "media");
  }

  void advance() {
    peek = ++index >= length ? $EOF : input.codeUnitAt(index);
  }
}

class _Rule {
  final String selectorText;
  final String body;
  final List<_Rule> rules;

  _Rule(this.selectorText, {this.body, this.rules});

  bool get hasNestedRules => rules != null;

  String toString() => "Rule[$selectorText $body]";
}

class _Parser {
  List<_Token> tokens;
  int currentIndex;

  _Parser(String input) {
    tokens = new _Lexer(input).parse();
    currentIndex = -1;
  }

  List<_Rule> parse() {
    final res = [];
    var rule;
    while ((rule = parseRule()) != null) {
      res.add(rule);
    }
    return res;
  }

  _Rule parseRule() {
    try {
      if (next.type == "media") {
        return parseMedia();
      } else {
        return parseCssRule();
      }
    } catch (e) {
      return null;
    }
  }

  _Rule parseMedia() {
    advance("media");
    final media = current.string;

    final rules = [];
    while (next.type != "rparen") {
      rules.add(parseCssRule());
    }
    advance("rparen");

    return new _Rule(media.trim(), rules: rules);
  }

  _Rule parseCssRule() {
    advance("selector");
    final selector = current.string;

    advance("body");
    final body = current.string;

    return new _Rule(selector, body: body);
  }

  void advance(String expectedType) {
    currentIndex += 1;
    if (current.type != expectedType) {
      throw "Unexpected token ${current.type}. Expected $expectedType";
    }
  }

  _Token get current => tokens[currentIndex];
  _Token get next => tokens[currentIndex + 1];
}