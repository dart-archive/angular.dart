part of angular;

class NgTextMustacheDirective {
  static String $selector = r':contains(/{{.*}}/)';

  dom.Node element;
  DirectiveValue value;
  ParsedFn interpolateFn;

  NgTextMustacheDirective(dom.Node this.element, DirectiveValue this.value, Interpolate interpolate) {
    interpolateFn = interpolate(value.value);
    element.text = '';
  }

  attach(Scope scope) {
    scope.$watch(interpolateFn, (text) => element.text = text);
  }
}

class NgAttrMustacheDirective {
  static String $selector = r'[*=/{{.*}}/]';

  attach(Scope scope) {

  }
}
