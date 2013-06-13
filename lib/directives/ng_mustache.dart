part of angular;

class NgTextMustacheDirective {
  static String $selector = r':contains(/{{.*}}/)';

  dom.Node element;
  ParsedFn interpolateFn;

  NgTextMustacheDirective(dom.Node this.element, DirectiveValue value, Interpolate interpolate) {
    interpolateFn = interpolate(value.value);
    element.text = '';
  }

  attach(Scope scope) {
    scope.$watch(interpolateFn, (text) => element.text = text);
  }
}

class NgAttrMustacheDirective {
  static String $selector = r'[*=/{{.*}}/]';
  static RegExp ATTR_NAME_VALUE_REGEXP = new RegExp(r'^([^=]+)=(.*)$');

  ParsedFn interpolateFn;
  dom.Element element;
  Function attrSetter;

  NgAttrMustacheDirective(dom.Element this.element, DirectiveValue value, Interpolate interpolate) {
    var match = ATTR_NAME_VALUE_REGEXP.firstMatch(value.value);
    var attrName = match[1];
    interpolateFn = interpolate(match[2]);
    attrSetter = (text) => element.attributes[attrName] = text;
    attrSetter('');
  }

  attach(Scope scope) {
    scope.$watch(interpolateFn, attrSetter);
  }
}
