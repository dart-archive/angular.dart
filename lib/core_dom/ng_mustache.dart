part of angular.core.dom;

@NgDirective(selector: r':contains(/{{.*}}/)')
class NgTextMustacheDirective {
  // This Directive is special and does not go through injection.
  NgTextMustacheDirective(dom.Node element,
                          String markup,
                          Interpolate interpolate,
                          Scope scope,
                          TextChangeListener listener) {
    Expression interpolateFn = interpolate(markup);
    setter(text) {
      element.text = text;
      if (listener != null) listener.call(text);
    }
    setter('');
    scope.$watch(interpolateFn.eval, setter, markup.trim());
  }

}

@NgDirective(selector: r'[*=/{{.*}}/]')
class NgAttrMustacheDirective {
  static RegExp ATTR_NAME_VALUE_REGEXP = new RegExp(r'^([^=]+)=(.*)$');

// This Directive is special and does not go through injection.
  NgAttrMustacheDirective(NodeAttrs attrs, String markup, Interpolate interpolate, Scope scope) {
    var match = ATTR_NAME_VALUE_REGEXP.firstMatch(markup);
    var attrName = match[1];
    Expression interpolateFn = interpolate(match[2]);
    Function attrSetter = (text) => attrs[attrName] = text;
    attrSetter('');
    scope.$watch(interpolateFn.eval, attrSetter, markup.trim());
  }
}

