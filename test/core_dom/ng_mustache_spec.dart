library ng_mustache_spec;

import '../_specs.dart';

main() {
  describe('ng-mustache', () {
    TestBed _;
    beforeEach(module((Module module) {
      module.type(_ListenerDirective);
    }));
    beforeEach(inject((TestBed tb) => _ = tb));

    it('should replace {{}} in text', inject((Compiler $compile, Scope $rootScope, Injector injector, DirectiveMap directives) {
      var element = $('<div>{{name}}<span>!</span></div>');
      var template = $compile(element, directives);

      $rootScope.name = 'OK';
      var block = template(injector);

      element = $(block.elements);

      expect(element.text()).toEqual('!');
      $rootScope.$digest();
      expect(element.text()).toEqual('OK!');
    }));


    it('should allow listening on text change events', inject((Logger logger) {
      _.compile('<div listener>{{text}}</div>');
      _.rootScope.text = 'works';
      _.rootScope.$apply();
      expect(_.rootElement.text).toEqual('works');
      expect(logger).toEqual(['', 'works']);
    }));


    it('should replace {{}} in attribute', inject((Compiler $compile, Scope $rootScope, Injector injector, DirectiveMap directives) {
      var element = $('<div some-attr="{{name}}" other-attr="{{age}}"></div>');
      var template = $compile(element, directives);

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

    beforeEach(inject((TestBed tb) => _ = tb));

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

@NgDirective(
    selector: '[listener]',
    publishTypes: const [TextChangeListener],
    visibility: NgDirective.DIRECT_CHILDREN_VISIBILITY
)
class _ListenerDirective implements TextChangeListener {
  Logger logger;
  _ListenerDirective(Logger this.logger);
  call(String text) => logger(text);
}
