library angular.dom.selector_spec;

import '../_specs.dart';

@NgDirective(selector:'b')                    class _BElement{}
@NgDirective(selector:'.b')                   class _BClass{}
@NgDirective(selector:'[directive]')          class _DirectiveAttr{}
@NgDirective(selector:'[directive=d][foo=f]') class _DirectiveFooAttr{}
@NgDirective(selector:'b[directive]')         class _BElementDirectiveAttr{}
@NgDirective(selector:'[directive=value]')    class _DirectiveValueAttr{}
@NgDirective(selector:'b[directive=value]')   class _BElementDirectiveValue{}
@NgDirective(selector:':contains(/abc/)')     class _ContainsAbc{}
@NgDirective(selector:'[*=/xyz/]')            class _AttributeContainsXyz{}

@NgComponent(selector:'component')            class _Component{}
@NgDirective(selector:'[attribute]')          class _Attribute{}
@NgDirective(selector:'[structural]',
             transclude: true)                class _Structural{}

@NgNonBindable(selector:'[non-bindable]')     class _NonBindable{}

main() {
  describe('Selector', () {
    //TODO(karma): throwing error here gets ignored
    // throw new Error();

    var log;
    var selector;
    var element;
    var directives;

    beforeEach(() {
      // TODO(dart): why can't I have global noop?
      // TODO(dart): why does this not work?
      var noop = (Element e, String v) => null;

      log = [];
      directives = new DirectiveRegistry()
        ..register(_BElement)
        ..register(_BClass)
        ..register(_DirectiveAttr)
        ..register(_DirectiveFooAttr)
        ..register(_BElementDirectiveAttr)
        ..register(_DirectiveValueAttr)
        ..register(_BElementDirectiveValue)
        ..register(_ContainsAbc)
        ..register(_AttributeContainsXyz)
        ..register(_Component)
        ..register(_Attribute)
        ..register(_Structural)
        ..register(_NonBindable);

      selector = directiveSelectorFactory(directives);
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

    it('should match text', () {
      expect(selector(element = e('before-abc-after')),
        toEqualsDirectiveInfos([
          { "selector": ':contains(/abc/)', "value": 'before-abc-after',
            "element": element, "name": '#text'}
        ]));
    });

    it('should sort by priority', () {
      expect(selector(element = e(
          '<component attribute non-bindable structural></component>')),
      toEqualsDirectiveInfos([
          { "selector": "[non-bindable]", "value": "", "element": element },
          { "selector": "[structural]", "value": "", "element": element },
          { "selector": "[attribute]", "value": "", "element": element },
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
      for(var i = 0, ii = expected.length; i < ii; i++) {
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

