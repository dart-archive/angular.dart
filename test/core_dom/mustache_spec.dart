library ng_mustache_spec;

import '../_specs.dart';

main() {
  describe('ng-mustache', () {
    TestBed _;
    beforeEachModule((Module module) {
      module.bind(_HelloFormatter);
      module.bind(_FooDirective);
    });
    beforeEach(inject((TestBed tb) => _ = tb));

    it('should replace {{}} in text', inject((Compiler compile,
        Scope rootScope, Injector injector, DirectiveMap directives)
    {
      var element = es('<div>{{name}}<span>!</span></div>');
      var template = compile(element, directives);

      rootScope.context['name'] = 'OK';
      var view = template(injector);

      element = view.nodes;

      rootScope.apply();
      expect(element).toHaveText('OK!');
    }));

    describe('observe/flush phase', () {
      it('should first only when then value has settled', async((Logger log) {
        _.compile('<div dir-foo="{{val}}"></div>');

        _.rootScope.apply();
        // _FooDirective should NOT have observed any changes.
        expect(log).toEqual([]);
        expect(_.rootElement.attributes['dir-foo']).toEqual('');

        _.rootScope.apply(() {
          _.rootScope.context['val'] = 'value';
        });
        // _FooDirective should have observed exactly one change.
        expect(_.rootElement.attributes['dir-foo']).toEqual('value');
        expect(log).toEqual(['value']);
      }));
    });

    it('should replace {{}} in attribute', inject((Compiler compile,
        Scope rootScope, Injector injector, DirectiveMap directives)
    {
      Element element =
          e('<div some-attr="{{name}}" other-attr="{{age}}"></div>');
      var template = compile([element], directives);

      rootScope.context['name'] = 'OK';
      rootScope.context['age'] = 23;
      var view = template(injector);

      element = view.nodes[0];

      rootScope.apply();
      expect(element.attributes['some-attr']).toEqual('OK');
      expect(element.attributes['other-attr']).toEqual('23');
    }));


    it('should allow newlines in attribute', inject((Compiler compile,
       RootScope rootScope, Injector injector, DirectiveMap directives)
    {
      Element element =
          e('<div multiline-attr="line1: {{line1}}\nline2: {{line2}}"></div>');
      var template = compile([element], directives);

      rootScope.context['line1'] = 'L1';
      rootScope.context['line2'] = 'L2';
      var view = template(injector);

      element = view.nodes[0];

      rootScope.apply();
      expect(element.attributes['multiline-attr'])
          .toEqual('line1: L1\nline2: L2');
    }));


    it('should handle formatters', inject((Compiler compile, RootScope rootScope,
        Injector injector, DirectiveMap directives)
    {
      var element = es('<div>{{"World" | hello}}</div>');
      var template = compile(element, directives);
      var view = template(injector);
      rootScope.apply();

      element = view.nodes;

      expect(element).toHaveHtml('Hello, World!');
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
      var element =
          _.compile('<div ng-class="currentCls" ng-show="isVisible"></div>');

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

@Component(selector: '[dir-foo]')
class _FooDirective implements AttachAware {
  NodeAttrs attrs;
  Logger log;

  _FooDirective(this.attrs, this.log);

  @override
  void attach() {
    attrs.observe('dir-foo', (val) => log(val));
  }
}
