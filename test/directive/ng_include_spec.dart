library ng_include_spec;

import '../_specs.dart';

main() {
  describe('NgInclude', () {
    TestBed _;

    beforeEach((TestBed tb) => _ = tb);

    it('should fetch template from literal url', async((Scope scope, TemplateCache cache) {
      cache.put('tpl.html', new HttpResponse(200, 'my name is {{name}}'));

      var element = _.compile('<div ng-include="tpl.html"></div>');

      expect(element.innerHtml).toEqual('');

      microLeap();  // load the template from cache.
      scope.context['name'] = 'Vojta';
      scope.apply();
      expect(element.text).toEqual('my name is Vojta');
    }));

    it('should fetch template from url using interpolation', async((Scope scope, TemplateCache cache) {
      cache.put('tpl1.html', new HttpResponse(200, 'My name is {{name}}'));
      cache.put('tpl2.html', new HttpResponse(200, 'I am {{name}}'));

      var element = _.compile('<div ng-include="{{template}}"></div>');

      expect(element.innerHtml).toEqual('');

      scope.context['name'] = 'Vojta';
      scope.context['template'] = 'tpl1.html';
      microLeap();
      scope.apply();
      microLeap();
      scope.apply();
      expect(element.text).toEqual('My name is Vojta');

      scope.context['template'] = 'tpl2.html';
      microLeap();
      scope.apply();
      microLeap();
      scope.apply();
      expect(element.text).toEqual('I am Vojta');
    }));

  });
}
