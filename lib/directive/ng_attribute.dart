part of angular.directive;

/**
  * The `ngAttr` directive allows you to include attributes you do not want eagerly
  * processed by the browser
  *
  * @example
        <svg>
          <circle ng-attr-cx="{{cx}}"></circle>
        </svg>
  */
@NgDirective(
    selector: '[ng-attr-*]')
class NgAttributeDirective implements NgAttachAware {
  dom.Element _element;

  NgAttributeDirective(dom.Element this._element);

  void attach() {
    _element.attributes.keys.forEach((key) {
      if (key.startsWith('ng-attr-')) {
        _element.attributes[key.substring(8)] = _element.attributes.remove(key);
      }
    });
  }
}
