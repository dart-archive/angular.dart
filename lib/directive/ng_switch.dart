part of angular.directive;

/**
 * The ngSwitch directive is used to conditionally swap DOM structure on your
 * template based on a scope expression. Elements within ngSwitch but without
 * ngSwitchWhen or ngSwitchDefault directives will be preserved at the location
 * as specified in the template.
 *
 * The directive itself works similar to ngInclude, however, instead of
 * downloading template code (or loading it from the template cache), ngSwitch
 * simply choses one of the nested elements and makes it visible based on which
 * element matches the value obtained from the evaluated expression. In other
 * words, you define a container element (where you place the directive), place
 * an expression on the **ng-switch="..." attribute**, define any inner elements
 * inside of the directive and place a when attribute per element. The when
 * attribute is used to inform ngSwitch which element to display when the on
 * expression is evaluated. If a matching expression is not found via a when
 * attribute then an element with the default attribute is displayed.
 *
 * ## Example:
 *
 *     <ANY ng-switch="expression">
 *       <ANY ng-switch-when="matchValue1">...</ANY>
 *       <ANY ng-switch-when="matchValue2">...</ANY>
 *       <ANY ng-switch-default>...</ANY>
 *     </ANY>
 *
 * On child elements add:
 *
 * * `ngSwitchWhen`: the case statement to match against. If match then this
 *   case will be displayed. If the same match appears multiple times, all the
 *   elements will be displayed.
 * * `ngSwitchDefault`: the default case when no other case match. If there
 *   are multiple default cases, all of them will be displayed when no other
 *   case match.
 *
 * ## Example:
 *
 *     <div>
 *       <button ng-click="selection='settings'">Show Settings</button>
 *       <button ng-click="selection='home'">Show Home Span</button>
 *       <button ng-click="selection=''">Show default</button>
 *       <tt>selection={{selection}}</tt>
 *       <hr/>
 *       <div ng-switch="selection">
 *           <div ng-switch-when="settings">Settings Div</div>
 *           <div ng-switch-when="home">Home Span</div>
 *           <div ng-switch-default>default</div>
 *       </div>
 *     </div>
 */
@NgDirective(
    selector: '[ng-switch]',
    map: const {
      'ng-switch': '=>value',
      'change': '&onChange'
    },
    visibility: NgDirective.DIRECT_CHILDREN_VISIBILITY)
class NgSwitchDirective {
  Map<String, List<_Case>> cases = new Map<String, List<_Case>>();
  List<_BlockScopePair> currentBlocks = <_BlockScopePair>[];
  Function onChange;
  final Scope scope;

  NgSwitchDirective(this.scope) {
    cases['?'] = <_Case>[];
  }

  addCase(String value, BlockHole anchor, BoundBlockFactory blockFactory) {
    cases.putIfAbsent(value, () => <_Case>[]);
    cases[value].add(new _Case(anchor, blockFactory));
  }

  set value(val) {
    currentBlocks
        ..forEach((_BlockScopePair pair) {
          pair.block.remove();
          pair.scope.$destroy();
        })
        ..clear();

    val = '!$val';
    (cases.containsKey(val) ? cases[val] : cases['?'])
        .forEach((_Case caze) {
          Scope childScope = scope.$new();
          var block = caze.blockFactory(childScope)..insertAfter(caze.anchor);
          currentBlocks.add(new _BlockScopePair(block, childScope));
        });
    if (onChange != null) {
      onChange();
    }
  }
}

class _BlockScopePair {
  final Block block;
  final Scope scope;

  _BlockScopePair(this.block, this.scope);
}

class _Case {
  final BlockHole anchor;
  final BoundBlockFactory blockFactory;

  _Case(this.anchor, this.blockFactory);
}

@NgDirective(
    selector: '[ng-switch-when]',
    children: NgAnnotation.TRANSCLUDE_CHILDREN,
    map: const {'.': '@value'})
class NgSwitchWhenDirective {
  final NgSwitchDirective ngSwitch;
  final BlockHole hole;
  final BoundBlockFactory blockFactory;
  final Scope scope;

  NgSwitchWhenDirective(this.ngSwitch, this.hole, this.blockFactory, this.scope);

  set value(String value) => ngSwitch.addCase('!$value', hole, blockFactory);
}


@NgDirective(
    children: NgAnnotation.TRANSCLUDE_CHILDREN,
    selector: '[ng-switch-default]')
class NgSwitchDefaultDirective {

  NgSwitchDefaultDirective(NgSwitchDirective ngSwitch, BlockHole hole,
                           BoundBlockFactory blockFactory, Scope scope) {
    ngSwitch.addCase('?', hole, blockFactory);
  }
}
