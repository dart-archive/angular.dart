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
  static RegExp EXPR_REGEXP = new RegExp(r'^{{(.*)}}$');

// This Directive is special and does not go through injection.
  NgAttrMustacheDirective(dom.Node node, NodeAttrs attrs, String markup, Interpolate interpolate, Scope scope, Parser parser) {
    var match = ATTR_NAME_VALUE_REGEXP.firstMatch(markup);
    var attrName = match[1];
    var exprMatch = EXPR_REGEXP.firstMatch(match[2]);

    var box = new ObservableBox();
    var binding = nodeBind(node).bind(attrName, box, 'value');

    if (exprMatch != null) {
      Expression expression = parser(EXPR_REGEXP.firstMatch(match[2])[1]);
      box.changes.listen((_) => expression.assign(scope, box.value));
      scope.$watch(expression.eval, (newValue, oldValue) => box.value = newValue, markup.trim());
    } else {
      Interpolation interpolation = interpolate(match[2]);
      interpolation.setter = (text) => box.value = text;
      interpolation.setter('');
      scope.$watchSet(interpolation.watchExpressions, interpolation.call, markup.trim());
    }
  }
}
