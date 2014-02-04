part of angular.directive;

/**
  * The `ngStyle` directive allows you to set CSS style on an HTML element
  * conditionally.
  *
  * @example
  *     <span ng-style="{color:'red'}">Sample Text</span>
  */
@NgDirective(
    selector: '[ng-style]',
    map: const { 'ng-style': '@styleExpression'})
class NgStyleDirective {
  final dom.Element _element;
  final Scope _scope;
  final AstParser _parser;

  String _styleExpression;
  Watch _watch;

  NgStyleDirective(this._element, this._scope, this._parser);

/**
  * ng-style attribute takes an expression which evaluates to an
  * object whose keys are CSS style names and values are corresponding values
  * for those CSS keys.
  */
  set styleExpression(String value) {
    _styleExpression = value;
    if (_watch != null) _watch.remove();
    _watch = _scope.watch(_parser(_styleExpression, collection: true), _onStyleChange);
  }

  _onStyleChange(MapChangeRecord mapChangeRecord, _) {
    if (mapChangeRecord != null) {
      dom.CssStyleDeclaration css = _element.style;
      fn(MapKeyValue kv) => css.setProperty(kv.key, kv.currentValue == null ? '' : kv.currentValue);

      mapChangeRecord
        ..forEachRemoval(fn)
        ..forEachChange(fn)
        ..forEachAddition(fn);
    }
  }
}
