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
    scope.$watchSet(interpolation.watchExpressions, interpolation.call,
        markup.trim());
  }

}

@NgDirective(selector: r'[*=/{{.*}}/]')
class NgAttrMustacheDirective {
  static final RegExp _ATTR_NAME_VALUE_REGEXP = new RegExp(r'^([^=]+)=(.*)$');
  static final RegExp _EXPR_REGEXP = new RegExp(r'^{{(.*)}}$');

  // This Directive is special and does not go through injection.
  NgAttrMustacheDirective(dom.Node node, String markup, Interpolate interpolate,
      Scope scope, Parser parser) {
    var attrMatch = _ATTR_NAME_VALUE_REGEXP.firstMatch(markup);
    var attrName = attrMatch[1];
    var attrValue = attrMatch[2];

    var box = new ObservableBox();
    var binding = nodeBind(node).bind(attrName, box, 'value');

    var exprMatch = _EXPR_REGEXP.firstMatch(attrValue);

    if (exprMatch != null) {
      Expression expression = parser(exprMatch[1]);
      if (expression.assignable) {
        box.changes.listen((_) => expression.assign(scope, box.value));
      }
      scope.$watch(expression.eval, (value, _) => box.value = value,
          markup.trim());
    } else {
      var interpolation = interpolate(attrValue);
      interpolation.setter = (text) => box.value = text;
      scope.$watchSet(interpolation.watchExpressions, interpolation.call,
          markup.trim());
    }
  }
}
