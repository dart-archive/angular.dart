library ng_non_bindable_spec;

import '../_specs.dart';
import '../_test_bed.dart';

main() {
  describe('NonBindableDirective', () {
    TestBed _;

    beforeEach(beforeEachTestBed((tb) => _ = tb));

    it('should set ignore all other markup/directives on the descendent nodes',
          inject((Scope scope, Injector injector, Compiler compiler) {
      var element = $('<div>' +
                      '  <span id="s1">{{a}}</span>' +
                      '  <span id="s2" ng-bind="b"></span>' +
                      '  <div foo="{{a}}" ng-non-bindable>' +
                      '    <span ng-bind="a"></span>{{b}}' +
                      '  </div>' +
                      '  <span id="s3">{{a}}</span>' +
                      '  <span id="s4" ng-bind="b"></span>' +
                      '</div>');
      compiler(element)(injector, element);
      scope.a = "one";
      scope.b = "two";
      scope.$digest();
      // Bindings not contained by ng-non-bindable should resolve.
      expect(element.find("#s1").text().trim()).toEqual('one');
      expect(element.find("#s2").text().trim()).toEqual('two');
      expect(element.find("#s3").text().trim()).toEqual('one');
      expect(element.find("#s4").text().trim()).toEqual('two');
      // Bindings contained by ng-non-bindable should be left alone.
      var nonBindableDiv = element.find("div");
      expect(nonBindableDiv.text().trim()).toEqual('{{b}}');
      // Bindings on the same node are processed.
      expect(nonBindableDiv.attr('foo')).toEqual('one');
    }));
  });
}
