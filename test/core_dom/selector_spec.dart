library angular.dom.selector_spec;

import '../_specs.dart';

@Decorator(selector:'b')                    class _BElement{}
@Decorator(selector:'.b')                   class _BClass{}
@Decorator(selector:'[directive]')          class _DirectiveAttr{}
@Decorator(selector:'[wildcard-*]')         class _WildcardDirectiveAttr{}
@Decorator(selector:'[directive=d][foo=f]') class _DirectiveFooAttr{}
@Decorator(selector:'b[directive]')         class _BElementDirectiveAttr{}
@Decorator(selector:'[directive=value]')    class _DirectiveValueAttr{}
@Decorator(selector:'b[directive=value]')   class _BElementDirectiveValue{}
@Decorator(selector:':contains(/abc/)')     class _ContainsAbc{}
@Decorator(selector:'[*=/xyz/]')            class _AttributeContainsXyz{}

@Component(selector:'component')            class _Component{}
@Decorator(selector:'[attribute]')          class _Attribute{}
@Decorator(selector:'[structural]',
             children: Directive.TRANSCLUDE_CHILDREN)
                                              class _Structural{}

@Decorator(selector:'[ignore-children]',
             children: Directive.IGNORE_CHILDREN)
                                              class _IgnoreChildren{}

@Decorator(selector: '[my-model][required]')
@Decorator(selector: '[my-model][my-required]')
                                              class _TwoDirectives {}

@Decorator(selector: '[two-directives]') class _OneOfTwoDirectives {}
@Decorator(selector: '[two-directives]') class _TwoOfTwoDirectives {}


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
          ..bind(_Component)
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
                { "selector": 'b', "value": null, "element": element}
            ]));
      });

      it('should match directive on class', () {
        expect(selector(element = e('<div class="a b c"></div>')),
        toEqualsDirectiveInfos([
            { "selector": '.b', "value": null, "element": element}
        ]));
      });

      it('should match directive on [attribute]', () {
        expect(selector(element = e('<div directive=abc></div>')),
        toEqualsDirectiveInfos([
            { "selector": '[directive]', "value": 'abc', "element": element,
                "name": 'directive' }]));

        expect(selector(element = e('<div directive></div>')),
        toEqualsDirectiveInfos([
            { "selector": '[directive]', "value": '', "element": element,
                "name": 'directive' }]));
      });

      it('should match directive on element[attribute]', () {
        expect(selector(element = e('<b directive=abc></b>')),
        toEqualsDirectiveInfos([
            { "selector": 'b', "value": null, "element": element},
            { "selector": '[directive]', "value": 'abc', "element": element},
            { "selector": 'b[directive]', "value": 'abc', "element": element}
        ]));
      });

      it('should match directive on [attribute=value]', () {
        expect(selector(element = e('<div directive=value></div>')),
        toEqualsDirectiveInfos([
            { "selector": '[directive]', "value": 'value', "element": element},
            { "selector": '[directive=value]', "value": 'value', "element": element}
        ]));
      });

      it('should match directive on element[attribute=value]', () {
        expect(selector(element = e('<b directive=value></div>')),
        toEqualsDirectiveInfos([
            { "selector": 'b', "value": null, "element": element, "name": null},
            { "selector": '[directive]', "value": 'value', "element": element},
            { "selector": '[directive=value]', "value": 'value', "element": element},
            { "selector": 'b[directive]', "value": 'value', "element": element},
            { "selector": 'b[directive=value]', "value": 'value', "element": element}
        ]));
      });

      it('should match attributes', () {
        expect(selector(element = e('<div attr="before-xyz-after"></div>')),
        toEqualsDirectiveInfos([
            { "selector": '[*=/xyz/]', "value": 'attr=before-xyz-after',
                "element": element, "name": 'attr'}
        ]));
      });

      it('should match attribute names', () {
        expect(selector(element = e('<div wildcard-match=ignored></div>')),
        toEqualsDirectiveInfos([
            { "selector": '[wildcard-*]', "value": 'ignored',
                "element": element, "name": 'wildcard-match'}
        ]));
      });

      it('should sort by priority', () {
        TemplateElementBinder eb = selector(element = e(
            '<component attribute ignore-children structural></component>'));
        expect(eb,
          toEqualsDirectiveInfos(
            null,
            template: {"selector": "[structural]", "value": "", "element": element}));

        expect(eb.templateBinder,
        toEqualsDirectiveInfos(
            [
                { "selector": "[attribute]", "value": "", "element": element },
                { "selector": "[ignore-children]", "value": "", "element": element }

            ],
            component: { "selector": "component", "value": null, "element": element }));
      });

      it('should match on multiple directives', () {
        expect(selector(element = e('<div directive="d" foo="f"></div>')),
        toEqualsDirectiveInfos([
            { "selector": '[directive]', "value": 'd', "element": element},
            { "selector": '[directive=d][foo=f]', "value": 'f', "element": element}
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
            { "selector": '[two-directives]', "value": '', "element": element},
            { "selector": '[two-directives]', "value": '', "element": element}
        ]));
      });

      it('should collect on-* attributes', () {
        ElementBinder binder = selector(e('<input on-click="foo" on-blah="fad"></input>'));
        expect(binder.onEvents).toEqual({'on-click': 'foo', 'on-blah': 'fad'});
      });

      it('should collect bind-* attributes', () {
        ElementBinder binder = selector(e('<input bind-x="y" bind-z="yy"></input>'));
        expect(binder.bindAttrs).toEqual({'bind-x': 'y', 'bind-z': 'yy'});
      });
    });

    describe('matchText', () {
      beforeEach((DirectiveMap directives) {
        selector = (node) => directives.selector.matchText(node);
      });

      it('should match text', () {
        expect(selector(element = e('before-abc-after')),
        toEqualsDirectiveInfos([
            { "selector": ':contains(/abc/)', "value": 'before-abc-after',
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

  bool _refMatches(directiveRef, expectedMap) =>
    directiveRef.element == expectedMap['element'] &&
    directiveRef.annotation.selector == expectedMap['selector'] &&
    directiveRef.value == expectedMap['value'];


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
      pass = pass && _refMatches(binder.component, expectedComponent);
    }
    return pass;
  }
}

Matcher toEqualsDirectiveInfos(List<Map> directives, {Map template, Map component}) =>
  new DirectiveInfosMatcher(directives, expectedTemplate: template, expectedComponent: component);
