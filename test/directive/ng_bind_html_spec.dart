library ng_bind_html_spec;

import '../_specs.dart';

main() {
  describe('BindHtmlDirective', () {
    TestBed _;

    beforeEach(inject((TestBed tb) => _ = tb));

    it('should sanitize and set innerHtml and sanitize and set html',
          inject((Scope scope, Injector injector, Compiler compiler) {
      var element = $('<div ng-bind-html="htmlVar"></div>');
      compiler(element)(injector, element);
      scope.htmlVar = '<a href="http://www.google.com"><b>Google!</b></a>';
      scope.$digest();
      // Sanitization removes the href attribute on the <a> tag.
      expect(element.html()).toEqual('<a><b>Google!</b></a>');
    }));
  });
}
