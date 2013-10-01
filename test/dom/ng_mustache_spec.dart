library ng_mustache_spec;

import '../_specs.dart';
import '../_test_bed.dart';

main() {
  describe('ng-mustache', () {
    it('should replace {{}} in text', inject((Compiler $compile, Scope $rootScope, Injector injector) {
      var element = $('<div>{{name}}<span>!</span></div>');
      var template = $compile(element);

      $rootScope.name = 'OK';
      var block = template(injector);

      element = $(block.elements);

      expect(element.text()).toEqual('!');
      $rootScope.$digest();
      expect(element.text()).toEqual('OK!');
    }));


    it('should replace {{}} in attribute', inject((Compiler $compile, Scope $rootScope, Injector injector) {
      var element = $('<div some-attr="{{name}}" other-attr="{{age}}"></div>');
      var template = $compile(element);

      $rootScope.name = 'OK';
      $rootScope.age = 23;
      var block = template(injector);

      element = $(block.elements);

      expect(element.attr('some-attr')).toEqual('');
      expect(element.attr('other-attr')).toEqual('');
      $rootScope.$digest();
      expect(element.attr('some-attr')).toEqual('OK');
      expect(element.attr('other-attr')).toEqual('23');
    }));
  });

  describe('NgShow', () {
    TestBed _;

    beforeEach(beforeEachTestBed((tb) => _ = tb));

    it('should add/remove ng-show class', () {
      var element = _.compile('<div ng-show="isVisible"></div>');

      expect(element).not.toHaveClass('ng-show');

      _.rootScope.$apply(() {
        _.rootScope['isVisible'] = true;
      });
      expect(element).toHaveClass('ng-show');

      _.rootScope.$apply(() {
        _.rootScope['isVisible'] = false;
      });
      expect(element).not.toHaveClass('ng-show');
    });

    it('should work together with ng-class', () {
      var element = _.compile('<div ng-class="currentCls" ng-show="isVisible"></div>');

      expect(element).not.toHaveClass('active');
      expect(element).not.toHaveClass('ng-show');

      _.rootScope.$apply(() {
        _.rootScope['currentCls'] = 'active';
      });
      expect(element).toHaveClass('active');
      expect(element).not.toHaveClass('ng-show');

      _.rootScope.$apply(() {
        _.rootScope['isVisible'] = true;
      });
      expect(element).toHaveClass('active');
      expect(element).toHaveClass('ng-show');
    });
  });

}
