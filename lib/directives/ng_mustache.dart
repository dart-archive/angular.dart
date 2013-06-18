part of angular;

class NgTextMustacheDirective {
  static String $selector = r':contains(/{{.*}}/)';

  dom.Node element;
  ParsedFn interpolateFn;

  NgTextMustacheDirective(dom.Node this.element, NodeAttrs attrs, Interpolate interpolate, Scope scope) {
    interpolateFn = interpolate(attrs[this]);
    element.text = '';
    scope.$watch(interpolateFn, (text) => element.text = text);
  }

}

class NgAttrMustacheDirective {
  static String $selector = r'[*=/{{.*}}/]';
  static RegExp ATTR_NAME_VALUE_REGEXP = new RegExp(r'^([^=]+)=(.*)$');

  NgAttrMustacheDirective(dom.Element element, NodeAttrs attrs, Interpolate interpolate, Scope scope) {
    var match = ATTR_NAME_VALUE_REGEXP.firstMatch(attrs[this]);
    var attrName = match[1];
    ParsedFn interpolateFn = interpolate(match[2]);
    Function attrSetter = (text) => element.attributes[attrName] = text;
    attrSetter('');
    scope.$watch(interpolateFn, attrSetter);
  }
}
