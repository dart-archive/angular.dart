library ng_template_spec;

import '../_specs.dart';

main() {
  describe('NgTemplateDirective', () {
    TestBed _;
    var element;

    they(should, htmlForElements, callback) {
      htmlForElements.forEach((html) {
        var tagName = html.contains('<template') ? 'template' : 'script';
        describe('$tagName[type="text/ng-template"]', () {
          beforeEach(inject((TestBed tb) => _ = tb));
          it(should, () {
             element = $(html);
             inject(callback);
           });
        });
      });
    }

    they('should populate TemplateCache with contents of a ng-template template element',
      [ // <template>
        '<div>foo' +
          '<template id="/ignore">ignore me</template>' +
          '<template type="text/ng-template" id="/myTemplate.html"><x>{{y}}</x></template>' +
        '</div>',
        // <script>
        '<div>foo' +
          '<script id="/ignore">ignore me</script>' +
          '<script type="text/ng-template" id="/myTemplate.html"><x>{{y}}</x></script>' +
        '</div>'],
      (Injector injector, Compiler compiler, TemplateCache templateCache, DirectiveMap directives) {
        compiler(element, directives)(injector, element);
        expect(templateCache.get('/ignore')).toBeNull();
        expect(templateCache.get('/myTemplate.html').responseText).toEqual('<x>{{y}}</x>');
      }
    );

    they('should not compile template elements',
      [ // <template>
        '<div>foo' +
          '<template type="text/javascript">some {{binding}} <div></div></template>' +
          '<template type="text/ng-template" id="/some">other {{binding}} <div></div></template>' +
        '</div>',
        // <script>
        '<div>foo' +
          '<script type="text/javascript">some {{binding}} <div></div></script>' +
          '<script type="text/ng-template" id="/some">other {{binding}} <div></div></script>' +
        '</div>'],
      (Injector injector, Compiler compiler, TemplateCache templateCache, Scope scope, DirectiveMap directives) {
        var templates = element.contents();
        compiler(element, directives)(injector, element);

        microLeap();
        // This binding should have been left alone (i.e. not interpolated).
        expect(templates[2].innerHtml).toEqual('other {{binding}} <div></div>');
      }
    );
  });
}
