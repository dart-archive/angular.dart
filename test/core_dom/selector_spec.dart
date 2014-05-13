library angular.dom.selector_spec;

import '../_specs.dart';
import 'package:angular/core_dom/node_property_binder.dart';

@Decorator(selector:'b')                    class _BElement{}
@Decorator(selector:'.b')                   class _BClass{}
@Decorator(selector:'[directive]')          class _DirectiveAttr{}
@Decorator(selector:'[directive=d][foo=f]') class _DirectiveFooAttr{}
@Decorator(selector:'b[directive]')         class _BElementDirectiveAttr{}
@Decorator(selector:'[directive=value]')    class _DirectiveValueAttr{}
@Decorator(selector:'b[directive=value]')   class _BElementDirectiveValue{}

@Component(selector:'component')            class _Component{}
@Decorator(selector:'[attribute]')          class _Attribute{}
@Decorator(selector:'[structural]',
             children: Directive.TRANSCLUDE_CHILDREN)
                                              class _Structural{}

@Decorator(selector:'[ignore-children]',
             children: Directive.IGNORE_CHILDREN)
                                              class _IgnoreChildren{}

@Decorator(selector: '[my-model][required],[my-model][my-required]')
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
          ..bind(_DirectiveFooAttr)
          ..bind(_BElementDirectiveAttr)
          ..bind(_DirectiveValueAttr)
          ..bind(_BElementDirectiveValue)
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
                toEqualsDirectives([_BElement]));
      });

      it('should match directive on class', () {
        expect(selector(element = e('<div class="a b c"></div>')),
            toEqualsDirectives([_BClass]));
      });

      it('should match directive on [attribute]', () {
        expect(selector(element = e('<div directive=abc></div>')),
            toEqualsDirectives([_DirectiveAttr]));

        expect(selector(element = e('<div directive></div>')),
            toEqualsDirectives([_DirectiveAttr]));
      });

      it('should match directive on element[attribute]', () {
        expect(selector(element = e('<b directive=abc></b>')),
            toEqualsDirectives([_BElement, _DirectiveAttr, _BElementDirectiveAttr]));
      });

      it('should match directive on [attribute=value]', () {
        expect(selector(element = e('<div directive=value></div>')),
            toEqualsDirectives([_DirectiveAttr, _DirectiveValueAttr]));
      });

      it('should match directive on element[attribute=value]', () {
        expect(selector(element = e('<b directive=value></div>')), toEqualsDirectives(
            [ _BElement, _DirectiveAttr, _DirectiveValueAttr, _BElementDirectiveAttr,
              _BElementDirectiveValue]));
      });

      it('should match attributes', () {
        expect(selector(element = e('<div attr="before-xyz-after"></div>')),
            toEqualsDirectives([]));
        expect(element.attributes).toEqual({'attr': 'before-xyz-after'});
      });

      it('should sort by priority', () {
        NodeBinder eb = selector(element = e(
            '<component attribute ignore-children structural></component>'));
        expect(eb, toEqualsDirectives([_Structural]));

        expect(eb.transcludeBinder, toEqualsDirectives(
            [_Component, _Attribute, _IgnoreChildren]));
      });

      it('should match on multiple directives', () {
        expect(selector(element = e('<div directive="d" foo="f"></div>')),
            toEqualsDirectives([_DirectiveAttr, _DirectiveFooAttr]));
      });

      it('should match ng-model + required on the same element', () {
        expect(
            selector(element = e('<input type="text" ng-model="val" probe="i" required="true" />')),
            toEqualsDirectives([NgModel, Probe, NgModelRequiredValidator, InputTextLike]));
      });

      it('should match two directives', () {
        expect(
            selector(e('<input type="text" my-model="val" required my-required />')),
            toEqualsDirectives([_TwoDirectives]));
      });

      it('should match an two directives with the same selector', () {
        expect(selector(element = e('<div two-directives></div>')),
            toEqualsDirectives([_OneOfTwoDirectives, _TwoOfTwoDirectives]));
      });

      it('should collect on-* attributes', () {
        NodeBinder binder = selector(e('<input on-click="foo" on-blah="fad"></input>'));
        expect(binder.onEvents).toEqual(['click', 'blah']);
      });

      it('should collect bind-* attributes', () {
        NodeBinder binder = selector(e('<input bind-x="y" bind-z="yy"></input>'));
        expect(binder.nodePropertyBinders.map((b) => '${b.property}: ${b.bindExp}'))
            .toEqual(['x: y', 'z: yy']);
      });
    });
  });
}


class DirectiveInfosMatcher extends Matcher {
  Set<Type> expected;
  Map expectedTemplate;
  Map expectedComponent;

  safeToString(a) => "${a['element']} ${a['selector']} ${a['value']}";
  safeToStringRef(a) => "${a.element} ${a.annotation.selector} ${a.value}";

  DirectiveInfosMatcher(expected, {this.expectedTemplate, this.expectedComponent}) {
    if (expected != null) {
      this.expected = new Set.from(expected);
    }
  }

  Description describe(Description description) =>
      description..add(expected.toString());

  bool _refMatches(directiveRef, expectedMap) =>
    directiveRef.element == expectedMap['element'] &&
    directiveRef.annotation.selector == expectedMap['selector'] &&
    directiveRef.value == expectedMap['value'];


  bool matches(NodeBinder binder, matchState) {
    var pass = true;
    if (expected != null) {
      var decorators = new Set.from(binder.directiveTypes);
      pass = expected.length == decorators.length;
      decorators.forEach((actualType) {
        pass = pass && expected.contains(actualType);
      });
    }
    if (pass && expectedTemplate != null) {
      pass = pass && _refMatches(binder.template, expectedTemplate);
    }
    if (pass && expectedComponent != null) {
      pass = pass && _refMatches(binder.component, expectedComponent);
    }
    return pass;
  }
}

Matcher toEqualsDirectives(List<Type> directives, {Map template, Map component}) =>
  new DirectiveInfosMatcher(directives, expectedTemplate: template, expectedComponent: component);
