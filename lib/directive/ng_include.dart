part of angular.directive;

/**
 * Fetches, compiles and includes an external Angular template/HTML. `Selector: [ng-include]`
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

  final dom.Element element;
  final Scope scope;
  final ViewFactoryCache viewFactoryCache;
  final DirectiveInjector directiveInjector;
  final DirectiveMap directives;

  View _view;
  Scope _childScope;

  NgInclude(this.element, this.scope, this.viewFactoryCache,
            this.directiveInjector, this.directives);

  _cleanUp() {
    if (_view == null) return;
    _view.nodes.forEach((node) => node.remove);
    _childScope.destroy();
    _childScope = null;
    element.innerHtml = '';
    _view = null;
  }

  _updateContent(ViewFactory viewFactory) {
    // create a new scope
    _childScope = scope.createProtoChild();
    _view = viewFactory(_childScope, directiveInjector);
    _view.nodes.forEach((node) => element.append(node));
  }

  set url(value) {
    _cleanUp();
    if (value != null && value != '') {
      viewFactoryCache.fromUrl(value, directives, Uri.base).then(_updateContent);
    }
  }
}
