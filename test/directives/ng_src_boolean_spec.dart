library ng_src_boolean_spec;

import '../_specs.dart';
import '../_test_bed.dart';
import 'dart:html' as dom;

main() {
  describe('boolean attr directives', () {
    TestBed _;
    beforeEach(beforeEachTestBed((tb) => _ = tb));


    it('should properly evaluate 0 as false', inject(() {
      _.compile('<button ng-disabled="isDisabled">Button</button>');
      _.rootScope.isDisabled = 0;
      _.rootScope.$digest();
      expect(_.rootElement.attr('disabled')).toBeFalsy();
      _.rootScope.isDisabled = 1;
      _.rootScope.$digest();
      expect(_.rootElement.attr('disabled')).toBeTruthy();
    }));


    it('should bind disabled', inject(() {
      _.compile('<button ng-disabled="isDisabled">Button</button>');
      _.rootScope.isDisabled = false;
      _.rootScope.$digest();
      expect(_.rootElement.attr('disabled')).toBeFalsy();
      _.rootScope.isDisabled = true;
      _.rootScope.$digest();
      expect(_.rootElement.attr('disabled')).toBeTruthy();
    }));


    it('should bind checked', inject(() {
      _.compile('<input type="checkbox" ng-checked="isChecked" />');
      _.rootScope.isChecked = false;
      _.rootScope.$digest();
      expect(_.rootElement.attr('checked')).toBeFalsy();
      _.rootScope.isChecked=true;
      _.rootScope.$digest();
      expect(_.rootElement.attr('checked')).toBeTruthy();
    }));


    it('should bind selected', inject(() {
      _.compile('<select><option value=""></option><option ng-selected="isSelected">Greetings!</option></select>');
      _.rootScope.isSelected=false;
      _.rootScope.$digest();
      expect(_.rootElement.children()[1].selected).toBeFalsy();
      _.rootScope.isSelected=true;
      _.rootScope.$digest();
      expect(_.rootElement.children()[1].selected).toBeTruthy();
    }));


    it('should bind readonly', inject(() {
      _.compile('<input type="text" ng-readonly="isReadonly" />');
      _.rootScope.isReadonly=false;
      _.rootScope.$digest();
      expect(_.rootElement.attr('readOnly')).toBeFalsy();
      _.rootScope.isReadonly=true;
      _.rootScope.$digest();
      expect(_.rootElement.attr('readOnly')).toBeTruthy();
    }));


    it('should bind open', inject(() {
      _.compile('<details ng-open="isOpen"></details>');
      _.rootScope.isOpen=false;
      _.rootScope.$digest();
      expect(_.rootElement.attr('open')).toBeFalsy();
      _.rootScope.isOpen=true;
      _.rootScope.$digest();
      expect(_.rootElement.attr('open')).toBeTruthy();
    }));


    describe('multiple', () {
      it('should NOT bind to multiple via ngMultiple', inject(() {
        _.compile('<select ng-multiple="isMultiple"></select>');
        _.rootScope.isMultiple=false;
        _.rootScope.$digest();
        expect(_.rootElement.attr('multiple')).toBeFalsy();
        _.rootScope.isMultiple='multiple';
        _.rootScope.$digest();
        expect(_.rootElement.attr('multiple')).toBeFalsy(); // ignore
      }));
    });
  });


  describe('ngSrc', () {
    TestBed _;
    beforeEach(beforeEachTestBed((tb) => _ = tb));

    it('should interpolate the expression and bind to src with raw same-domain value',
    inject(() {
      _.compile('<div ng-src="{{id}}"></div>');

      _.rootScope.$digest();
      expect(_.rootElement.attr('src')).toEqual('');

      _.rootScope.$apply(() {
        _.rootScope.id = '/somewhere/here';
      });
      expect(_.rootElement.attr('src')).toEqual('/somewhere/here');
    }));


    xit('should interpolate the expression and bind to src with a trusted value', inject(($sce) {
      _.compile('<div ng-src="{{id}}"></div>');

      _.rootScope.$digest();
      expect(_.rootElement.attr('src')).toEqual(null);

      _.rootScope.$apply(() {
        _.rootScope.id = $sce.trustAsResourceUrl('http://somewhere');
      });
      expect(_.rootElement.attr('src')).toEqual('http://somewhere');
    }));


    xit('should NOT interpolate a multi-part expression for non-img src attribute', inject(() {
      expect(() {
        _.compile('<div ng-src="some/{{id}}"></div>');
      }).toThrow("Error while interpolating: some/{{id}}\nStrict " +
          "Contextual Escaping disallows interpolations that concatenate multiple expressions " +
          "when a trusted value is required.  See http://docs.angularjs.org/api/ng.\$sce");
    }));


    it('should interpolate a multi-part expression for regular attributes', inject(() {
      _.compile('<div foo="some/{{id}}"></div>');
      _.rootScope.$digest();
      expect(_.rootElement.attr('foo')).toEqual('some/');
      _.rootScope.$apply(() {
        _.rootScope.id = 1;
      });
      expect(_.rootElement.attr('foo')).toEqual('some/1');
    }));


    xit('should NOT interpolate a wrongly typed expression', inject(($sce) {
      expect(() {
        _.compile('<div ng-src="{{id}}"></div>');
        _.rootScope.$apply(() {
          _.rootScope.id = $sce.trustAsUrl('http://somewhere');
        });
        _.rootElement.attr('src');
      }).toThrow("Can't interpolate: {{id}}\nError: [\$sce:insecurl] Blocked " +
          "loading resource from url not allowed by \$sceDelegate policy.  URL: http://somewhere");
    }));

  });


  describe('ngSrcset', () {
    TestBed _;
    beforeEach(beforeEachTestBed((tb) => _ = tb));

    it('should interpolate the expression and bind to srcset', inject(() {
      _.compile('<div ng-srcset="some/{{id}} 2x"></div>');

      _.rootScope.$digest();
      expect(_.rootElement.attr('srcset')).toEqual('some/ 2x');

      _.rootScope.$apply(() {
        _.rootScope.id = 1;
      });
      expect(_.rootElement.attr('srcset')).toEqual('some/1 2x');
    }));
  });


  describe('ngHref', () {
    TestBed _;
    beforeEach(beforeEachTestBed((tb) => _ = tb));

    it('should interpolate the expression and bind to href', inject(() {
      _.compile('<div ng-href="some/{{id}}"></div>');
      _.rootScope.$digest();
      expect(_.rootElement.attr('href')).toEqual('some/');

      _.rootScope.$apply(() {
        _.rootScope.id = 1;
      });
      expect(_.rootElement.attr('href')).toEqual('some/1');
    }));


    it('should bind href and merge with other attrs', inject(() {
      _.compile('<a ng-href="{{url}}" rel="{{rel}}"></a>');
      _.rootScope.url = 'http://server';
      _.rootScope.rel = 'REL';
      _.rootScope.$digest();
      expect(_.rootElement.attr('href')).toEqual('http://server');
      expect(_.rootElement.attr('rel')).toEqual('REL');
    }));


    it('should bind href even if no interpolation', inject(() {
      _.compile('<a ng-href="http://server"></a>');
      _.rootScope.$digest();
      expect(_.rootElement.attr('href')).toEqual('http://server');
    }));
  });
}
