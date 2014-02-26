library angular.dom.selector_spec;

import '../_specs.dart';

@NgDirective(selector:'b')                    class _BElement{}
@NgDirective(selector:'.b')                   class _BClass{}
@NgDirective(selector:'[directive]')          class _DirectiveAttr{}
@NgDirective(selector:'[wildcard-*]')         class _WildcardDirectiveAttr{}
@NgDirective(selector:'[directive=d][foo=f]') class _DirectiveFooAttr{}
@NgDirective(selector:'b[directive]')         class _BElementDirectiveAttr{}
@NgDirective(selector:'[directive=value]')    class _DirectiveValueAttr{}
@NgDirective(selector:'b[directive=value]')   class _BElementDirectiveValue{}
@NgDirective(selector:':contains(/abc/)')     class _ContainsAbc{}
@NgDirective(selector:'[*=/xyz/]')            class _AttributeContainsXyz{}

@NgComponent(selector:'component')            class _Component{}
@NgDirective(selector:'[attribute]')          class _Attribute{}
@NgDirective(selector:'[structural]',
             children: NgAnnotation.TRANSCLUDE_CHILDREN)
                                              class _Structural{}

@NgDirective(selector:'[ignore-children]',
             children: NgAnnotation.IGNORE_CHILDREN)
                                              class _IgnoreChildren{}

@NgDirective(selector: '[my-model][required]')
@NgDirective(selector: '[my-model][my-required]')
                                              class _TwoDirectives {}

@NgDirective(selector: '[two-directives]') class _OneOfTwoDirectives {}
@NgDirective(selector: '[two-directives]') class _TwoOfTwoDirectives {}


main() {
  describe('Selector', () {
    //TODO(karma): throwing error here gets ignored
    // throw new Error();

    var log;
    var selector;
    var element;
    var directives;

    beforeEach(() => log = []);
    beforeEach(module((Module module) {
      module
        ..type(_BElement)
        ..type(_BClass)
        ..type(_DirectiveAttr)
        ..type(_WildcardDirectiveAttr)
        ..type(_DirectiveFooAttr)
        ..type(_BElementDirectiveAttr)
        ..type(_DirectiveValueAttr)
        ..type(_BElementDirectiveValue)
        ..type(_ContainsAbc)
        ..type(_AttributeContainsXyz)
        ..type(_Component)
        ..type(_Attribute)
        ..type(_Structural)
        ..type(_IgnoreChildren)
        ..type(_TwoDirectives)
        ..type(_OneOfTwoDirectives)
        ..type(_TwoOfTwoDirectives);
    }));
    beforeEach(inject((DirectiveMap directives) {
      selector = directiveSelectorFactory(directives);
    }));

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

    it('should match text', () {
      expect(selector(element = e('before-abc-after')),
        toEqualsDirectiveInfos([
          { "selector": ':contains(/abc/)', "value": 'before-abc-after',
            "element": element, "name": '#text'}
        ]));
    });

    it('should sort by priority', () {
      expect(selector(element = e(
          '<component attribute ignore-children structural></component>')),
      toEqualsDirectiveInfos([
          { "selector": "[structural]", "value": "", "element": element },
          { "selector": "[attribute]", "value": "", "element": element },
          { "selector": "[ignore-children]", "value": "", "element": element },
          { "selector": "component", "value": null, "element": element }
      ]));
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
  });
}


class DirectiveInfosMatcher extends Matcher {
  List<Map> expected;

  DirectiveInfosMatcher(this.expected);

  Description describe(Description description) {
    description.add(expected.toString());
    return description;
  }

  bool matches(directiveRefs, matchState) {
    var pass = expected.length == directiveRefs.length;
    if (pass) {
      for (var i = 0, ii = expected.length; i < ii; i++) {
        DirectiveRef directiveRef = directiveRefs[i];
        var expectedMap = expected[i];

        pass = pass &&
          directiveRef.element == expectedMap['element'] &&
          directiveRef.annotation.selector == expectedMap['selector'] &&
          directiveRef.value == expectedMap['value'];
      }
    }
    return pass;
  }
}

Matcher toEqualsDirectiveInfos(List<Map> directives) {
  return new DirectiveInfosMatcher(directives);
}

