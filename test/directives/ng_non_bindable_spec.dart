library ng_non_bindable_spec;

import '../_specs.dart';
import '../_test_bed.dart';

main() {
  describe('NonBindableDirective', () {
    TestBed _;

    beforeEach(beforeEachTestBed((tb) => _ = tb));

    it('should set ignore all other markup/directives on the element and its descendants',
          inject((Scope scope, Injector injector, Compiler compiler) {
      var element = $('<div>' +
                      '  {{a}}' +
                      '  <span ng-bind="b"></span>' +
                      '  <div foo="{{a}}" ng-non-bindable>' +
                      '    <span ng-bind="a"></span>{{b}}' +
                      '  </div>' +
                      '</div>');
      compiler(element)(injector, element);
      scope.a = "one";
      scope.b = "two";
      scope.$digest();
      var elements = element.contents();
      expect(elements.eq(0).text().trim()).toEqual('one');
      expect(elements.eq(1).text().trim()).toEqual('two');
      var nonBindableDiv = element.find("div");
      expect(nonBindableDiv.attr('foo')).toEqual('{{a}}');
      expect(nonBindableDiv.text().trim()).toEqual('{{b}}');
    }));
  });
}
