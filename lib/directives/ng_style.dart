library angular.directive.ng_style;

import "dart:html" as dom;
import "../dom/directive.dart";
import "../scope.dart";
import "../utils.dart";

/**
  * The `ngStyle` directive allows you to set CSS style on an HTML element conditionally.
  *
  * @example
        <span ng-style="{color:'red'}">Sample Text</span>
  */
@NgDirective(
    selector: '[ng-style]',
    map: const { 'ng-style': '@.styleExpression'})
class NgStyleAttrDirective {
  dom.Element _element;
  Scope _scope;

  String _styleExpression;

  NgStyleAttrDirective(dom.Element this._element, Scope this._scope) { print('ng-style created'); }

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
