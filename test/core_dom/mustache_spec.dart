library ng_mustache_spec;

import '../_specs.dart';

main() {
  describe('ng-mustache', () {
    TestBed _;
    beforeEachModule((Module module) {
      module.bind(_HelloFormatter);
    });
    beforeEach(inject((TestBed tb) => _ = tb));

    it('should replace {{}} in text', inject((Compiler compile,
        Scope rootScope, Injector injector, DirectiveMap directives)
    {
      var element = es('<div>{{name}}<span>!</span></div>');
      var template = compile(element, directives);

      rootScope.context['name'] = 'OK';
      var view = template(injector, rootScope);

      element = view.nodes;

      rootScope.apply();
      expect(element).toHaveText('OK!');
    }));

  });

  describe('NgShow', () {
    TestBed _;

    beforeEach(inject((TestBed tb) => _ = tb));

    it('should add/remove ng-hide class', () {
      var element = _.compile('<div bind-ng-show="isVisible"></div>');

      expect(element).not.toHaveClass('ng-hide');

      _.rootScope.apply(() {
        _.rootScope.context['isVisible'] = true;
      });
      expect(element).not.toHaveClass('ng-hide');

      _.rootScope.apply(() {
        _.rootScope.context['isVisible'] = false;
      });
      expect(element).toHaveClass('ng-hide');
    });

    it('should work together with ng-class', () {
      var element =
          _.compile('<div bind-ng-class="currentCls" bind-ng-show="isVisible"></div>');

      expect(element).not.toHaveClass('active');
      expect(element).not.toHaveClass('ng-hide');

      _.rootScope.apply(() {
        _.rootScope.context['currentCls'] = 'active';
      });
      expect(element).toHaveClass('active');
      expect(element).toHaveClass('ng-hide');

      _.rootScope.apply(() {
        _.rootScope.context['isVisible'] = true;
      });
      expect(element).toHaveClass('active');
      expect(element).not.toHaveClass('ng-hide');
    });
  });

}

@Formatter(name: 'hello')
class _HelloFormatter {
  call(String str) {
    return 'Hello, $str!';
  }
}
