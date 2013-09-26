library ng_template_spec;

import '../_specs.dart';
import '../_test_bed.dart';

main() {
  describe('NgTemplateDirective', () {
    TestBed _;

    beforeEach(beforeEachTestBed((tb) => _ = tb));

    it('should populate TemplateCache with contents of a ng-template template element',
          inject((Injector injector, Compiler compiler, TemplateCache templateCache) {
      var element = $('<div>foo' +
                        '<template id="/ignore">ignore me</template>' +
                        '<template type="text/ng-template" id="/myTemplate.html"><x>{{y}}</x></template>' +
                      '</div>');
      compiler(element)(injector, element);
      expect(templateCache.get('/ignore')).toBeNull();
      expect(templateCache.get('/myTemplate.html').responseText).toEqual('<x>{{y}}</x>');
    }));

    it('should not compile template elements',
          inject((Injector injector, Compiler compiler, TemplateCache templateCache) {
      var element = $('<div>foo' +
                        '<template type="text/javascript">some {{binding}} <div></div></template>' +
                        '<template type="text/ng-template" id="/some">other {{binding}} <div></div></template>' +
                      '</div>');
      var templates = element.contents();
      compiler(element)(injector, element);

      nextTurn(true);
      // These bindings should have been left alone (i.e. not interpolated).
      expect(templates[1].content.innerHtml).toEqual('some {{binding}} <div></div>');
      expect(templates[2].content.innerHtml).toEqual('other {{binding}} <div></div>');
    }));
  });
}
