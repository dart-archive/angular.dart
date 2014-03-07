library bootstrap_spec;

import '_specs.dart';
import 'package:angular/angular_dynamic.dart';

void main() {
  describe('bootstrap', () {
    setBody(String html) {
      var body = window.document.querySelector('body');
      body.setInnerHtml(html, treeSanitizer: new NullTreeSanitizer());
      return body;
    }

    it('should default to whole page', () {
      var body = setBody('<div>{{"works"}}</div>');
      ngDynamicApp().run();
      expect(body).toHaveHtml('<div>works</div>');
    });

    it('should compile starting at ng-app node', () {
      var body = setBody(
          '<div>{{ignor me}}<div ng-app ng-bind="\'works\'"></div></div>');
      ngDynamicApp().run();
      expect(body.text).toEqual('{{ignor me}}works');
    });

    it('should compile starting at ng-app node', () {
      var body = setBody(
          '<div>{{ignor me}}<div ng-bind="\'works\'"></div></div>');
      ngDynamicApp()..selector('div[ng-bind]')..run();
      expect(body.text).toEqual('{{ignor me}}works');
    });
  });
}
