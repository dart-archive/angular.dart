library event_handler_spec;

import '../_specs.dart';

@NgController(selector: '[foo]', publishAs: 'ctrl')
class FooController {
  var description = "desc";
  var invoked = false;
}

@NgComponent(selector: 'bar',
    template: '''
              <div>
                <span on-abc="ctrl.invoked=true;"></span>
                <content></content>
              </div>
              ''',
    publishAs: 'ctrl')
class BarComponent {
  var invoked = false;
}

main() {
  ddescribe('EventHandler', () {
    Compiler compiler;
    DirectiveMap directives;
    Injector injector;
    Expando expando;
    Element rootElement;
    RootScope rootScope;

    beforeEach(module((Module module) {
      module..type(FooController);
      module..type(BarComponent);
      return (Injector _injector) {
        injector = _injector;
        compiler = injector.get(Compiler);
        directives = injector.get(DirectiveMap);
        expando = injector.get(Expando);
        rootElement = injector.get(Element);
        rootScope = injector.get(RootScope);
      };
    }));

    it('shoud register and handle event', inject(() {
      var template = '''
        <div foo>
          <div on-abc="ctrl.invoked=true;"></div>
        </div>
      ''';
      // We need to attach to document.body to have events actually travel
      // through DOM.
      $(rootElement).html(template);
      compiler([rootElement], directives)(injector, [rootElement]);

      document.querySelector('[on-abc]').dispatchEvent(new Event('abc'));
      var fooScope = expando[document.querySelector('[foo]')].scope;
      expect(fooScope.context['ctrl'].invoked).toEqual(true);
    }));

    it('shoud register and handle event with long name', inject(() {
      var template = '''
        <div foo>
          <div on-my-new-event="ctrl.invoked=true;"></div>
        </div>
      ''';
      // We need to attach to document.body to have events actually travel
      // through DOM.
      $(rootElement).html(template);
      compiler([rootElement], directives)(injector, [rootElement]);

      document.querySelector('[on-my-new-event]').dispatchEvent(new Event('myNewEvent'));
      var fooScope = expando[document.querySelector('[foo]')].scope;
      expect(fooScope.context['ctrl'].invoked).toEqual(true);
    }));

    it('shoud have model updates applied correctly', inject(() {
      var template = '''
        <div foo>
          <div on-abc='ctrl.description="new description";'>{{ctrl.description}}</div>
        </div>
      ''';
      // We need to attach to document.body to have events actually travel
      // through DOM.
      $(rootElement).html(template);
      compiler([rootElement], directives)(injector, [rootElement]);

      var el = document.querySelector('[on-abc]');
      el.dispatchEvent(new Event('abc'));
      rootScope.apply();
      expect(el.text).toEqual("new description");
    }));

    iit('shoud register event when shadow dom is used', async(inject(() {
      var template = '<bar></bar>';
      $(rootElement).html(template);
      compiler([rootElement], directives)(injector, [rootElement]);

      microLeap();

      var shadowRoot = document.querySelector('bar').shadowRoot;
      var el = shadowRoot.querySelector('span');
      shadowRoot.querySelector('span').dispatchEvent(new Event('abc'));
      var shadowRootScope = expando[shadowRoot].scope;
      expect(shadowRootScope.context['ctrl'].invoked).toEqual(true);
    })));

    it('shoud handle event within content only once', async(inject(() {
      var template = '''
                     <div foo>
                       <bar>
                         <div on-abc="ctrl.invoked=true;"></div>
                       </bar>
                     </div>
                     ''';
      $(rootElement).html(template);
      compiler([rootElement], directives)(injector, [rootElement]);

      microLeap();

      .querySelector('[on-abc]').dispatchEvent(new Event('abc'));
      var shadowRoot = document.querySelector('bar').shadowRoot;
      var shadowRootScope = expando[shadowRoot].scope;
      expect(shadowRootScope.context['ctrl'].invoked).toEqual(false);

      var fooScope = expando[document.querySelector('[foo]')].scope;
      expect(fooScope.context['ctrl'].invoked).toEqual(true);
    })));
  });
}
