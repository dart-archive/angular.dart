library ng_src_boolean_spec;

import '../_specs.dart';
import 'dart:html' as dom;

main() {
  describe('boolean attr directives', () {
    TestBed _;
    beforeEach((TestBed tb) => _ = tb);


    it('should properly evaluate 0 as false', () {
      _.compile('<button ng-disabled="isDisabled">Button</button>');
      _.rootScope.context['isDisabled'] = 0;
      _.rootScope.apply();
      expect(_.rootElement.attributes['disabled']).toBeFalsy();
      _.rootScope.context['isDisabled'] = 1;
      _.rootScope.apply();
      expect(_.rootElement.attributes['disabled']).toBeTruthy();
    });


    it('should bind disabled', () {
      _.compile('<button ng-disabled="isDisabled">Button</button>');
      _.rootScope.context['isDisabled'] = false;
      _.rootScope.apply();
      expect(_.rootElement.attributes['disabled']).toBeFalsy();
      _.rootScope.context['isDisabled'] = true;
      _.rootScope.apply();
      expect(_.rootElement.attributes['disabled']).toBeTruthy();
    });


    it('should bind checked', () {
      _.compile('<input type="checkbox" ng-checked="isChecked" />');
      _.rootScope.context['isChecked'] = false;
      _.rootScope.apply();
      expect(_.rootElement.attributes['checked']).toBeFalsy();
      _.rootScope.context['isChecked']=true;
      _.rootScope.apply();
      expect(_.rootElement.attributes['checked']).toBeTruthy();
    });


    it('should bind selected', () {
      _.compile('<select><option value=""></option><option ng-selected="isSelected">Greetings!</option></select>');
      _.rootScope.context['isSelected']=false;
      _.rootScope.apply();
      expect((_.rootElement.childNodes[1] as dom.OptionElement).selected).toBeFalsy();
      _.rootScope.context['isSelected']=true;
      _.rootScope.apply();
      expect((_.rootElement.childNodes[1] as dom.OptionElement).selected).toBeTruthy();
    });


    it('should bind readonly', () {
      _.compile('<input type="text" ng-readonly="isReadonly" />');
      _.rootScope.context['isReadonly']=false;
      _.rootScope.apply();
      expect(_.rootElement.attributes['readOnly']).toBeFalsy();
      _.rootScope.context['isReadonly']=true;
      _.rootScope.apply();
      expect(_.rootElement.attributes['readOnly']).toBeTruthy();
    });


    it('should bind open', () {
      _.compile('<details ng-open="isOpen"></details>');
      _.rootScope.context['isOpen']=false;
      _.rootScope.apply();
      expect(_.rootElement.attributes['open']).toBeFalsy();
      _.rootScope.context['isOpen']=true;
      _.rootScope.apply();
      expect(_.rootElement.attributes['open']).toBeTruthy();
    });


    describe('multiple', () {
      it('should NOT bind to multiple via ngMultiple', () {
        _.compile('<select ng-multiple="isMultiple"></select>');
        _.rootScope.context['isMultiple']=false;
        _.rootScope.apply();
        expect(_.rootElement.attributes['multiple']).toBeFalsy();
        _.rootScope.context['isMultiple']='multiple';
        _.rootScope.apply();
        expect(_.rootElement.attributes['multiple']).toBeFalsy(); // ignore
      });
    });
  });


  describe('ngSrc', () {
    TestBed _;
    beforeEach((TestBed tb) => _ = tb);

    it('should interpolate the expression and bind to src with raw same-domain value', () {
      _.compile('<div ng-src="{{id}}"></div>');

      _.rootScope.apply();
      expect(_.rootElement.attributes['src']).toEqual(null);

      _.rootScope.apply(() {
        _.rootScope.context['id'] = '/somewhere/here';
      });
      expect(_.rootElement.attributes['src']).toEqual('/somewhere/here');
    });


    xit('should interpolate the expression and bind to src with a trusted value', (sce) {
      _.compile('<div ng-src="{{id}}"></div>');

      _.rootScope.apply();
      expect(_.rootElement.attributes['src']).toEqual(null);

      _.rootScope.apply(() {
        _.rootScope.context['id'] = sce.trustAsResourceUrl('http://somewhere');
      });
      expect(_.rootElement.attributes['src']).toEqual('http://somewhere');
    });


    xit('should NOT interpolate a multi-part expression for non-img src attribute', () {
      expect(() {
        _.compile('<div ng-src="some/{{id}}"></div>');
      }).toThrow("Error while interpolating: some/{{id}}\nStrict " +
          "Contextual Escaping disallows interpolations that concatenate multiple expressions " +
          "when a trusted value is required.  See http://docs.angularjs.org/api/ng.sce");
    });


    it('should interpolate a multi-part expression for regular attributes', () {
      _.compile('<div foo="some/{{id}}"></div>');
      _.rootScope.apply();
      expect(_.rootElement.attributes['foo']).toEqual('some/');
      _.rootScope.apply(() {
        _.rootScope.context['id'] = 1;
      });
      expect(_.rootElement.attributes['foo']).toEqual('some/1');
    });


    xit('should NOT interpolate a wrongly typed expression', (sce) {
      expect(() {
        _.compile('<div ng-src="{{id}}"></div>');
        _.rootScope.apply(() {
          _.rootScope.context['id'] = sce.trustAsUrl('http://somewhere');
        });
        _.rootElement.attributes['src'];
      }).toThrow("Can't interpolate: {{id}}\nError: [sce:insecurl] Viewed " +
          "loading resource from url not allowed by sceDelegate policy.  URL: http://somewhere");
    });

  });


  describe('ngSrcset', () {
    TestBed _;
    beforeEach((TestBed tb) => _ = tb);

    it('should interpolate the expression and bind to srcset', () {
      _.compile('<div ng-srcset="some/{{id}} 2x"></div>');

      _.rootScope.apply();
      expect(_.rootElement.attributes['srcset']).toEqual('some/ 2x');

      _.rootScope.apply(() {
        _.rootScope.context['id'] = 1;
      });
      expect(_.rootElement.attributes['srcset']).toEqual('some/1 2x');
    });
  });


  describe('ngHref', () {
    TestBed _;
    beforeEach((TestBed tb) => _ = tb);

    it('should interpolate the expression and bind to href', () {
      _.compile('<div ng-href="some/{{id}}"></div>');
      _.rootScope.apply();
      expect(_.rootElement.attributes['href']).toEqual('some/');

      _.rootScope.apply(() {
        _.rootScope.context['id'] = 1;
      });
      expect(_.rootElement.attributes['href']).toEqual('some/1');
    });


    it('should bind href and merge with other attrs', () {
      _.compile('<a ng-href="{{url}}" rel="{{rel}}"></a>');
      _.rootScope.context['url'] = 'http://server';
      _.rootScope.context['rel'] = 'REL';
      _.rootScope.apply();
      expect(_.rootElement.attributes['href']).toEqual('http://server');
      expect(_.rootElement.attributes['rel']).toEqual('REL');
    });


    it('should bind href even if no interpolation', () {
      _.compile('<a ng-href="http://server"></a>');
      _.rootScope.apply();
      expect(_.rootElement.attributes['href']).toEqual('http://server');
    });
  });

  describe('ngAttr', () {
    TestBed _;
    beforeEach((TestBed tb) => _ = tb);

    it('should interpolate the expression and bind to *', () {
      _.compile('<div ng-attr-foo="some/{{id}}"></div>');
      _.rootScope.apply();
      expect(_.rootElement.attributes['foo']).toEqual('some/');

      _.rootScope.apply(() {
        _.rootScope.context['id'] = 1;
      });
      expect(_.rootElement.attributes['foo']).toEqual('some/1');
    });


    it('should bind * and merge with other attrs', () {
      _.compile('<div ng-attr-bar="{{bar}}" ng-attr-bar2="{{bar2}}" bam="{{bam}}"></a>');
      _.rootScope.context['bar'] = 'foo';
      _.rootScope.context['bar2'] = 'foo2';
      _.rootScope.context['bam'] = 'boom';
      _.rootScope.apply();
      expect(_.rootElement.attributes['bar']).toEqual('foo');
      expect(_.rootElement.attributes['bar2']).toEqual('foo2');
      expect(_.rootElement.attributes['bam']).toEqual('boom');
      _.rootScope.context['bar'] = 'FOO';
      _.rootScope.context['bar2'] = 'FOO2';
      _.rootScope.context['bam'] = 'BOOM';
      _.rootScope.apply();
      expect(_.rootElement.attributes['bar']).toEqual('FOO');
      expect(_.rootElement.attributes['bar2']).toEqual('FOO2');
      expect(_.rootElement.attributes['bam']).toEqual('BOOM');
    });


    it('should bind * even if no interpolation', () {
      _.compile('<a ng-attr-quack="vanilla"></a>');
      _.rootScope.apply();
      expect(_.rootElement.attributes['quack']).toEqual('vanilla');
    });
  });
}
