library angular.directive.ng_include;

import "dart:html" as dom;
import 'package:di/di.dart';
import "../dom/directive.dart";
import "../dom/block.dart";
import "../dom/block_factory.dart";
import "../scope.dart";

@NgDirective(
    selector: '[ng-include]',
    map: const {'ng-include': '=.url'} )
class NgIncludeAttrDirective {

  dom.Element element;
  Scope scope;
  BlockCache blockCache;
  Injector injector;

  Block _previousBlock;
  Scope _previousScope;

  NgIncludeAttrDirective(dom.Element this.element,
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
    _cleanUp();

    // create a new scope
    _previousScope = scope.$new();
    _previousBlock = createBlock(injector.createChild([new Module()..value(Scope, _previousScope)]));

    _previousBlock.elements.forEach((elm) => element.append(elm));
  }


  set url(value) {
    if (value == null || value == '') {
      _cleanUp();
      return;
    }

    if (value.startsWith('<')) {
      // inlined template
      _updateContent(blockCache.fromHtml(value));
    } else {
      // an url template
      blockCache.fromUrl(value).then((createBlock) => _updateContent(createBlock));
    }
  }
}
