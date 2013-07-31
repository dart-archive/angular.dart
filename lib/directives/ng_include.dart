part of angular;

class NgIncludeAttrDirective {

  NgIncludeAttrDirective(dom.Element element, Scope scope, NodeAttrs attrs, BlockCache blockCache, Injector injector) {

    var previousBlock = null;
    var previousScope = null;

    cleanUp() {
      if (previousBlock == null) {
        return;
      }

      previousBlock.remove();
      previousScope.$destroy();
      element.innerHtml = '';

      previousBlock = null;
      previousScope = null;
    };

    updateContent(createBlock) {
      cleanUp();

      // create a new scope
      previousScope = scope.$new();
      previousBlock = createBlock(injector.createChild([new ScopeModule(previousScope)]));

      previousBlock.elements.forEach((elm) {
        element.append(elm);
      });
    };

    scope.$watch(attrs[this], (value, another) {
      print('ng-include tpl changed to $value');

      if (value == null || value == '') {
        cleanUp();
        return;
      }

      if (value.startsWith('<')) {
        // inlined template
        updateContent(blockCache.fromHtml(value));
      } else {
        // an url template
        blockCache.fromUrl(value).then((createBlock) {
          updateContent(createBlock);

          // Http should take care of this
          scope.$digest();
        });
      }
    });
  }
}
