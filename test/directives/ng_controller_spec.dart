import '../_specs.dart';


class MainController {
  Scope _scope;
  String name = 'name on controller';

  MainController(Scope this._scope) {
    _scope['name'] = 'Vojta';
  }
}


main() {
  beforeEach(module((AngularModule module) {
    module.type(MainController, MainController);
  }));

  describe('NgController', () {
    var compile, element, rootScope;

    beforeEach(inject((Scope scope, Compiler compiler, Injector injector) {
      compile = (html, [applyFn]) {
        element = $(html);
        rootScope = scope;
        compiler(element)(injector, element);
        scope.$apply(applyFn);
        nextTurn(true);
      };
    }));


    it('should instantiate controller', async(() {
      compile('<div><div ng-controller="Main" class="controller">Hi {{name}}</div></div>');
      expect(element.find('.controller').text()).toEqual('Hi Vojta');
    }));


    it('should create a new scope', async(() {
      compile('<div><div ng-controller="Main" class="controller">Hi {{name}}</div><div class="siblink">{{name}}</div></div>', () {
        rootScope['name'] = 'parent';
      });

      expect(element.find('.controller').text()).toEqual('Hi Vojta');
      expect(element.find('.siblink').text()).toEqual('parent');
    }));


    it('should export controller', async(() {
      compile('<div><div ng-controller="Main as main" class="controller">Hi {{main.name}}</div></div>');
      expect(element.find('.controller').text()).toEqual('Hi name on controller');
    }));
  });
}
