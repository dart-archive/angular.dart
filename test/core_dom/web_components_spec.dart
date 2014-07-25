library angular.dom.web_components_spec;

import '../_specs.dart';
import 'dart:js' as js;

registerElement(String name, prototype) {
  return (new js.JsObject.fromBrowserObject(document)).callMethod('registerElement',
          [name, new js.JsObject.jsify({"prototype": prototype })]);
}



main() {
  describe('WebComponent support', () {
    TestBed _;

    customProp(String prop, [elt]) {
      if (elt == null) elt = _.rootElement;
      return (new js.JsObject.fromBrowserObject(elt))[prop];
    }

    beforeEach((TestBed tb) {
      _ = tb;
    });
    
    it('should create custom elements', () {
      registerElement('tests-basic', {'prop-x': 6});
      
      // Create a web component
      _.compile('<tests-basic></tests-basic>');
      expect(customProp('prop-x')).toEqual(6);
    });


    it('should bind to Custom Element properties', () {
      registerElement('tests-bound', {'prop-y': 10});
      _.compile('<tests-bound bind-prop-y=27></tests-bound>');

      // Scope has not been digested yet
      expect(customProp('prop-y')).toEqual(10);

      _.rootScope.apply();
      expect(customProp('prop-y')).toEqual(27);
    });


    it('should bind to a non-existent property', () {
      registerElement('tests-empty', {});
      _.compile('<tests-empty bind-new-prop=27></tests-empty>');
      _.rootScope.apply();
      expect(customProp('new-prop')).toEqual(27);
    });
    
    it('should bind to both directives and properties', () {
      registerElement('tests-double', {});
      _.compile('<tests-double ng-bind bind-ng-bind="\'hello\'"></tests-double>');
      _.rootScope.apply();
      expect(customProp('ng-bind')).toEqual("hello");
      expect(_.rootElement).toHaveText('hello');
    });
  });
}
