library ng_mustache_spec;

import '../_specs.dart';

main() {
  describe('ng-mustache', () {
    TestBed _;
    beforeEach(module((Module module) {
      module.type(_HelloFilter);
    }));
    beforeEach(inject((TestBed tb) => _ = tb));

    it('should replace {{}} in text', inject((Compiler $compile, Scope rootScope, Injector injector, DirectiveMap directives) {
      var element = $('<div>{{name}}<span>!</span></div>');
      var template = $compile(element, directives);

      rootScope.context['name'] = 'OK';
      var block = template(injector);

      element = $(block.elements);

      rootScope.apply();
      expect(element.text()).toEqual('OK!');
    }));


    it('should replace {{}} in attribute', inject((Compiler $compile, Scope rootScope, Injector injector, DirectiveMap directives) {
      var element = $('<div some-attr="{{name}}" other-attr="{{age}}"></div>');
      var template = $compile(element, directives);

      rootScope.context['name'] = 'OK';
      rootScope.context['age'] = 23;
      var block = template(injector);

      element = $(block.elements);

      rootScope.apply();
      expect(element.attr('some-attr')).toEqual('OK');
      expect(element.attr('other-attr')).toEqual('23');
    }));


    it('should allow newlines in attribute', inject((Compiler $compile, RootScope rootScope, Injector injector, DirectiveMap directives) {
      var element = $('<div multiline-attr="line1: {{line1}}\nline2: {{line2}}"></div>');
      var template = $compile(element, directives);

      rootScope.context['line1'] = 'L1';
      rootScope.context['line2'] = 'L2';
      var block = template(injector);

      element = $(block.elements);

      rootScope.apply();
      expect(element.attr('multiline-attr')).toEqual('line1: L1\nline2: L2');
    }));


    it('should handle filters', inject((Compiler $compile, RootScope rootScope, Injector injector, DirectiveMap directives) {
      var element = $('<div>{{"World" | hello}}</div>');
      var template = $compile(element, directives);
      var block = template(injector);
      rootScope.apply();

      element = $(block.elements);

      expect(element.html()).toEqual('Hello, World!');
    }));
  });

  describe('NgShow', () {
    TestBed _;

    beforeEach(inject((TestBed tb) => _ = tb));

    it('should add/remove ng-hide class', () {
      var element = _.compile('<div ng-show="isVisible"></div>');

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
      var element = _.compile('<div ng-class="currentCls" ng-show="isVisible"></div>');

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

@NgFilter(name:'hello')
class _HelloFilter {
  call(String str) {
    return 'Hello, $str!';
  }
}

