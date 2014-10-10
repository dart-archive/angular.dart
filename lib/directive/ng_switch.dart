part of angular.directive;

/**
 * Conditionally swaps DOM structure on your template, based on a scope expression. `Selector:
 * [ng-switch]`
 *
 * Elements within ngSwitch but without ngSwitchWhen or ngSwitchDefault directives will be
 * preserved at the location as specified in the template.
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
 *   case matches.
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
@Decorator(
    selector: '[ng-switch]',
    map: const {
      'ng-switch': '=>value',
      'change': '&onChange'
    },
    visibility: Visibility.DIRECT_CHILD)
class NgSwitch {
  final _cases = <String, List<_Case>>{'?': <_Case>[]};
  final _currentViews = <_ViewScopePair>[];
  Function onChange;
  final Scope _scope;

  NgSwitch(this._scope);

  void addCase(String value, ViewPort anchor, BoundViewFactory viewFactory) {
    _cases.putIfAbsent(value, () => <_Case>[]).add(new _Case(anchor, viewFactory));
  }

  set value(val) {
    _currentViews
        ..forEach((_ViewScopePair pair) {
          pair.port.remove(pair.view);
        })
        ..clear();

    val = '!$val';
    (_cases.containsKey(val) ? _cases[val] : _cases['?'])
        .forEach((_Case caze) {
          Scope childScope = _scope.createProtoChild();
          var view = caze.viewFactory(childScope);
          caze.anchor.insert(view);
          _currentViews.add(new _ViewScopePair(view, caze.anchor,
            childScope));
        });
    if (onChange != null) {
      onChange();
    }
  }
}

class _ViewScopePair {
  final View view;
  final ViewPort port;
  final Scope scope;

  _ViewScopePair(this.view, this.port, this.scope);
}

class _Case {
  final ViewPort anchor;
  final BoundViewFactory viewFactory;

  _Case(this.anchor, this.viewFactory);
}
/**
 * Specifies a case statement to match against when as part of an `ng-switch` statement. `Selector:
 * [ng-switch-when]`
 *
 * If the same match appears multiple times, all the elements will be displayed.
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

@Decorator(
    selector: '[ng-switch-when]',
    children: Directive.TRANSCLUDE_CHILDREN,
    map: const {'.': '@value'})
class NgSwitchWhen {
  final NgSwitch _ngSwitch;
  final ViewPort _port;
  final BoundViewFactory _viewFactory;

  NgSwitchWhen(this._ngSwitch, this._port, this._viewFactory);

  void set value(String value) => _ngSwitch.addCase('!$value', _port, _viewFactory);
}
/**
 * Specifies a default case to use when no other case statement matches as part of an `ng-switch`
 * statement. `Selector: [ng-switch-default]`
 *
 * If there are multiple default cases, all of them will be displayed when no other case matches.
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
@Decorator(
    children: Directive.TRANSCLUDE_CHILDREN,
    selector: '[ng-switch-default]')
class NgSwitchDefault {
  NgSwitchDefault(NgSwitch ngSwitch, ViewPort port, BoundViewFactory viewFactory) {
    ngSwitch.addCase('?', port, viewFactory);
  }
}
