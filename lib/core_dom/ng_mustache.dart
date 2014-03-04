part of angular.core.dom;

@NgDirective(selector: r':contains(/{{.*}}/)')
class NgTextMustacheDirective {
  // This Directive is special and does not go through injection.
  NgTextMustacheDirective(dom.Node element,
                          String markup,
                          Interpolate interpolate,
                          Scope scope,
                          AstParser parser,
                          FilterMap filters) {
    Interpolation interpolation = interpolate(markup);
    interpolation.setter = (text) => element.text = text;

    List items = interpolation.expressions.map((exp) {
      return parser(exp, filters:filters);
    }).toList();
    AST ast = new PureFunctionAST('[[$markup]]', new ArrayFn(), items);
    scope.watch(ast, interpolation.call, readOnly: true);
  }

}

@NgDirective(selector: r'[*=/{{.*}}/]')
class NgAttrMustacheDirective {
  // This Directive is special and does not go through injection.
  NgAttrMustacheDirective(NodeAttrs attrs,
                          String markup,
                          Interpolate interpolate,
                          Scope scope,
                          AstParser parser,
                          FilterMap filters) {
    var eqPos = markup.indexOf('=');
    var attrName = markup.substring(0, eqPos);
    var attrValue = markup.substring(eqPos + 1);
    Interpolation interpolation = interpolate(attrValue);
    var lastValue = markup;
    interpolation.setter = (text) {
      if (lastValue != text) {
            lastValue = attrs[attrName] = text;
      }
    };
    // TODO(misko): figure out how to remove call to setter. It slows down
    // Block instantiation
    interpolation.setter('');

    List items = interpolation.expressions.map((exp) {
      return parser(exp, filters:filters);
    }).toList();
    AST ast = new PureFunctionAST('[[$markup]]', new ArrayFn(), items);
    /*
      Attribute bindings are tricky. They need to be resolved on digest
      inline with components so that any bindings to component can
      be resolved before the component attach method. But once the
      component is attached we need to run on the flush cycle rather
      then digest cycle.
     */
    // TODO(misko): figure out how to get most of these on observe rather then watch.
    scope.watch(ast, interpolation.call);
  }
}

