library event_handler_spec;

import '../_specs.dart';

@Controller(selector: '[foo]', publishAs: 'ctrl')
class FooController {
  var description = "desc";
  var invoked = false;
  var anotherInvoked = false;
  EventHandler eventHandler;
  NgElement element;

  FooController(this.element) {
    element.addEventListener('cux', onCux);
    element.addEventListener('cux', onAnotherCux);
  }

  void onCux(Event e) {
    invoked = true;
  }

  void onAnotherCux(Event e) {
    anotherInvoked = true;
  }

}

@Component(selector: 'bar',
    template: '''
              <div>
                <span on-abc="ctrl.invoked=true;"></span>
                <content></content>
              </div>
              ''',
    publishAs: 'ctrl')
class BarComponent {
  var invoked = false;
  BarComponent(RootScope scope) {
    scope.context['ctrl'] = this;
  }
}

main() {
  describe('EventHandler', () {
    beforeEachModule((Module module) {
      module
        ..bind(FooController)..bind(BarComponent);
    });

    it('should register and handle event', inject((TestBed _, MockApplication app) {
      var e = _.compile(
        '''<div foo>
          <div on-abc="ctrl.invoked=true;"></div>
        </div>''');
      app.attachToRenderDOM(e);

      _.triggerEvent(e.querySelector('[on-abc]'), name: 'abc');
      expect(_.getScope(e).context['ctrl'].invoked).toEqual(true);
    }));

    it('should allow registration using method', inject((TestBed _, MockApplication app) {
      var e = _.compile(
      '''<div foo>
          <div baz></div>
        </div>''');
      app.attachToRenderDOM(e);

      _.triggerEvent(e.querySelector('[baz]'), name: 'cux');
      expect(_.getScope(e).context['ctrl'].invoked).toEqual(true);
    }));

    it('should allow registration of multiple event handlers using method',
        inject((TestBed _, MockApplication app) {
      var e = _.compile(
          '''<div foo>
          <div baz></div>
        </div>''');
      app.attachToRenderDOM(e);

      _.triggerEvent(e.querySelector('[baz]'), name: 'cux');
      expect(_.getScope(e).context['ctrl'].invoked).toEqual(true);
      expect(_.getScope(e).context['ctrl'].anotherInvoked).toEqual(true);
    }));

    it('shoud register and handle event with long name', inject((TestBed _, Application app) {
      var e = _.compile(
        '''<div foo>
          <div on-my-new-event="ctrl.invoked=true;"></div>
        </div>''');

      _.triggerEvent(e.querySelector('[on-my-new-event]'), name: 'myNewEvent', type: 'CustomEvent');
      var fooScope = _.getScope(e);
      expect(fooScope.context['ctrl'].invoked).toEqual(true);
    }));

    it('should have model updates applied correctly', inject((TestBed _, Application app) {
      var e = _.compile(
        '''<div foo>
          <div on-abc='ctrl.description="new description";'>{{ctrl.description}}</div>
        </div>''');

      var el = e.querySelector('[on-abc]');
      _.triggerEvent(el, name: 'abc', type: 'CustomEvent');
      _.rootScope.apply();
      expect(el.text).toEqual("new description");
    }));

    it('should register event when shadow dom is used', async((TestBed _, Application app) {
      var e = _.compile('<bar></bar>');

      microLeap();

      var shadowRoot = e.shadowRoot;
      var span = shadowRoot.querySelector('span');
      _.triggerEvent(span, name: 'abc', type: 'CustomEvent');
      var ctrl = _.rootScope.context['ctrl'];
      expect(ctrl.invoked).toEqual(true);
    }));

    it('shoud handle event within content only once', async(inject((TestBed _, Application app) {
      var e = _.compile(
        '''<div foo>
             <bar>
               <div on-abc="ctrl.invoked=true;"></div>
             </bar>
           </div>''');

      microLeap();

      _.triggerEvent(e.querySelector('[on-abc]'), name: 'abc', type: 'CustomEvent');
      var shadowRoot = e.querySelector('bar').shadowRoot;
      var shadowRootScope = _.getScope(shadowRoot);
      expect(shadowRootScope.context['ctrl'].invoked).toEqual(false);

      var fooScope = _.getScope(e);
      expect(fooScope.context['ctrl'].invoked).toEqual(true);
    })));
  });
}
