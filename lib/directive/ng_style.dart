part of angular.directive;

/**
  * The `ngStyle` directive allows you to set CSS style on an HTML element conditionally.
  *
  * @example
        <span ng-style="{color:'red'}">Sample Text</span>
  */
@NgDirective(
    selector: '[ng-style]',
    map: const { 'ng-style': '@styleExpression'})
class NgStyleDirective {
  dom.Element _element;
  Scope _scope;

  String _styleExpression;

  NgStyleDirective(dom.Element this._element, Scope this._scope);

  Function _removeWatch = () => null;
  var _lastStyles;

/**
  * ng-style attribute takes an expression hich evals to an
  *      object whose keys are CSS style names and values are corresponding values for those CSS
  *      keys.
  */
  set styleExpression(String value) {
    _styleExpression = value;
    _removeWatch();
    _removeWatch = _scope.$watchCollection(_styleExpression, _onStyleChange);
  }

  _onStyleChange(Map newStyles) {
    dom.CssStyleDeclaration css = _element.style;
    if (_lastStyles != null) {
      _lastStyles.forEach((val, style) { css.setProperty(val, ''); });
    }
    _lastStyles = newStyles;

    if (newStyles != null) {
      newStyles.forEach((val, style) { css.setProperty(val, style); });
    }
  }
}
