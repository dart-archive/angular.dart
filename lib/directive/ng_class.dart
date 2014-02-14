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
@NgDirective(
    selector: '[ng-class]',
    map: const {'ng-class': '@valueExpression'},
    exportExpressionAttrs: const ['ng-class'])
class NgClassDirective extends _NgClassBase {
  NgClassDirective(dom.Element element, Scope scope, NodeAttrs attrs, AstParser parser)
      : super(element, scope, null, attrs, parser);
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
@NgDirective(
    selector: '[ng-class-odd]',
    map: const {'ng-class-odd': '@valueExpression'},
    exportExpressionAttrs: const ['ng-class-odd'])
class NgClassOddDirective extends _NgClassBase {
  NgClassOddDirective(dom.Element element, Scope scope, NodeAttrs attrs, AstParser parser)
      : super(element, scope, 0, attrs, parser);
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
@NgDirective(
    selector: '[ng-class-even]',
    map: const {'ng-class-even': '@valueExpression'},
    exportExpressionAttrs: const ['ng-class-even'])
class NgClassEvenDirective extends _NgClassBase {
  NgClassEvenDirective(dom.Element element, Scope scope, NodeAttrs attrs, AstParser parser)
      : super(element, scope, 1, attrs, parser);
}

abstract class _NgClassBase {
  final dom.Element element;
  final Scope scope;
  final int mode;
  final NodeAttrs nodeAttrs;
  final AstParser _parser;
  var previousSet = [];
  var currentSet = [];

  _NgClassBase(this.element, this.scope, this.mode, this.nodeAttrs, this._parser) {
    var prevClass;

    nodeAttrs.observe('class', (String newValue) {
      if (prevClass != newValue) {
        prevClass = newValue;
        _handleChange(scope.context[r'$index']);
      }
    });
  }

  set valueExpression(currentExpression) {
    // this should be called only once, so we don't worry about cleaning up
    // watcher registrations.
    scope.watch(
        _parser(currentExpression, collection: true),
        (current, _) {
          currentSet = _flatten(current);
          _handleChange(scope.context[r'$index']);
        },
        readOnly: true
    );
    if (mode != null) {
      scope.watch(_parser(r'$index'), (index, oldIndex) {
        var mod = index % 2;
        if (oldIndex == null || mod != oldIndex % 2) {
          if (mod == mode) {
            element.classes.addAll(currentSet);
          } else {
            element.classes.removeAll(previousSet);
          }
        }
      }, readOnly: true);
    }
  }

  _handleChange(index) {
    if (mode == null || (index != null && index % 2 == mode)) {
      element.classes..removeAll(previousSet)..addAll(currentSet);
    }

    previousSet = currentSet;
  }

  static List<String> _flatten(classes) {
    if (classes == null) return [];
    if (classes is CollectionChangeRecord) {
      classes = (classes as CollectionChangeRecord).iterable.toList();
    }
    if (classes is List) {
      return classes.where((String e) => e != null && e.isNotEmpty)
                    .toList(growable: false);
    }
    if (classes is MapChangeRecord) {
      classes = (classes as MapChangeRecord).map;
    }
    if (classes is Map) {
      return classes.keys.where((key) => toBool(classes[key])).toList();
    }
    if (classes is String) return classes.split(' ');
    throw 'ng-class expects expression value to be List, Map or String, got $classes';
  }
}
