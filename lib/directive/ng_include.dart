part of angular.directive;

@NgDirective(
    selector: '[ng-include]',
    map: const {'ng-include': '=>url'} )
class NgIncludeDirective {

  dom.Element element;
  Scope scope;
  BlockCache blockCache;
  Injector injector;

  Block _previousBlock;
  Scope _previousScope;

  NgIncludeDirective(dom.Element this.element,
                         Scope this.scope,
                         BlockCache this.blockCache,
                         Injector this.injector);

  _cleanUp() {
    if (_previousBlock == null) {
      return;
    }

    _previousBlock.remove();
    _previousScope.$destroy();
    element.innerHtml = '';

    _previousBlock = null;
    _previousScope = null;
  }

  _updateContent(createBlock) {
    // create a new scope
    _previousScope = scope.$new();
    _previousBlock = createBlock(injector.createChild([new Module()..value(Scope, _previousScope)]));

    _previousBlock.elements.forEach((elm) => element.append(elm));
  }


  set url(value) {
    _cleanUp();
    if (value != null && value != '') {
      blockCache.fromUrl(value).then(_updateContent);
    }
  }
}
