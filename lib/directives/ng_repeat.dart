part of angular;

class Row {
  var id;
  Scope scope;
  Block block;
  dom.Node startNode;
  dom.Node endNode;
  List<dom.Node> elements;

  Row(this.id);
}

@NgDirective(transclude: '.')
class NgRepeatAttrDirective  {
  static RegExp SYNTAX = new RegExp(r'^\s*(.+)\s+in\s+(.*?)\s*(\s+track\s+by\s+(.+)\s*)?$');
  static RegExp LHS_SYNTAX = new RegExp(r'^(?:([\$\w]+)|\(([\$\w]+)\s*,\s*([\$\w]+)\))$');

  String expression;
  String valueIdentifier;
  String keyIdentifier;
  String listExpr;
  ElementWrapper anchor;
  ElementWrapper cursor;
  BlockHole blockHole;
  BoundBlockFactory boundBlockFactory;
  Function trackByIdFn = (key, value, index) {
    return value;
  };
  Map<Object, Row> lastRows = new Map<dynamic, Row>();

  NgRepeatAttrDirective(BlockHole this.blockHole,
                        BoundBlockFactory this.boundBlockFactory,
                        NodeAttrs attrs,
                        Scope scope) {
    expression = attrs[this];
    Match match = SYNTAX.firstMatch(expression);
    if (match == null) {
      throw "[NgErr7] ngRepeat error! Expected expression in form of '_item_ in _collection_[ track by _id_]' but got '$expression'.";
    }
    listExpr = match.group(2);
    var assignExpr = match.group(1);
    match = LHS_SYNTAX.firstMatch(assignExpr);
    if (match == null) {
      throw "[NgErr8] ngRepeat error! '_item_' in '_item_ in _collection_' should be an identifier or '(_key_, _value_)' expression, but got '$assignExpr'.";
    }
    valueIdentifier = match.group(3);
    if (valueIdentifier == null) valueIdentifier = match.group(1);
    keyIdentifier = match.group(2);

    scope.$watchCollection(listExpr, (collection) {
      var previousNode = blockHole.elements[0],     // current position of the node
          nextNode,
          arrayLength,
          childScope,
          trackById,
          newRowOrder = [],
          cursor = blockHole;
      // Same as lastBlockMap but it has the current state. It will become the
      // lastBlockMap on the next iteration.
      Map<dynamic, Row> newRows = new Map<dynamic, Row>();
      arrayLength = collection.length;
      // locate existing items
      var length = newRowOrder.length = collection.length;
      for(var index = 0; index < length; index++) {
        var value = collection[index];
        trackById = trackByIdFn(index, value, index);
        if(lastRows.containsKey(trackById)) {
          var row = lastRows[trackById];
          lastRows.remove(trackById);
          newRows[trackById] = row;
          newRowOrder[index] = row;
        } else if (newRows.containsKey(trackById)) {
          // restore lastBlockMap
          newRowOrder.forEach((row) {
            if (row != null && row.startNode != null) {
              lastRows[row.id] = row;
            }
          });
          // This is a duplicate and we need to throw an error
          throw "[NgErr50] ngRepeat error! Duplicates in a repeater are not allowed. Use 'track by' expression to specify unique keys. Repeater: $expression, Duplicate key: $trackById";
        } else {
          // new never before seen row
          newRowOrder[index] = new Row(trackById);
          newRows[trackById] = null;
        }
      }

      // remove existing items
      lastRows.forEach((key, row){
        row.block.remove();
        row.scope.$destroy();
      });

      for (var index = 0, length = collection.length; index < length; index++) {
        var key = index;
        var value = collection[index];
        Row row = newRowOrder[index];

        if (row.startNode != null) {
          // if we have already seen this object, then we need to reuse the
          // associated scope/element
          childScope = row.scope;

          nextNode = previousNode;
          do {
            nextNode = nextNode.nextNode;
          } while(nextNode != null);

          if (row.startNode == nextNode) {
            // do nothing
          } else {
            // existing item which got moved
            row.block.moveAfter(cursor);
          }
          previousNode = row.endNode;
        } else {
          // new item which we don't know about
          childScope = scope.$new();
        }

        childScope[valueIdentifier] = value;
        childScope.$index = index;
        childScope.$first = (index == 0);
        childScope.$last = (index == (arrayLength - 1));
        childScope.$middle = !(childScope.$first || childScope.$last);

        if (row.startNode == null) {
          newRows[row.id] = row;
          var block = boundBlockFactory(childScope);
          row.block = block;
          row.scope = childScope;
          row.elements = block.elements;
          row.startNode = row.elements[0];
          row.endNode = row.elements[row.elements.length - 1];
          block.insertAfter(cursor);
        }
        cursor = row.block;
      }
      lastRows = newRows;
    });
  }
}
