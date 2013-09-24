library angular.directive.ng_repeat;

import 'dart:html' as dom;
import '../dom/directive.dart';
import '../dom/block.dart';
import '../dom/block_factory.dart';
import '../scope.dart';

class _Row {
  var id;
  Scope scope;
  Block block;
  dom.Element startNode;
  dom.Element endNode;
  List<dom.Element> elements;

  _Row(this.id);
}

@NgDirective(
    transclude: true,
    selector: '[ng-repeat]',
    map: const {'.': '@.expression'})
class NgRepeatAttrDirective  {
  static RegExp SYNTAX = new RegExp(r'^\s*(.+)\s+in\s+(.*?)\s*(\s+track\s+by\s+(.+)\s*)?$');
  static RegExp LHS_SYNTAX = new RegExp(r'^(?:([\$\w]+)|\(([\$\w]+)\s*,\s*([\$\w]+)\))$');

  BlockHole blockHole;
  BoundBlockFactory boundBlockFactory;
  Scope scope;

  String _expression;
  String valueIdentifier;
  String keyIdentifier;
  String listExpr;
  Map<Object, _Row> rows = new Map<dynamic, _Row>();
  Function trackByIdFn = (key, value, index) => value;
  Function removeWatch = () => null;

  NgRepeatAttrDirective(BlockHole this.blockHole,
                        BoundBlockFactory this.boundBlockFactory,
                        Scope this.scope);

  set expression(value) {
    _expression = value;
    removeWatch();
    Match match = SYNTAX.firstMatch(_expression);
    if (match == null) {
      throw "[NgErr7] ngRepeat error! Expected expression in form of '_item_ in _collection_[ track by _id_]' but got '$_expression'.";
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

    removeWatch = scope.$watchCollection(listExpr, _onCollectionChange);
  }

  List<_Row> _computeNewRows(collection, trackById) {
    List<_Row> newRowOrder = [];
    // Same as lastBlockMap but it has the current state. It will become the
    // lastBlockMap on the next iteration.
    Map<dynamic, _Row> newRows = new Map<dynamic, _Row>();
    var arrayLength = collection.length;
    // locate existing items
    var length = newRowOrder.length = collection.length;
    for (var index = 0; index < length; index++) {
      var value = collection[index];
      trackById = trackByIdFn(index, value, index);
      if (rows.containsKey(trackById)) {
        var row = rows[trackById];
        rows.remove(trackById);
        newRows[trackById] = row;
        newRowOrder[index] = row;
      } else if (newRows.containsKey(trackById)) {
        // restore lastBlockMap
        newRowOrder.forEach((row) {
          if (row != null && row.startNode != null) {
            rows[row.id] = row;
          }
        });
        // This is a duplicate and we need to throw an error
        throw "[NgErr50] ngRepeat error! Duplicates in a repeater are not allowed. Use 'track by' expression to specify unique keys. Repeater: $_expression, Duplicate key: $trackById";
      } else {
        // new never before seen row
        newRowOrder[index] = new _Row(trackById);
        newRows[trackById] = null;
      }
    }
    // remove existing items
    rows.forEach((key, row){
      row.block.remove();
      row.scope.$destroy();
    });
    rows = newRows;
    return newRowOrder;
  }

  _onCollectionChange(collection) {
    var previousNode = blockHole.elements[0],     // current position of the node
        nextNode,
        childScope,
        trackById,
        cursor = blockHole;

    if (collection is! List) {
      collection = [];
    }

    List<_Row> newRowOrder = _computeNewRows(collection, trackById);

    for (var index = 0, length = collection.length; index < length; index++) {
      var key = index;
      var value = collection[index];
      _Row row = newRowOrder[index];

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
      childScope[r'$index'] = index;
      childScope[r'$first'] = (index == 0);
      childScope[r'$last'] = (index == (collection.length - 1));
      childScope[r'$middle'] = !(childScope.$first || childScope.$last);

      if (row.startNode == null) {
        rows[row.id] = row;
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
  }
}
