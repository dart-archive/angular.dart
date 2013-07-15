import '../_specs.dart';
import '../_test_bed.dart';
import '../_http.dart';

main() {
  describe('NgInclude', () {
    TestBed _;

    beforeEach(beforeEachTestBed((tb) => _ = tb));

    beforeEach(module((AngularModule module) {
      module.type(HttpFutures, MockHttpFutures);
    }));

    it('should fail', inject((Scope scope, TemplateCache cache, HttpFutures futures) {
      cache.put('tpl.html', 'my name is {{name}}');

      var element = _.compile('<div ng-include="template"></div>');

      expect(element.html()).toEqual('');

      scope.$apply(() {
        scope['name'] = 'Vojta';
        scope['template'] = 'tpl.html';
      });
      futures.trigger();
      expect(element.text()).toEqual('my name is Vojta');
    }));


    it('should support inlined templates', inject((Scope scope) {
      var element = _.compile('<div ng-include="template"></div>');

      scope.$apply(() {
        scope['name'] = 'Vojta';
        scope['template'] = '<span>my inlined name is {{name}}</span>';
      });
      expect(element.text()).toEqual('my inlined name is Vojta');
    }));
  });
}
