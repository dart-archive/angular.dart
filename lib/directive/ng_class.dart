part of angular.directive;

/**
 * The `ngClass` allows you to set CSS classes on HTML an element, dynamically,
 * by databinding an expression that represents all classes to be added.
 *
 * The directive won't add duplicate classes if a particular class was
 * already set.
 *
 * When the expression changes, the previously added classes are removed and
 * only then the new classes are added.
 *
 * The result of the expression evaluation can be a string representing space
 * delimited class names, an array, or a map of class names to boolean values.
 * In the case of a map, the names of the properties whose values are truthy
 * will be added as css classes to the element.
 *
 * ##Examples
 *
 * index.html:
 *
 *     <!--
 *       The map syntax:
 *
 *           ng-class="{key1: value1, key2: value2, ...}"
 *
 *       results in only adding CSS classes represented by the map keys when
 *       the corresponding value expressions are truthy.
 *
 *       To use a css class that contains a hyphen (such as line-through in this
 *       example), you should quote the name to make it a valid map key.  You
 *       may, of course, quote all the map keys for consistency.
 *     -->
 *     <p ng-class="{'line-through': strike, bold: bold, red: red}">Map Syntax Example</p>
 *     <input type="checkbox" ng-model="bold"> bold
 *     <input type="checkbox" ng-model="strike"> strike
 *     <input type="checkbox" ng-model="red"> red
 *     <hr>
 *
 *     <p ng-class="style">Using String Syntax</p>
 *     <input type="text" ng-model="style" placeholder="Type: bold strike red">
 *     <hr>
 *
 *     <p ng-class="[style1, style2, style3]">Using Array Syntax</p>
 *     <input ng-model="style1" placeholder="Type: bold"><br>
 *     <input ng-model="style2" placeholder="Type: strike"><br>
 *     <input ng-model="style3" placeholder="Type: red"><br>
 *
 * style.css:
 *
 *     .strike {
 *       text-decoration: line-through;
 *     }
 *     .line-through {
 *       text-decoration: line-through;
 *     }
 *     .bold {
 *         font-weight: bold;
 *     }
 *     .red {
 *         color: red;
 *     }
 *
 */
@Decorator(
    selector: '[ng-class]',
    map: const {'ng-class': '@valueExpression'},
    exportExpressionAttrs: const ['ng-class'])
class NgClass extends _NgClassBase {
  NgClass(NgElement ngElement, Scope scope, NodeAttrs nodeAttrs)
      : super(ngElement, scope, nodeAttrs);
}

/**
 * The `ngClassOdd` and `ngClassEven` directives work exactly as
 * {@link ng.directive:ngClass ngClass}, except it works in
 * conjunction with `ngRepeat` and takes affect only on odd (even) rows.
 *
 * This directive can be applied only within a scope of an `ngRepeat`.
 *
 * ##Examples
 *
 * index.html:
 *
 *     <li ng-repeat="name in ['John', 'Mary', 'Cate', 'Suz']">
 *       <span ng-class-odd="'odd'" ng-class-even="'even'">
 *         {{name}}
 *       </span>
 *     </li>
 *
 * style.css:
 *
 *     .odd {
 *       color: red;
 *     }
 *     .even {
 *       color: blue;
 *     }
 */
@Decorator(
    selector: '[ng-class-odd]',
    map: const {'ng-class-odd': '@valueExpression'},
    exportExpressionAttrs: const ['ng-class-odd'])
class NgClassOdd extends _NgClassBase {
  NgClassOdd(NgElement ngElement, Scope scope, NodeAttrs nodeAttrs)
      : super(ngElement, scope, nodeAttrs, 0);
}

/**
 * The `ngClassOdd` and `ngClassEven` directives work exactly as
 * {@link ng.directive:ngClass ngClass}, except it works in
 * conjunction with `ngRepeat` and takes affect only on odd (even) rows.
 *
 * This directive can be applied only within a scope of an `ngRepeat`.
 *
 * ##Examples
 *
 * index.html:
 *
 *     <li ng-repeat="name in ['John', 'Mary', 'Cate', 'Suz']">
 *       <span ng-class-odd="'odd'" ng-class-even="'even'">
 *         {{name}}
 *       </span>
 *     </li>
 *
 * style.css:
 *
 *     .odd {
 *       color: red;
 *     }
 *     .even {
 *       color: blue;
 *     }
 */
@Decorator(
    selector: '[ng-class-even]',
    map: const {'ng-class-even': '@valueExpression'},
    exportExpressionAttrs: const ['ng-class-even'])
class NgClassEven extends _NgClassBase {
  NgClassEven(NgElement ngElement, Scope scope, NodeAttrs nodeAttrs)
      : super(ngElement, scope, nodeAttrs, 1);
}

abstract class _NgClassBase {
  final NgElement _ngElement;
  final Scope _scope;
  final int _mode;
  Watch _watchExpression;
  Watch _watchPosition;
  var _previousSet = new Set<String>();
  var _currentSet = new Set<String>();
  bool _first = true;

  _NgClassBase(this._ngElement, this._scope, NodeAttrs nodeAttrs,
               [this._mode = null])
  {
    var prevCls;

    nodeAttrs.observe('class', (String cls) {
      if (prevCls != cls) {
        prevCls = cls;
        _applyChanges(_scope.context[r'$index']);
      }
    });
  }

  set valueExpression(expression) {
    if (_watchExpression != null) _watchExpression.remove();
    _watchExpression = _scope.watch(expression, (v, _) {
        _computeChanges(v);
        _applyChanges(_scope.context[r'$index']);
      },
      canChangeModel: false,
      collection: true);

    if (_mode != null) {
      if (_watchPosition != null) _watchPosition.remove();
      _watchPosition = _scope.watch(r'$index', (idx, previousIdx) {
        var mod = idx % 2;
        if (previousIdx == null || mod != previousIdx % 2) {
          if (mod == _mode) {
            _currentSet.forEach((cls) => _ngElement.addClass(cls));
          } else {
            _previousSet.forEach((cls) => _ngElement.removeClass(cls));
          }
        }
      }, canChangeModel: false);
    }
  }

  void _computeChanges(value) {
    if (value is CollectionChangeRecord) {
      _computeCollectionChanges(value, _first);
    } else if (value is MapChangeRecord) {
      _computeMapChanges(value, _first);
    } else {
      if (value is String) {
        _currentSet..clear()..addAll(value.split(' '));
      } else if (value == null) {
        _currentSet.clear();
      } else {
        throw 'ng-class expects expression value to be List, Map or String, '
              'got $value';
      }
    }

    _first = false;
  }

  // todo(vicb) refactor once GH-774 gets fixed
  void _computeCollectionChanges(CollectionChangeRecord changes, bool first) {
    if (first) {
      changes.iterable.forEach((cls) {
        _currentSet.add(cls);
      });
    } else {
      changes.forEachAddition((AddedItem a) {
        _currentSet.add(a.item);
      });
      changes.forEachRemoval((RemovedItem r) {
        _currentSet.remove(r.item);
      });
    }
  }

  // todo(vicb) refactor once GH-774 gets fixed
  _computeMapChanges(MapChangeRecord changes, first) {
    if (first) {
      changes.map.forEach((cls, active) {
        if (toBool(active)) _currentSet.add(cls);
      });
    } else {
      changes.forEachChange((ChangedKeyValue kv) {
        var cls = kv.key;
        var active = toBool(kv.currentValue);
        var wasActive = toBool(kv.previousValue);
        if (active != wasActive) {
          if (active) {
            _currentSet.add(cls);
          } else {
            _currentSet.remove(cls);
          }
        }
      });
      changes.forEachAddition((AddedKeyValue kv) {
        if (toBool(kv.currentValue)) _currentSet.add(kv.key);
      });
      changes.forEachRemoval((RemovedKeyValue kv) {
        if (toBool(kv.previousValue)) _currentSet.remove(kv.key);
      });
    }
  }

  _applyChanges(index) {
    if (_mode == null || (index != null && index % 2 == _mode)) {
      _previousSet
          .where((cls) => cls != null)
          .forEach((cls) => _ngElement.removeClass(cls));
      _currentSet
          .where((cls) => cls != null)
          .forEach((cls) => _ngElement.addClass(cls));
    }

    _previousSet = _currentSet.toSet();
  }
}
