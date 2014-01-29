part of angular.directive;

/**
 * Fetches, compiles and includes an external Angular template/HTML.
 *
 * A new child [Scope] is created for the included DOM subtree.
 *
 * [NgIncludeDirective] provides only one small part of the power of
 * [NgComponent].  Consider using directives and components instead as they
 * provide this feature as well as much more.
 *
 * Note: The browser's Same Origin Policy (<http://v.gd/5LE5CA>) and
 * Cross-Origin Resource Sharing (CORS) policy (<http://v.gd/nXoY8y>) restrict
 * whether the template is successfully loaded.  For example,
 * [NgIncludeDirective] won't work for cross-domain requests on all browsers and
 * for `file://` access on some browsers.
 */
@NgDirective(
    selector: '[ng-include]',
    map: const {'ng-include': '@url'})
class NgIncludeDirective {

  final dom.Element element;
  final Scope scope;
  final BlockCache blockCache;
  final Injector injector;

  Block _previousBlock;
  Scope _previousScope;

  NgIncludeDirective(this.element, this.scope, this.blockCache, this.injector);

  _cleanUp() {
    if (_previousBlock == null) return;

    _previousBlock.remove();
    _previousScope.$destroy();
    element.innerHtml = '';

    _previousBlock = null;
    _previousScope = null;
  }

  _updateContent(createBlock) {
    // create a new scope
    _previousScope = scope.$new();
    _previousBlock = createBlock(injector.createChild([new Module()
        ..value(Scope, _previousScope)]));

    _previousBlock.elements.forEach((elm) => element.append(elm));
  }


  set url(value) {
    _cleanUp();
    if (value != null && value != '') {
      blockCache.fromUrl(value).then(_updateContent);
    }
  }
}
