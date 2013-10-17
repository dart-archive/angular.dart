library ng_include_spec;

import '../_specs.dart';

main() {
  describe('NgInclude', () {
    TestBed _;

    beforeEach(inject((TestBed tb) => _ = tb));

    it('should fetch template from url', async(inject((Scope scope, TemplateCache cache) {
      cache.put('tpl.html', new HttpResponse(200, 'my name is {{name}}'));

      var element = _.compile('<div ng-include="template"></div>');

      expect(element.innerHtml).toEqual('');

      scope.$apply(() {
        scope['name'] = 'Vojta';
        scope['template'] = 'tpl.html';
      });

      microLeap();  // load the template from cache.
      expect(element.text).toEqual('my name is Vojta');
    })));
  });
}
