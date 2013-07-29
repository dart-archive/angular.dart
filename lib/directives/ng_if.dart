part of angular;

@NgDirective(transclude: true)
class NgIfAttrDirective {

  NgIfAttrDirective(BoundBlockFactory boundBlockFactory, BlockHole blockHole,
                    NodeAttrs attrs, dom.Node node, Scope scope) {
    var _block;
    block() {
      if (_block != null) return _block;
      var childScope = scope.$new();
      _block = boundBlockFactory(childScope);
      return _block;
    }
    var isInserted = false;

    scope.$watch(attrs[this], (value) {
      // TODO(vojta): ignore changes like null -> false
      if (value != null && toBool(value)) {
        if (!isInserted) {
          block().insertAfter(blockHole);
          isInserted = true;
        }
      } else {
        if (isInserted) {
          block().remove();
          isInserted = false;
        }
      }
    });
  }
}
