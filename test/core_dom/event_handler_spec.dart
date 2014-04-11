library event_handler_spec;

import '../_specs.dart';

@Controller(selector: '[foo]', publishAs: 'ctrl')
class FooController {
  var description = "desc";
  var invoked = false;
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
      module..type(FooController);
      module..type(BarComponent);
      module..value(Element, document.body);
    });

    afterEach(() {
      document.body.children.clear();
    });

    it('shoud register and handle event', inject((TestBed _) {
      document.body.append(_.compile(
        '''<div foo>
          <div on-abc="ctrl.invoked=true;"></div>
        </div>'''));

      document.querySelector('[on-abc]').dispatchEvent(new Event('abc'));
      var fooScope = _.getScope(document.querySelector('[foo]'));
      expect(fooScope.context['ctrl'].invoked).toEqual(true);
    }));

    it('shoud register and handle event with long name', inject((TestBed _) {
      document.body.append(_.compile(
        '''<div foo>
          <div on-my-new-event="ctrl.invoked=true;"></div>
        </div>'''));

      document.querySelector('[on-my-new-event]').dispatchEvent(new Event('myNewEvent'));
      var fooScope = _.getScope(document.querySelector('[foo]'));
      expect(fooScope.context['ctrl'].invoked).toEqual(true);
    }));

    it('shoud have model updates applied correctly', inject((TestBed _) {
      document.body.append(_.compile(
        '''<div foo>
          <div on-abc='ctrl.description="new description";'>{{ctrl.description}}</div>
        </div>'''));
      var el = document.querySelector('[on-abc]');
      el.dispatchEvent(new Event('abc'));
      _.rootScope.apply();
      expect(el.text).toEqual("new description");
    }));

    it('shoud register event when shadow dom is used', async((TestBed _) {
      document.body.append(_.compile('<bar></bar>'));

      microLeap();

      var shadowRoot = _.rootElement.shadowRoot;
      var span = shadowRoot.querySelector('span');
      span.dispatchEvent(new CustomEvent('abc'));
      var ctrl = _.rootScope.context['ctrl'];
      expect(ctrl.invoked).toEqual(true);
    }));

    it('shoud handle event within content only once', async(inject((TestBed _) {
      document.body.append(_.compile(
        '''<div foo>
             <bar>
               <div on-abc="ctrl.invoked=true;"></div>
             </bar>
           </div>'''));

      microLeap();

      document.querySelector('[on-abc]').dispatchEvent(new Event('abc'));
      var shadowRoot = document.querySelector('bar').shadowRoot;
      var shadowRootScope = _.getScope(shadowRoot);
      expect(shadowRootScope.context['ctrl'].invoked).toEqual(false);

      var fooScope = _.getScope(document.querySelector('[foo]'));
      expect(fooScope.context['ctrl'].invoked).toEqual(true);
    })));
  });
}
