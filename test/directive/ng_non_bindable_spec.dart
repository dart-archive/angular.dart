library ng_non_bindable_spec;

import '../_specs.dart';

main() {
  describe('NonBindableDirective', () {
    TestBed _;

    beforeEach((TestBed tb) => _ = tb);

    it('should set ignore all other markup/directives on the descendent nodes',
          (Scope scope, Injector injector, Compiler compiler, DirectiveMap directives) {
      Element element = e('<div>' +
                      '  <span id="s1">{{a}}</span>' +
                      '  <span id="s2" ng-bind="b"></span>' +
                      '  <div foo="{{a}}" ng-non-bindable>' +
                      '    <span ng-bind="a"></span>{{b}}' +
                      '  </div>' +
                      '  <span id="s3">{{a}}</span>' +
                      '  <span id="s4" ng-bind="b"></span>' +
                      '</div>');
      compiler([element], directives)(injector, [element]);
      scope.context['a'] = "one";
      scope.context['b'] = "two";
      scope.apply();
      // Bindings not contained by ng-non-bindable should resolve.
      expect(element.querySelector("#s1").text.trim()).toEqual('one');
      expect(element.querySelector("#s2").text.trim()).toEqual('two');
      expect(element.querySelector("#s3").text.trim()).toEqual('one');
      expect(element.querySelector("#s4").text.trim()).toEqual('two');
      // Bindings contained by ng-non-bindable should be left alone.
      var nonBindableDiv = element.querySelector("div");
      expect(nonBindableDiv).toHaveHtml('<span ng-bind="a"></span>{{b}}');
      expect(nonBindableDiv.text.trim()).toEqual('{{b}}');
      // Bindings on the same node are processed.
      expect(nonBindableDiv.attributes['foo']).toEqual('one');
    });
  });
}
