library ng_include_spec;

import '../_specs.dart';

main() {
  describe('NgInclude', () {
    TestBed _;

    beforeEach((TestBed tb) => _ = tb);

    it('should fetch template from literal url',
        async((Scope scope, TemplateCache cache) {
      cache.put('tpl.html', new HttpResponse(200, 'my name is {{name}}'));

      var element = _.compile('<div ng-include="tpl.html"></div>');

      expect(element).toHaveText('');

      microLeap(); // load the template from cache.
      scope.context['name'] = 'Vojta';
      scope.apply();
      expect(element).toHaveText('my name is Vojta');
    }));

    it('should fetch template from url using interpolation',
        async((Scope scope, TemplateCache cache) {
      cache.put('tpl1.html', new HttpResponse(200, 'My name is {{name}}'));
      cache.put('tpl2.html', new HttpResponse(200, 'I am {{name}}'));

      var element = _.compile('<div ng-include="{{template}}"></div>');

      expect(element).toHaveText('');

      scope.context['name'] = 'Vojta';
      scope.context['template'] = 'tpl1.html';
      microLeap();
      scope.apply();
      microLeap();
      scope.apply();
      expect(element).toHaveText('My name is Vojta');

      scope.context['template'] = 'tpl2.html';
      microLeap();
      scope.apply();
      microLeap();
      scope.apply();
      expect(element).toHaveText('I am Vojta');
    }));

    it('should create and destroy a child scope',
        async((Scope scope, TemplateCache cache) {
      cache.put(
          'tpl.html', new HttpResponse(200, '<p probe="probe">include</p>'));

      var getChildScope = () =>
          scope.context['probe'] == null ? null : scope.context['probe'].scope;

      var element = _.compile('<div ng-include="{{template}}"></div>');

      expect(element).toHaveText('');
      expect(getChildScope()).toBeNull();

      scope.context['template'] = 'tpl.html';
      microLeap();
      scope.apply();
      microLeap();
      scope.apply();
      expect(element).toHaveText('include');
      var childScope1 = getChildScope();
      expect(childScope1).toBeNotNull();
      var destroyListener = guinness.createSpy('destroy child scope');
      var watcher = childScope1.on(ScopeEvent.DESTROY).listen(destroyListener);

      scope.context['template'] = null;
      microLeap();
      scope.apply();
      expect(element).toHaveText('');
      expect(getChildScope()).toBeNull();
      expect(destroyListener).toHaveBeenCalledOnce();

      scope.context['template'] = 'tpl.html';
      microLeap();
      scope.apply();
      microLeap();
      scope.apply();
      expect(element).toHaveText('include');
      var childScope2 = getChildScope();
      expect(childScope2).toBeNotNull();
      expect(childScope2).not.toBe(childScope1);
    }));
  });
}
