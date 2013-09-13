library angular.directive.ng_if;

import "dart:html" as dom;
import "../dom/directive.dart";
import "../dom/block.dart";
import "../dom/block_factory.dart";
import "../scope.dart";
import "../utils.dart";

@NgDirective(
    transclude: true,
    selector:'[ng-if]',
    map: const {'.': '=.condition'})
class NgIfAttrDirective {

  BoundBlockFactory boundBlockFactory;
  BlockHole blockHole;
  Scope scope;

  Block _block;
  Scope _childScope;

  NgIfAttrDirective(BoundBlockFactory this.boundBlockFactory,
                    BlockHole this.blockHole,
                    Scope this.scope) {
  }

  block() {
    if (_block != null) return _block;
    return _block;
  }

  set condition(value) {
    // TODO(vojta): ignore changes like null -> false
    if (toBool(value)) {
      if (_block == null) {
        _block = boundBlockFactory(_childScope = scope.$new());
        _block.insertAfter(blockHole);
      }
    } else {
      if (_block != null) {
        _block.remove();
        _childScope.$destroy();
        _block = null;
        _childScope = null;
      }
    }
  }
}
