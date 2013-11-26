part of angular.core.dom;

@NgDirective(selector: r':contains(/{{.*}}/)')
class NgTextMustacheDirective {
  // This Directive is special and does not go through injection.
  NgTextMustacheDirective(dom.Node element,
                          String markup,
                          Interpolate interpolate,
                          Scope scope,
                          TextChangeListener listener) {
    Interpolation interpolation = interpolate(markup);
    interpolation.setter = (text) {
      element.text = text;
      if (listener != null) listener.call(text);
    };
    interpolation.setter('');
    scope.$watchSet(interpolation.watchExpressions, interpolation.call, markup.trim());
  }

}

@NgDirective(selector: r'[*=/{{.*}}/]')
class NgAttrMustacheDirective {
  static RegExp ATTR_NAME_VALUE_REGEXP = new RegExp(r'^([^=]+)=(.*)$');

// This Directive is special and does not go through injection.
  NgAttrMustacheDirective(NodeAttrs attrs, String markup, Interpolate interpolate, Scope scope) {
    var match = ATTR_NAME_VALUE_REGEXP.firstMatch(markup);
    var attrName = match[1];
    Interpolation interpolation = interpolate(match[2]);
    interpolation.setter = (text) => attrs[attrName] = text;
    interpolation.setter('');
    scope.$watchSet(interpolation.watchExpressions, interpolation.call, markup.trim());
  }
}

