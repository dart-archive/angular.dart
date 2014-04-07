library ng_template_spec;

import '../_specs.dart';

main() {
  describe('NgTemplateDirective', () {
    TestBed _;
    var element;

    beforeEach((TestBed tb) => _ = tb);

    they(should, htmlForElements, callback) {
      htmlForElements.forEach((html) {
        var tagName = html.contains('<template') ? 'template' : 'script';
        describe('$tagName[type="text/ng-template"]', () {
          beforeEach(() => element = e(html));
          it(should, callback);
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
      (TemplateCache templateCache) {
        _.compile(element);
        expect(templateCache.get('/ignore')).toBeNull();
        expect(templateCache.get('/myTemplate.html').responseText).toEqual('<x>{{y}}</x>');
      }
    );

    it('should not compile template elements', () {
      _.compile(element = e('<div>foo'
          '<template type="text/javascript">some {{binding}} <div></div></template>'
          '<template type="text/ng-template" id="/some">other {{binding}} <div></div></template>'
          '</div>'));

      microLeap();

      expect(element.children[1] is TemplateElement).toBeTruthy();
      // This binding should have been left alone (i.e. not interpolated).
      expect(element.children[1].content).toHaveHtml('other {{binding}} <div></div>');
    });

    it('should not compile script elements', () {
      _.compile(element = e('<div>foo'
          '<script type="text/javascript">some {{binding}} <div></div></script>'
          '<script type="text/ng-template" id="/some">other {{binding}} <div></div></script>'
          '</div>'));

      microLeap();

      // This binding should have been left alone (i.e. not interpolated).
      expect(element.children[1]).toHaveHtml('other {{binding}} <div></div>');
    });
  });
}
