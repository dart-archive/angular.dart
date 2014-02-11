library ng_include_spec;

import '../_specs.dart';

main() {
  describe('NgInclude', () {
    TestBed _;

    beforeEach(inject((TestBed tb) => _ = tb));

    it('should fetch template from literal url', async(inject((Scope scope, TemplateCache cache) {
      cache.put('tpl.html', new HttpResponse(200, 'my name is {{name}}'));

      var element = _.compile('<div ng-include="tpl.html"></div>');

      expect(element.innerHtml).toEqual('');

      microLeap();  // load the template from cache.
      scope.applyInZone(() {
        scope.context['name'] = 'Vojta';
      });
      expect(element.text).toEqual('my name is Vojta');
    })));

    it('should fetch template from url using interpolation', async(inject((Scope scope, TemplateCache cache) {
      cache.put('tpl1.html', new HttpResponse(200, 'My name is {{name}}'));
      cache.put('tpl2.html', new HttpResponse(200, 'I am {{name}}'));

      var element = _.compile('<div ng-include="{{template}}"></div>');

      expect(element.innerHtml).toEqual('');

      scope.applyInZone(() {
        scope.context['name'] = 'Vojta';
        scope.context['template'] = 'tpl1.html';
      });
      expect(element.text).toEqual('My name is Vojta');

      scope.applyInZone(() {
        scope.context['template'] = 'tpl2.html';
      });
      expect(element.text).toEqual('I am Vojta');
    })));

  });
}
