part of angular;

@NgDirective(selector: r':contains(/{{.*}}/)')
class NgTextMustacheDirective {
  dom.Node element;
  ParsedFn interpolateFn;

  // This Directive is special and does not go through injection.
  NgTextMustacheDirective(dom.Node this.element, String markup, Interpolate interpolate, Scope scope) {
    interpolateFn = interpolate(markup);
    element.text = '';
    scope.$watch(interpolateFn, (text) => element.text = text);
  }

}

@NgDirective(selector: r'[*=/{{.*}}/]')
class NgAttrMustacheDirective {
  static RegExp ATTR_NAME_VALUE_REGEXP = new RegExp(r'^([^=]+)=(.*)$');

// This Directive is special and does not go through injection.
  NgAttrMustacheDirective(dom.Element element, String markup, Interpolate interpolate, Scope scope) {
    var match = ATTR_NAME_VALUE_REGEXP.firstMatch(markup);
    var attrName = match[1];
    ParsedFn interpolateFn = interpolate(match[2]);
    Function attrSetter = (text) => element.attributes[attrName] = text;
    attrSetter('');
    scope.$watch(interpolateFn, attrSetter);
  }
}
