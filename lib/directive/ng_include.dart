part of angular.directive;

/**
 * Fetches, compiles and includes an external Angular template/HTML.
 *
 * A new child [Scope] is created for the included DOM subtree.
 *
 * [NgInclude] provides only one small part of the power of
 * [Component].  Consider using directives and components instead as they
 * provide this feature as well as much more.
 *
 * Note: The browser's Same Origin Policy (<http://v.gd/5LE5CA>) and
 * Cross-Origin Resource Sharing (CORS) policy (<http://v.gd/nXoY8y>) restrict
 * whether the template is successfully loaded.  For example,
 * [NgInclude] won't work for cross-domain requests on all browsers and
 * for `file://` access on some browsers.
 */
@Decorator(
    selector: '[ng-include]',
    map: const {'.': '@url'},
    children: Directive.TRANSCLUDE_CHILDREN)
class NgInclude {
  final ViewCache _viewCache;
  final DirectiveMap _directives;
  final ViewPort _viewPort;
  final Scope _scope;
  View _view;

  NgInclude(this._scope, this._viewCache, this._directives, this._viewPort);

  void set url(value) {
    _cleanUp();
    if (value != null && value != '') {
      _viewCache.fromUrl(value, _directives).then(_updateContent);
    }
  }

  void _cleanUp() {
    if (_view != null) {
      _viewPort.remove(_view);
      _view = null;
    }
  }

  void _updateContent(ViewFactory viewFactory) {
    _view = _viewPort.insertNew(viewFactory);
    print(_view.nodes);
  }
}
