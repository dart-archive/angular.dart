library ng_message_spec;

import '../_specs.dart';
import 'package:angular/messages/module.dart';
import 'package:angular/mock/module.dart';

void main() {
  describe('ngMessage', () {
   TestBed _;

    s(text) => text.replaceAll(" ","");

    describe('watch value', () {
      it('should render a hashmap collection', (TestBed _) {
        var scope = _.rootScope;
        var element = _.compile('<div ng-messages="col">'
                                '  <div ng-message="ready">This message is ready</div>'
                                '</div>');
        scope.apply();

        expect(element.children.length).toBe(0);
        expect(element.text.trim()).toEqual('');

        scope.apply(() {
          scope.context['col'] = { 'ready' : true };
        });

        expect(element.children.length).toBe(1);
        expect(element.text).toContain("This message is ready");
      });

      it('should render with an empty collection', (TestBed _) {
        var scope = _.rootScope;
        var element = _.compile('<div ng-messages="col">'
                                '  <div ng-message="ready">This message is ready</div>'
                                '</div>');

        scope.apply(() {
          scope.context['col'] = {};
        });

        expect(element.children.length).toBe(0);
        expect(element.text.trim()).toEqual('');

        scope.apply(() {
          scope.context['col'] = { 'ready' : true };
        });

        expect(element.children.length).toBe(1);
        expect(element.text).toContain("This message is ready");

        scope.apply(() {
          scope.context['col'] = null;
        });

        expect(element.children.length).toBe(0);
        expect(element.text.trim()).toEqual('');
      });

      it('should insert and remove matching inner elements that are truthy and falsy', (TestBed _) {
        var scope = _.rootScope;
        var element = _.compile('<div ng-messages="col">'
                                '  <div ng-message="red">This message is red</div>'
                                '  <div ng-message="blue">This message is blue</div>'
                                '</div>');

        scope.apply(() {
          scope.context['col'] = {};
        });

        expect(element.children.length).toBe(0);
        expect(element.text.trim()).toEqual('');

        scope.apply(() {
          scope.context['col'] = {
            'blue' : true,
            'red' : false
          };
        });

        expect(element.children.length).toBe(1);
        expect(element.text).toContain("This message is blue");

        scope.apply(() {
          scope.context['col'] = {
            'red' : {}
          };
        });

        expect(element.children.length).toBe(1);
        expect(element.text).toContain("This message is red");

        scope.apply(() {
          scope.context['col'] = {
            'red' : null,
            'blue' : null
          };
        });

        expect(element.children.length).toBe(0);
        expect(element.text.trim()).toEqual("");
      });

      it('should add ng-active/ng-inactive CSS classes to the element when errors are/aren\'t displayed',
        (TestBed _) {

        var scope = _.rootScope;
        var element = _.compile('<div ng-messages="col">'
                                '  <div ng-message="ready">This message is ready</div>'
                                '</div>');

        scope.apply(() {
          scope.context['col'] = {};
        });

        expect(element).not.toHaveClass('ng-active');
        expect(element).toHaveClass('ng-inactive');

        scope.apply(() {
          scope.context['col'] = { 'ready' : 1 };
        });

        expect(element).toHaveClass('ng-active');
        expect(element).not.toHaveClass('ng-inactive');
      });
    });

    describe('ngMessageOn', () {
      it('should set \$control as the active map value within the scope of ngMessageOn', (TestBed _) { 
        var scope = _.rootScope;
        var element = _.compile('<div ng-messages="col">'
                                '  <div ng-message="number">*{{ \$control }}* is not a number</div>'
                                '  <div ng-message="palendrome">*{{ \$control }}* is not a palendrome</div>'
                                '</div>');
        scope.apply(() {
          scope.context['col'] = {
            'number' : "1a2e"
          };
        });

        expect(element.children.length).toBe(1);
        expect(element.text.trim()).toEqual("*1a2e* is not a number");

        scope.apply(() {
          scope.context['col'] = {
            'palendrome' : "matias"
          };
        });

        expect(element.children.length).toBe(1);
        expect(element.text.trim()).toEqual("*matias* is not a palendrome");
      });

      it('should alias the first control as \$control within the messages list', (TestBed _) { 
        var scope = _.rootScope;
        var element = _.compile('<form name="myForm">'
                                '  <input type="email" ng-model="email" name="myEmail" />'
                                '  <div ng-messages="myForm[\'myEmail\'].errorStates">'
                                '    <div ng-message="ng-email">*{{ \$control.viewValue }}* is not a valid email</div>'
                                '</div>');
        scope.apply(() {
          scope.context['email'] = 'abc';
        });

        expect(element.text.trim()).toEqual("*abc* is not a valid email");

        scope.apply(() {
          scope.context['email'] = 'sir@email.com';
        });

        expect(element.text.trim()).toEqual("");
      });
    });

    describe('[ng-messages-include]', () {
      it('should load a remote template', async((TestBed _, TemplateCache cache) {
        cache.put('abc.html', new HttpResponse(200,
          '<div ng-message="a">A</div>'
          '<div ng-message="b">B</div>'
          '<div ng-message="c">C</div>'
        ));

        var scope = _.rootScope;
        var element = _.compile('<div ng-messages="data" ng-messages-include="abc.html"></div>');

        // FIXME(matsko): figure out how to make one apply update the multiple attr beforehand
        scope.apply();

        microLeap();  // load the template from cache.

        scope.apply(() {
          scope.context['data'] = {
            'a': 1,
            'b': 2,
            'c': 3
          };
        });

        expect(element.children.length).toBe(1);
        expect(s(element.text)).toEqual("A");

        scope.apply(() {
          scope.context['data'] = {
            'c': 3
          };
        });

        expect(element.children.length).toBe(1);
        expect(s(element.text)).toEqual("C");
      }));

      it('should allow for overriding the remote template messages within the element',
        async((TestBed _, TemplateCache cache) {

        cache.put('abc.html', new HttpResponse(200,
          '<div ng-message="a">A</div>'
          '<div ng-message="b">B</div>'
          '<div ng-message="c">C</div>'
        ));

        var scope = _.rootScope;
        var element = _.compile('<div ng-messages="data" ng-messages-include="abc.html">'
                                '  <div ng-message="a">AAA</div>'
                                '  <div ng-message="c">CCC</div>'
                                '</div>');

        // FIXME(matsko): figure out how to make one apply update the multiple attr beforehand
        scope.apply();

        microLeap();  // load the template from cache.

        scope.apply(() {
          scope.context['data'] = {
            'a': 1,
            'b': 2,
            'c': 3
          };
        });

        expect(element.children.length).toBe(1);
        expect(s(element.text)).toEqual("AAA");

        scope.apply(() {
          scope.context['data'] = {
            'b': 2,
            'c': 3
          };
        });

        expect(element.children.length).toBe(1);
        expect(s(element.text)).toEqual("B");

        scope.apply(() {
          scope.context['data'] = {
            'c': 3
          };
        });

        expect(element.children.length).toBe(1);
        expect(s(element.text)).toEqual("CCC");
      }));
    });
    
    describe('[ng-messages-multiple]', () {
      it('should show all truthy messages when present', (TestBed _) {
        var scope = _.rootScope;
        var element = _.compile('<div ng-messages="data" ng-messages-multiple="true">'
                                '  <div ng-message="one">1</div>'
                                '  <div ng-message="two">2</div>'
                                '  <div ng-message="three">3</div>'
                                '</div>');

        // FIXME(matsko): figure out how to make one apply update the multiple attr beforehand
        scope.apply();

        scope.apply(() {
          scope.context['data'] = {
            'one': true,
            'two': false,
            'three': true
          };
        });

        expect(element.children.length).toBe(2);
        expect(s(element.text)).toContain("13");
      });

      it('should render all truthy messages from a remote template',
        async((TestBed _, TemplateCache cache) {

        cache.put('xyz.html', new HttpResponse(200,
          '<div ng-message="x">X</div>'
          '<div ng-message="y">Y</div>'
          '<div ng-message="z">Z</div>'
        ));

        var scope = _.rootScope;
        var element = _.compile('<div ng-messages="data" '
                                     'ng-messages-multiple="true" '
                                     'ng-messages-include="xyz.html"></div>');

        // FIXME(matsko): figure out how to make one apply update the multiple attr beforehand
        scope.apply();

        microLeap();  // load the template from cache.

        scope.apply(() {
          scope.context['data'] = {
            'x': 'a',
            'y': null,
            'z': true
          };
        });

        expect(element.children.length).toBe(2);
        expect(s(element.text)).toEqual("XZ");

        scope.apply(() {
          scope.context['data']['y'] = {};
        });

        expect(element.children.length).toBe(3);
        expect(s(element.text)).toEqual("XYZ");
      }));

      it('should render and override all truthy messages from a remote template',
        async((TestBed _, TemplateCache cache) {

        cache.put('xyz.html', new HttpResponse(200,
          '<div ng-message="x">X</div>'
          '<div ng-message="y">Y</div>'
          '<div ng-message="z">Z</div>'
        ));

        var scope = _.rootScope;
        var element = _.compile('<div ng-messages="data" '
                                     'ng-messages-multiple="true" '
                                     'ng-messages-include="xyz.html">'
                                        '<div ng-message="y">YYY</div>'
                                        '<div ng-message="z">ZZZ</div>'
                                '</div>');

        // FIXME(matsko): figure out how to make one apply update the multiple attr beforehand
        scope.apply();

        microLeap();  // load the template from cache.

        scope.apply(() {
          scope.context['data'] = {
            'x': 'a',
            'y': null,
            'z': true
          };
        });

        expect(element.children.length).toBe(2);
        expect(s(element.text)).toEqual("ZZZX");

        scope.apply(() {
          scope.context['data']['y'] = {};
        });

        expect(element.children.length).toBe(3);
        expect(s(element.text)).toEqual("YYYZZZX");
      }));
    });
  });
}
