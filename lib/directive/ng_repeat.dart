part of angular.directive;

class _Row {
  var id;
  Scope scope;
  Block block;
  dom.Element startNode;
  dom.Element endNode;
  List<dom.Element> elements;

  _Row(this.id);
}

/**
 * The `ngRepeat` directive instantiates a template once per item from a
 * collection. Each template instance gets its own scope, where the given loop
 * variable is set to the current collection item, and `$index` is set to the
 * item index or key.
 *
 * Special properties are exposed on the local scope of each template instance,
 * including:
 *
 * <table>
 * <tr><th> Variable  </th><th> Type </th><th> Details                                                                     <th></tr>
 * <tr><td> `$index`  </td><td>[num] </td><td> iterator offset of the repeated element (0..length-1)                       <td></tr>
 * <tr><td> `$first`  </td><td>[bool]</td><td> true if the repeated element is first in the iterator.                      <td></tr>
 * <tr><td> `$middle` </td><td>[bool]</td><td> true if the repeated element is between the first and last in the iterator. <td></tr>
 * <tr><td> `$last`   </td><td>[bool]</td><td> true if the repeated element is last in the iterator.                       <td></tr>
 * <tr><td> `$even`   </td><td>[bool]</td><td> true if the iterator position `$index` is even (otherwise false).           <td></tr>
 * <tr><td> `$odd`    </td><td>[bool]</td><td> true if the iterator position `$index` is odd (otherwise false).            <td></tr>
 * </table>
 *
 *
 * [repeat_expression] ngRepeat The expression indicating how to enumerate a
 * collection. These formats are currently supported:
 *
 *   * `variable in expression` – where variable is the user defined loop
 *   variable and `expression` is a scope expression giving the collection to
 *   enumerate.
 *
 *     For example: `album in artist.albums`.
 *
 *   * `variable in expression track by tracking_expression` – You can also
 *   provide an optional tracking function which can be used to associate the
 *   objects in the collection with the DOM elements. If no tracking function is
 *   specified the ng-repeat associates elements by identity in the collection.
 *   It is an error to have more than one tracking function to resolve to the
 *   same key. (This would mean that two distinct objects are mapped to the same
 *   DOM element, which is not possible.)  Filters should be applied to the
 *   expression, before specifying a tracking expression.
 *
 *     For example: `item in items` is equivalent to `item in items track by
 *     $id(item)`. This implies that the DOM elements will be associated by item
 *     identity in the array.
 *
 *     For example: `item in items track by $id(item)`. A built in `$id()`
 *     function can be used to assign a unique `$$hashKey` property to each item
 *     in the array. This property is then used as a key to associated DOM
 *     elements with the corresponding item in the array by identity. Moving the
 *     same object in array would move the DOM element in the same way ian the
 *     DOM.
 *
 *     For example: `item in items track by item.id` is a typical pattern when
 *     the items come from the database. In this case the object identity does
 *     not matter. Two objects are considered equivalent as long as their `id`
 *     property is same.
 *
 *     For example: `item in items | filter:searchText track by item.id` is a
 *     pattern that might be used to apply a filter to items in conjunction with
 *     a tracking expression.
 *
 * # Example:
 *
 *     <ul>
 *       <li ng-repeat="item in ['foo', 'bar', 'baz']">{{item}}</li>
 *     </ul>
 */

@NgDirective(
    children: NgAnnotation.TRANSCLUDE_CHILDREN,
    selector: '[ng-repeat]',
    map: const {'.': '@expression'})
class NgRepeatDirective extends AbstractNgRepeatDirective {
  NgRepeatDirective(BlockHole blockHole,
                    BoundBlockFactory boundBlockFactory,
                    Scope scope,
                    Parser parser,
                    AstParser astParser)
      : super(blockHole, boundBlockFactory, scope, parser, astParser);
}

/**
 * *EXPERIMENTAL:* This feature is experimental. We reserve the right to change
 * or delete it.
 *
 * [ng-shallow-repeat] is same as [ng-repeat] with some tradeoffs designed for
 * speed. Use [ng-shallow-repeat] when you expect that your items you are
 * repeating over do not change during the repeater lifetime.
 *
 * The shallow repeater introduces these changes:
 *
 *  * The repeater only fires if the identity of the list changes or if the list
 *  [length] property changes. This means that the repeater will still see
 *  additions and deletions but not changes to the array.
 *  * The child scopes for each item are created in the lazy mode
 *  (see [Scope.$new]). This means the scopes are effectively taken out of the
 *  digest cycle and will not update on changes to the model.
 *
 */
@deprecated
@NgDirective(
    children: NgAnnotation.TRANSCLUDE_CHILDREN,
    selector: '[ng-shallow-repeat]',
    map: const {'.': '@expression'})
//TODO(misko): delete me, since we can no longer do shallow digest.
class NgShallowRepeatDirective extends AbstractNgRepeatDirective {
  NgShallowRepeatDirective(BlockHole blockHole,
                          BoundBlockFactory boundBlockFactory,
                          Scope scope,
                          Parser parser,
                          AstParser astParser)
      : super(blockHole, boundBlockFactory, scope, parser, astParser)
  {
    print('DEPRECATED: [ng-shallow-repeat] use [ng-repeat]');
  }
}

abstract class AbstractNgRepeatDirective  {
  static RegExp _SYNTAX = new RegExp(r'^\s*(.+)\s+in\s+(.*?)\s*(\s+track\s+by\s+(.+)\s*)?(\s+lazily\s*)?$');
  static RegExp _LHS_SYNTAX = new RegExp(r'^(?:([\$\w]+)|\(([\$\w]+)\s*,\s*([\$\w]+)\))$');

  final BlockHole _blockHole;
  final BoundBlockFactory _boundBlockFactory;
  final Scope _scope;
  final Parser _parser;
  final AstParser _astParser;

  String _expression;
  String _valueIdentifier;
  String _keyIdentifier;
  String _listExpr;
  Map<dynamic, _Row> _rows = {};
  Function _trackByIdFn = (key, value, index) => value;
  Watch _watch = null;
  Iterable _lastCollection;

  AbstractNgRepeatDirective(this._blockHole, this._boundBlockFactory,
                            this._scope, this._parser, this._astParser);

  set expression(value) {
    _expression = value;
    if (_watch != null) _watch.remove();
    Match match = _SYNTAX.firstMatch(_expression);
    if (match == null) {
      throw "[NgErr7] ngRepeat error! Expected expression in form of '_item_ "
          "in _collection_[ track by _id_]' but got '$_expression'.";
    }
    _listExpr = match.group(2);
    var trackByExpr = match.group(4);
    if (trackByExpr != null) {
      Expression trackBy = _parser(trackByExpr);
      _trackByIdFn = ((key, value, index) {
        final trackByLocals = <String, Object>{};
        if (_keyIdentifier != null) trackByLocals[_keyIdentifier] = key;
        trackByLocals
            ..[_valueIdentifier] = value
            ..[r'$index'] = index
            ..[r'$id'] = (obj) => obj;
        return relaxFnArgs(trackBy.eval)(new ScopeLocals(_scope.context, trackByLocals));
      });
    }
    var assignExpr = match.group(1);
    match = _LHS_SYNTAX.firstMatch(assignExpr);
    if (match == null) {
      throw "[NgErr8] ngRepeat error! '_item_' in '_item_ in _collection_' "
          "should be an identifier or '(_key_, _value_)' expression, but got "
          "'$assignExpr'.";
    }
    _valueIdentifier = match.group(3);
    if (_valueIdentifier == null) _valueIdentifier = match.group(1);
    _keyIdentifier = match.group(2);

    _watch = _scope.watch(
        _astParser(_listExpr, collection: true),
        (CollectionChangeRecord collection, _) {
          //TODO(misko): we should take advantage of the CollectionChangeRecord!
          _onCollectionChange(collection == null ? [] : collection.iterable);
        }
    );
  }

  List<_Row> _computeNewRows(Iterable collection, trackById) {
    final newRowOrder = new List<_Row>(collection.length);
    // Same as lastBlockMap but it has the current state. It will become the
    // lastBlockMap on the next iteration.
    final newRows = <dynamic, _Row>{};
    // locate existing items
    for (var index = 0; index < newRowOrder.length; index++) {
      var value = collection.elementAt(index);
      trackById = _trackByIdFn(index, value, index);
      if (_rows.containsKey(trackById)) {
        var row = _rows[trackById];
        _rows.remove(trackById);
        newRows[trackById] = row;
        newRowOrder[index] = row;
      } else if (newRows.containsKey(trackById)) {
        // restore lastBlockMap
        newRowOrder.forEach((row) {
          if (row != null && row.startNode != null) _rows[row.id] = row;
        });
        // This is a duplicate and we need to throw an error
        throw "[NgErr50] ngRepeat error! Duplicates in a repeater are not "
            "allowed. Use 'track by' expression to specify unique keys. "
            "Repeater: $_expression, Duplicate key: $trackById";
      } else {
        // new never before seen row
        newRowOrder[index] = new _Row(trackById);
        newRows[trackById] = null;
      }
    }
    // remove existing items
    _rows.forEach((key, row) {
      row.block.remove();
      row.scope.destroy();
    });
    _rows = newRows;
    return newRowOrder;
  }

  _onCollectionChange(Iterable collection) {
    dom.Node previousNode = _blockHole.elements[0]; // current position of the node
    dom.Node nextNode;
    Scope childScope;
    Map childContext;
    Scope trackById;
    ElementWrapper cursor = _blockHole;

    List<_Row> newRowOrder = _computeNewRows(collection, trackById);

    for (var index = 0; index < collection.length; index++) {
      var value = collection.elementAt(index);
      _Row row = newRowOrder[index];

      if (row.startNode != null) {
        // if we have already seen this object, then we need to reuse the
        // associated scope/element
        childScope = row.scope;
        childContext = childScope.context as Map;

        nextNode = previousNode;
        do {
          nextNode = nextNode.nextNode;
        } while(nextNode != null);

        // existing item which got moved
        if (row.startNode != nextNode) row.block.moveAfter(cursor);
        previousNode = row.endNode;
      } else {
        // new item which we don't know about
        childScope = _scope.createChild(childContext = new PrototypeMap(_scope.context));
      }

      if (!identical(childScope.context[_valueIdentifier], value)) {
        childContext[_valueIdentifier] = value;
      }
      var first = (index == 0);
      var last = (index == collection.length - 1);
      childContext
          ..[r'$index'] = index
          ..[r'$first'] = first
          ..[r'$last'] = last
          ..[r'$middle'] = !first && !last
          ..[r'$odd'] = index & 1 == 1
          ..[r'$even'] = index & 1 == 0;

      if (row.startNode == null) {
        var block = _boundBlockFactory(childScope);
        _rows[row.id] = row
            ..block = block
            ..scope = childScope
            ..elements = block.elements
            ..startNode = row.elements[0]
            ..endNode = row.elements[row.elements.length - 1];
        block.insertAfter(cursor);
      }
      cursor = row.block;
    }
  }
}
