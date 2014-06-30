part of angular.core.dom_internal;

// This Directive is special and does not go through injection.
@Decorator(selector: r':contains(/{{.*}}/)')
class TextMustache {
  final dom.Node _element;
  final FormatterMap formatters;

  TextMustache(this._element, AST ast, Scope scope, this.formatters) {
    scope.watchAST(ast,
                _updateMarkup,
                canChangeModel: false, userData: formatters);
  }

  void _updateMarkup(text, previousText) {
    _element.text = text;
  }
}

// This Directive is special and does not go through injection.
@Decorator(selector: r'[*=/{{.*}}/]')
class AttrMustache {
  bool _hasObservers;
  Watch _watch;
  NodeAttrs _attrs;
  String _attrName;
  FormatterMap _formatters;

  // This Directive is special and does not go through injection.
  AttrMustache(this._attrs,
                          String this._attrName,
                          AST valueAST,
                          Scope scope, this._formatters) {
    _updateMarkup('', 'INITIAL-VALUE');

    _attrs.listenObserverChanges(_attrName, (hasObservers) {
    if (_hasObservers != hasObservers) {
      _hasObservers = hasObservers;
      if (_watch != null) _watch.remove();
        _watch = scope.watchAST(valueAST, _updateMarkup,
            canChangeModel: _hasObservers, userData: _formatters);
      }
    });
  }

  void _updateMarkup(text, previousText) {
    if (text != previousText && !(previousText == null && text == '')) {
        _attrs[_attrName] = text;
    }
  }
}

