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
  // This Directive is special and does not go through injection.
  NgAttrMustacheDirective(NodeAttrs attrs, String markup, Interpolate interpolate, Scope scope) {
    var eqPos = markup.indexOf('=');
    var attrName = markup.substring(0, eqPos);
    var attrValue = markup.substring(eqPos + 1);
    Interpolation interpolation = interpolate(attrValue);
    interpolation.setter = (text) => attrs[attrName] = text;
    interpolation.setter('');
    scope.$watchSet(interpolation.watchExpressions, interpolation.call, markup.trim());
  }
}

