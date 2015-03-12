library angular.dom.selector_spec;

import '../_specs.dart';

const _aBElement               = const Decorator(selector:'b'); 
const _aBClass                 = const Decorator(selector:'.b');
const _aDirectiveAttr          = const Decorator(selector:'[directive]');
const _aWildcardDirectiveAttr  = const Decorator(selector:'[wildcard-*]');
const _aDirectiveFooAttr       = const Decorator(selector:'[directive=d][foo=f]');
const _aBElementDirectiveAttr  = const Decorator(selector:'b[directive]');
const _aDirectiveValueAttr     = const Decorator(selector:'[directive=value]');
const _aBElementDirectiveValue = const Decorator(selector:'b[directive=value]');
const _aContainsAbc            = const Decorator(selector:':contains(/abc/)');
const _aAttributeContainsXyz   = const Decorator(selector:'[*=/xyz/]');
const _aAttribute              = const Decorator(selector:'[attribute]');
const _aCComponent             = const Component(selector:'component');
const _aStructural             = const Decorator(selector:'[structural]',
                                                 children: Directive.TRANSCLUDE_CHILDREN);
const _aIgnoreChildren         = const Decorator(selector:'[ignore-children]',
                                                 children: Directive.IGNORE_CHILDREN);
const _aTwoDirectives0         = const Decorator(selector: '[my-model][required]');
const _aTwoDirectives1         = const Decorator(selector: '[my-model][my-required]');
const _aOneOfTwoDirectives     = const Decorator(selector: '[two-directives]');
const _aTwoOfTwoDirectives     = const Decorator(selector: '[two-directives]');


@_aBElement               class _BElement{}
@_aBClass                 class _BClass{}
@_aDirectiveAttr          class _DirectiveAttr{}
@_aWildcardDirectiveAttr  class _WildcardDirectiveAttr{}
@_aDirectiveFooAttr       class _DirectiveFooAttr{}
@_aBElementDirectiveAttr  class _BElementDirectiveAttr{}
@_aDirectiveValueAttr     class _DirectiveValueAttr{}
@_aBElementDirectiveValue class _BElementDirectiveValue{}
@_aContainsAbc            class _ContainsAbc{}
@_aAttributeContainsXyz   class _AttributeContainsXyz{}
@_aCComponent             class _CComponent{}
@_aAttribute              class _Attribute{}
@_aStructural             class _Structural{}
@_aIgnoreChildren         class _IgnoreChildren{}
@_aOneOfTwoDirectives     class _OneOfTwoDirectives {}
@_aTwoOfTwoDirectives     class _TwoOfTwoDirectives {}

@_aTwoDirectives0
@_aTwoDirectives1         class _TwoDirectives {}

main() {
  describe('Selector', () {
    var log;
    var selector;
    var element;
    var directives;

    beforeEach(() => log = []);
    beforeEachModule((Module module) {
      module
          ..bind(_BElement)
          ..bind(_BClass)
          ..bind(_DirectiveAttr)
          ..bind(_WildcardDirectiveAttr)
          ..bind(_DirectiveFooAttr)
          ..bind(_BElementDirectiveAttr)
          ..bind(_DirectiveValueAttr)
          ..bind(_BElementDirectiveValue)
          ..bind(_ContainsAbc)
          ..bind(_AttributeContainsXyz)
          ..bind(_CComponent)
          ..bind(_Attribute)
          ..bind(_Structural)
          ..bind(_IgnoreChildren)
          ..bind(_TwoDirectives)
          ..bind(_OneOfTwoDirectives)
          ..bind(_TwoOfTwoDirectives);
    });

    describe('matchElement', () {
      beforeEach((DirectiveMap directives) {
        selector = (node) => directives.selector.matchElement(node);
      });

      it('should match directive on element', () {
        expect(
            selector(element = e('<b></b>')),
            toEqualsDirectiveInfos([
                { "selector": 'b', "value": null, "element": element, "annotation": _aBElement}
            ]));
      });

      it('should match directive on class', () {
        expect(selector(element = e('<div class="a b c"></div>')),
        toEqualsDirectiveInfos([
            { "selector": '.b', "value": null, "element": element, "annotation": _aBClass}
        ]));
      });

      it('should match directive on [attribute]', () {
        expect(selector(element = e('<div directive=abc></div>')),
        toEqualsDirectiveInfos([
            { "selector": '[directive]', "value": 'abc', "element": element,
                "name": 'directive', "annotation": _aDirectiveAttr }]));

        expect(selector(element = e('<div directive></div>')),
        toEqualsDirectiveInfos([
            { "selector": '[directive]', "value": '', "element": element,
                "name": 'directive', "annotation": _aDirectiveAttr }]));
      });

      it('should match directive on element[attribute]', () {
        expect(selector(element = e('<b directive=abc></b>')),
        toEqualsDirectiveInfos([
            { "selector": 'b', "value": null, "element": element, "annotation": _aBElement},
            { "selector": '[directive]', "value": 'abc', "element": element, "annotation": _aDirectiveAttr},
            { "selector": 'b[directive]', "value": 'abc', "element": element, "annotation": _aBElementDirectiveAttr}
        ]));
      });

      it('should match directive on [attribute=value]', () {
        expect(selector(element = e('<div directive=value></div>')),
        toEqualsDirectiveInfos([
            { "selector": '[directive]', "value": 'value', "element": element, "annotation": _aDirectiveAttr},
            { "selector": '[directive=value]', "value": 'value', "element": element, "annotation": _aDirectiveValueAttr}
        ]));
      });

      it('should match directive on element[attribute=value]', () {
        expect(selector(element = e('<b directive=value></div>')),
        toEqualsDirectiveInfos([
            { "selector": 'b', "value": null, "element": element, "name": null, "annotation": _aBElement},
            { "selector": '[directive]', "value": 'value', "element": element, "annotation": _aDirectiveAttr},
            { "selector": '[directive=value]', "value": 'value', "element": element, "annotation": _aDirectiveValueAttr},
            { "selector": 'b[directive]', "value": 'value', "element": element, "annotation": _aBElementDirectiveAttr},
            { "selector": 'b[directive=value]', "value": 'value', "element": element, "annotation": _aBElementDirectiveValue}
        ]));
      });

      it('should match attributes', () {
        expect(selector(element = e('<div attr="before-xyz-after"></div>')),
        toEqualsDirectiveInfos([
            { "selector": '[*=/xyz/]',
                "value": 'attr',
                "ast": '"before-xyz-after"',
                "element": element,
                "name": 'attr',
                "annotation": _aAttributeContainsXyz}
        ]));
      });

      it('should match attribute names', () {
        expect(selector(element = e('<div wildcard-match=ignored></div>')),
        toEqualsDirectiveInfos([
            { "selector": '[wildcard-*]', "value": 'ignored',
                "element": element, "name": 'wildcard-match', "annotation": _aWildcardDirectiveAttr}
        ]));
      });

      it('should sort by priority', async(() {
        TemplateElementBinder eb = selector(element = e(
            '<component attribute ignore-children structural></component>'));
        expect(eb,
          toEqualsDirectiveInfos(
            null,
            template: {"selector": "[structural]", "value": "", "element": element, "annotation": _aStructural}));

        expect(eb.templateBinder,
        toEqualsDirectiveInfos(
            [
                { "selector": "[attribute]", "value": "", "element": element, "annotation": _aAttribute },
                { "selector": "[ignore-children]", "value": "", "element": element, "annotation": _aIgnoreChildren }

            ],
            component: { "selector": "component", "value": null, "element": element, "annotation": _aCComponent }));
      }));

      it('should match on multiple directives', () {
        expect(selector(element = e('<div directive="d" foo="f"></div>')),
        toEqualsDirectiveInfos([
            { "selector": '[directive]', "value": 'd', "element": element, "annotation": _aDirectiveAttr},
            { "selector": '[directive=d][foo=f]', "value": 'f', "element": element, "annotation": _aDirectiveFooAttr}
        ]));
      });

      it('should match ng-model + required on the same element', () {
        expect(
            selector(element = e('<input type="text" ng-model="val" probe="i" required="true" />')),
            toEqualsDirectiveInfos([
                { "selector": '[ng-model]',                 "value": 'val',   "element": element},
                { "selector": '[probe]',                    "value": 'i',     "element": element},
                { "selector": '[ng-model][required]',       "value": 'true',  "element": element},
                { "selector": 'input[type=text][ng-model]', "value": 'val',   "element": element}
            ]));
      });

      it('should match two directives', () {
        expect(
            selector(element = e('<input type="text" my-model="val" required my-required />')),
            toEqualsDirectiveInfos([
                { "selector": '[my-model][required]',    "value": '', "element": element},
                { "selector": '[my-model][my-required]', "value": '', "element": element}
            ]));
      });

      it('should match an two directives with the same selector', () {
        expect(selector(element = e('<div two-directives></div>')),
        toEqualsDirectiveInfos([
            { "selector": '[two-directives]', "value": '', "element": element, "annotation": _aOneOfTwoDirectives},
            { "selector": '[two-directives]', "value": '', "element": element, "annotation": _aTwoOfTwoDirectives}
        ]));
      });

      it('should collect on-* attributes', () {
        ElementBinder binder = selector(e('<input on-click="foo" on-blah="fad"></input>'));
        expect(binder.onEvents).toEqual({'on-click': 'foo', 'on-blah': 'fad'});
      });

      it('should collect bind-* attributes', () {
        ElementBinder binder = selector(e('<input bind-x="y" bind-z="yy"></input>'));
        expect(binder.bindAttrs.keys.length).toEqual(2);
        expect(binder.bindAttrs['x'].expression).toEqual('y');
        expect(binder.bindAttrs['z'].expression).toEqual('yy');
      });
    });

    describe('matchText', () {
      beforeEach((DirectiveMap directives) {
        selector = (node) => directives.selector.matchText(node);
      });

      it('should match text', () {
        expect(selector(element = e('before-abc-after')),
        toEqualsDirectiveInfos([
            { "selector": ':contains(/abc/)',
                "value": 'before-abc-after',
                "ast": '"before-abc-after"',
                "element": element, "name": '#text'}
        ]));
      });
    });

    describe('matchComment', () {
      beforeEach((DirectiveMap directives) {
        selector = (node) => directives.selector.matchComment(node);
      });

      it('should match comments', () {
        expect(selector(element = e('<!-- nothing here -->')),
        toEqualsDirectiveInfos([]));
      });
    });
  });
}


class DirectiveInfosMatcher extends Matcher {
  final List<Map> expected;
  Map expectedTemplate;
  Map expectedComponent;

  safeToString(a) => "${a['element']} ${a['selector']} ${a['value']}";
  safeToStringRef(a) => "${a.element} ${a.annotation.selector} ${a.value}";

  DirectiveInfosMatcher(this.expected, {this.expectedTemplate, this.expectedComponent}) {
    if (expected != null) {
      expected.sort((a, b) => Comparable.compare(safeToString(a), safeToString(b)));
    }
  }

  Description describe(Description description) =>
      description..add(expected.toString());

  bool _refMatches(DirectiveRef directiveRef, Map expectedMap) =>
    directiveRef.element == expectedMap['element'] &&
    directiveRef.annotation.selector == expectedMap['selector'] &&
    directiveRef.value == expectedMap['value'] &&
    (expectedMap['annotation'] == null || directiveRef.annotation == expectedMap['annotation']) &&
    (directiveRef.valueAST == null || directiveRef.valueAST.expression == expectedMap['ast']);


  bool matches(ElementBinder binder, matchState) {
    var pass = true;
    if (expected != null) {
      var decorators = new List.from(binder.decorators)
          ..sort((a, b) => Comparable.compare(safeToStringRef(a), safeToStringRef(b)));
      pass = expected.length == decorators.length;
      for (var i = 0, ii = expected.length; i < ii; i++) {
        DirectiveRef directiveRef = decorators[i];
        var expectedMap = expected[i];
        pass = pass && _refMatches(directiveRef, expectedMap);
      }
    }
    if (pass && expectedTemplate != null) {
      pass = pass && _refMatches((binder as TemplateElementBinder).template, expectedTemplate);
    }
    if (pass && expectedComponent != null) {
      pass = pass && _refMatches(binder.componentData.ref, expectedComponent);
    }
    return pass;
  }
}

Matcher toEqualsDirectiveInfos(List<Map> directives, {Map template, Map component}) =>
  new DirectiveInfosMatcher(directives, expectedTemplate: template, expectedComponent: component);
