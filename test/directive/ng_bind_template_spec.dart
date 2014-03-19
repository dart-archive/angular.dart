library ng_bind_template_spec;

import '../_specs.dart';

main() {
  describe('BindTemplateDirective', () {
    TestBed _;

    beforeEach((TestBed tb) => _ = tb);

    it('should bind template',
          (Scope scope, Injector injector, Compiler compiler) {
      var element = _.compile('<div ng-bind-template="{{salutation}} {{name}}!"></div>');
      scope.context['salutation'] = 'Hello';
      scope.context['name'] = 'Heisenberg';
      scope.apply();

      expect(element.text).toEqual('Hello Heisenberg!');

      scope.context['salutation'] = 'Good-Bye';
      scope.apply();

      expect(element.text).toEqual('Good-Bye Heisenberg!');
    });
  });
}
