library event_handler_spec;

import '../_specs.dart';

@Decorator(selector: '[foo]')
class FooController {
  var description = "desc";
  var invoked = false;
  FooController(Scope scope) {
    scope.context['foo'] = this;
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
    scope.context['bar'] = this;
  }
}

main() {
  describe('EventHandler', () {
    Element ngAppElement;
    beforeEachModule((Module module) {
      ngAppElement = new DivElement()..attributes['ng-app'] = '';
      module..bind(FooController);
      module..bind(BarComponent);
      module..bind(Node, toValue: ngAppElement);
      document.body.append(ngAppElement);
    });

    afterEach(() {
      ngAppElement.remove();
      ngAppElement = null;
    });

    compile(_, html) {
      ngAppElement.setInnerHtml(html, treeSanitizer: new NullTreeSanitizer());
      _.compile(ngAppElement);
      return ngAppElement.firstChild;
    }

    it('should register and handle event', inject((TestBed _) {
      var e = compile(_,
        '''<div foo>
          <div on-abc="foo.invoked=true;"></div>
        </div>''');

      _.triggerEvent(e.querySelector('[on-abc]'), 'abc');
      expect(_.getScope(e).context['foo'].invoked).toEqual(true);
    }));

    it('shoud register and handle event with long name', inject((TestBed _) {
      var e = compile(_,
        '''<div foo>
          <span on-my-new-event="foo.invoked=true;"></span>
        </div>''');

      _.triggerEvent(e.querySelector('[on-my-new-event]'), 'myNewEvent');
      var fooScope = _.getScope(e);
      expect(fooScope.context['foo'].invoked).toEqual(true);
    }));

    it('shoud have model updates applied correctly', inject((TestBed _) {
      var e = compile(_,
        '''<div foo>
          <div on-abc='foo.description="new description";'>{{foo.description}}</div>
        </div>''');
      var el = document.querySelector('[on-abc]');
      el.dispatchEvent(new Event('abc'));
      _.rootScope.apply();
      expect(el.text).toEqual("new description");
    }));

    it('shoud register event when shadow dom is used', async((TestBed _) {
      var e = compile(_,'<bar></bar>');

      microLeap();

      var shadowRoot = e.shadowRoot;
      var span = shadowRoot.querySelector('span');
      span.dispatchEvent(new CustomEvent('abc'));
      var bar = _.rootScope.context['bar'];
      expect(bar.invoked).toEqual(true);
    }));

    it('shoud handle event within content only once', async(inject((TestBed _) {
      var e = compile(_,
        '''<div foo>
             <bar>
               <div on-abc="foo.invoked=true;"></div>
             </bar>
           </div>''');

      microLeap();

      document.querySelector('[on-abc]').dispatchEvent(new Event('abc'));
      var shadowRoot = document.querySelector('bar').shadowRoot;
      var shadowRootScope = _.getScope(shadowRoot);
      expect(shadowRootScope.context['ctrl'].invoked).toEqual(false);

      var fooScope = _.getScope(document.querySelector('[foo]'));
      expect(fooScope.context['foo'].invoked).toEqual(true);
    })));
  });
}
