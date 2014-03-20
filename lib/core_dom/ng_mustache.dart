part of angular.core.dom;

// This Directive is special and does not go through injection.
@NgDirective(selector: r':contains(/{{.*}}/)')
class NgTextMustacheDirective {
  NgTextMustacheDirective(dom.Node element,
                          String markup,
                          Interpolate interpolate,
                          Scope scope,
                          AstParser parser,
                          FilterMap filters) {
    Interpolation interpolation = interpolate(markup);
    interpolation.setter = (text) => element.text = text;

    List items = interpolation.expressions
        .map((exp) => parser(exp, filters: filters))
        .toList();
    AST ast = new PureFunctionAST('[[$markup]]', new ArrayFn(), items);
    scope.watch(ast, interpolation.call, readOnly: true);
  }
}

// This Directive is special and does not go through injection.
@NgDirective(selector: r'[*=/{{.*}}/]')
class NgAttrMustacheDirective {
  bool _hasObservers;
  Watch _watch;

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
    var lastValue = markup;
    Interpolation interpolation = interpolate(attrValue)..setter = (text) {
      if (lastValue != text) lastValue = attrs[attrName] = text;
    };

    // TODO(misko): figure out how to remove call to setter. It slows down
    // View instantiation
    interpolation.setter('');

    List items = interpolation.expressions
        .map((exp) => parser(exp, filters: filters))
        .toList();

    AST ast = new PureFunctionAST('[[$markup]]', new ArrayFn(), items);

    attrs.listenObserverChanges(attrName, (hasObservers) {
      if (_hasObservers != hasObservers) {
        _hasObservers = hasObservers;
        if (_watch != null) _watch.remove();
        _watch = scope.watch(ast, interpolation.call, readOnly: !hasObservers);
      }
    });
  }
}

