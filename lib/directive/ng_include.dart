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
    map: const {'ng-include': '@url'})
class NgInclude {
  final dom.Element _element;
  final Scope _scope;
  final ViewCache _viewCache;
  final Injector _injector;
  final DirectiveMap _directives;

  View _view;

  NgInclude(this._element, this._scope, this._viewCache, this._injector, this._directives);

  void set url(String value) {
    _cleanUp();
    if (value != null && value != '') {
      _viewCache.fromUrl(value, _directives).then(_updateContent);
    }
  }

  void _cleanUp() {
    if (_view == null) return;
    _view.nodes.forEach((node) => node.remove);
    _element.innerHtml = '';
    _view = null;
  }

  void _updateContent(ViewFactory createView) {
    _view = createView(new Module()..bind(Scope, toValue: _scope));

    _view.nodes.forEach((node) => element.append(node));
  }
}
