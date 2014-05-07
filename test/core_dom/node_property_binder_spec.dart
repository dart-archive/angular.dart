library angular.core_dom.node_property_binder_spec;

import '../_specs.dart';
import 'package:angular/core_dom/node_property_binder.dart';
import 'dart:html';


main() {
  ddescribe('node_property_binder', () {
    Injector injector;
    RootScope rootScope;
    Map context;
    Element appElement;
    InputElement inputElement;
    NodeBinderBuilder nodePropertiesBinderBuilder;
    Case _case = new Case();

    beforeEachModule((Module m) {
      m.bind(MyDirective);
      m.bind(GenericDirective);
    });

    beforeEach((RootScope _scope, Injector _injector, Expando expando) {
      rootScope = _scope;
      context = rootScope.context;
      injector = _injector;
      appElement = injector.get(Node);
      inputElement = new InputElement();
      nodePropertiesBinderBuilder = new NodeBinderBuilder(
          injector.get(Parser),
          injector.get(ExceptionHandler));
      expando[appElement] = new ElementProbe(null, appElement, injector, rootScope);
    });

    afterEach(() {
      injector = rootScope = context = inputElement = nodePropertiesBinderBuilder = null;
    });

    setup(Element element,
          { Scope scope,
            Map attrs,
            List<String> events: const ['change'],
            Map<Type, Directive> directives: const {} }) {
      appElement.append(element);
      Map<String, String> bindings = {};
      Map<String, String> onEvents = {};
      attrs.forEach((name, value) {
        element.attributes[name] = value;
        if (name.startsWith('bind-')) {
          bindings[name.substring('bind-'.length)] = value;
        }
        if (name.startsWith('on-')) {
          onEvents[name.substring('on-'.length)] = value;
        }
      });
      if (scope == null) scope = rootScope;
      NodeBinder binder = nodePropertiesBinderBuilder.build(
          element, events, attrs, bindings, onEvents, directives);
      binder.bind(injector, scope, injector.get(FormatterMap), injector.get(EventHandler), element);
    }

    describe('camelCase', () {
      it('should camelCase', () {
        expect(_case.camel('foo')).toEqual('foo');
        expect(_case.camel('foo-bar')).toEqual('fooBar');
        expect(_case.camel('foo--bar')).toEqual('fooBar');
        expect(_case.camel('foo-bar-baz')).toEqual('fooBarBaz');
      });

      it('should camelCase exceptions', () {
        expect(_case.camel('read-only')).toEqual('readOnly');
        expect(_case.camel('readonly')).toEqual('readOnly');
      });

      it('should dashCase', () {
        expect(_case.dash('bar')).toEqual('bar');
        expect(_case.dash('innerHTML')).toEqual('inner-html');
      });

      it('should dashCase exceptions', () {
        expect(_case.dash('readOnly')).toEqual('readonly');
      });
    });

    describe('no directive binding', () {
      it('should set up unibinding on element', () {
        setup(inputElement, attrs: {'bind-value': 'text'});

        rootScope.apply('text = "hello"');
        expect(inputElement.value).toEqual('hello');

        rootScope.apply('text = "bye"');
        expect(inputElement.value).toEqual('bye');
      });

      it('should set up bibinding on element', (TestBed _, Logger logger) {
        setup(inputElement,
              attrs: {'bind-value': 'model',
                      'value': 'should not see'});
        rootScope.domWrite(() => logger('flush'));
        rootScope.domWrite(() => logger('input.value=${inputElement.value}'));
        rootScope.domRead(() => logger('input.value=${inputElement.value}'));
        rootScope.apply('model = "initial"');
        expect(logger).toEqual(['flush', 'input.value=should not see', 'input.value=initial']);

        expect(context['model']).toEqual('initial');

        inputElement.value = 'hello';
        _.triggerEvent(inputElement, 'change');
        expect(context['model']).toEqual('hello');

        inputElement.value = 'bye';
        _.triggerEvent(inputElement, 'change');
        expect(context['model']).toEqual('bye');
      });

      it('should not set up bibinding on element when interpolating', (TestBed _) {
        setup(inputElement,
              attrs: {'bind-value': '(text|stringify)',
                      'value': 'should not see'});

        expect(context['text']).toEqual(null);

        inputElement.value = 'hello';
        _.triggerEvent(inputElement, 'change');
        expect(context['text']).toEqual(null);
      });

      it('should bind to non-existant property', () {
        setup(inputElement, attrs: {'bind-dont-exist': 'text'});
        // should not throw
      });
    });

    describe('directive binding', () {
      it('should bind to existing properties', (Logger logger) {
        setup(inputElement, 
            attrs: {
                'bind-title': 'titleExp',
                'value': 'Initial Value'},
            directives: {
                MyDirective: new Decorator(
                    bind: {
                      'title': 'title',
                      'value': 'name'
                    }),
                GenericDirective: new Decorator(
                    bind: {
                        'title': 'a',
                        'value': 'b'
                    })});
        MyDirective myDirective = injector.get(MyDirective);
        GenericDirective genericDirective = injector.get(GenericDirective);

        rootScope.domWrite(() => logger('flush'));
        rootScope.domWrite(() => logger('input.title=${inputElement.title}'));
        rootScope.domRead(() => logger('input.title=${inputElement.title}'));
        rootScope.apply('titleExp = "Initial Title"');
        // Verify that the directive setters get called before flush phase, but DOM write in flush.
        expect(logger).toEqual(
            [ 'name=Initial Value', 'b=Initial Value', 'title=Initial Title', 'a=Initial Title',
              'attach:my', 'attach:generic', 'flush',
              'input.title=', 'input.title=Initial Title' ]);

        expect(myDirective.title).toEqual('Initial Title');
        expect(myDirective.name).toEqual('Initial Value');
        expect(genericDirective.a).toEqual('Initial Title');
        expect(genericDirective.b).toEqual('Initial Value');
      });

      it('should bind to non-existing properties', () {
        setup(inputElement, 
            attrs: {
                'bind-dont-exist1': 'exp',
                'dont-exist2': 'two'},
            directives: {
                GenericDirective: new Decorator(
                    bind: {
                        'dontExist1': 'a',
                        'dontExist2': 'b'
                    })});
        GenericDirective genericDirective = injector.get(GenericDirective);
        rootScope.apply('exp = "one"');
        expect(genericDirective.a).toEqual('one');
        expect(genericDirective.b).toEqual('two');
      });
    });

    it('should update other directive when value changes', (Logger logger) {
      setup(inputElement, 
          attrs: {
              'bind-value': 'exp'},
          directives: {
              MyDirective: new Decorator(
                  bind: { 'value': 'name' },
                  observe: { 'name': 'onNameChange' }),
              GenericDirective: new Decorator(
                  bind: { 'value': 'a' },
                  observe: {'a': 'onAChange'})
          });
      MyDirective myDirective = injector.get(MyDirective);
      GenericDirective genericDirective = injector.get(GenericDirective);
      rootScope.domWrite(() => logger('flush'));
      rootScope.apply('exp = "ABC"');
      expect(myDirective.name).toEqual('ABC');
      expect(genericDirective.a).toEqual('ABC');
      expect(logger).toEqual(
          ['name=ABC', 'My: ABC <- null', 'a=ABC', 'Generic: ABC <- null',
           'attach:my', 'attach:generic','flush']);
      logger.clear();

      genericDirective.a = '123';
      rootScope.domWrite(() => logger('flush'));
      rootScope.apply();
      expect(inputElement.value).toEqual('123');
      expect(myDirective.name).toEqual('123');
      expect(genericDirective.a).toEqual('123');
      expect(logger).toEqual(
          ['a=123', 'name=123', 'My: 123 <- ABC', 'a=123', 'Generic: 123 <- ABC', 'flush']);
      logger.clear();
    });

    describe('child nodes binding', () {
      var div;
      beforeEach(() {
        div = new Element.html('<div>pre<span>:</span>post</div>');
      });

      it('should bind to child index propertie', () {
        setup(div, attrs: {'bind-2-text': 'model', 'bind-3-text': 'should ignore me'});

        rootScope.apply('model = "hello"');
        expect(div.text).toEqual('pre:hello');

        rootScope.apply('model = "bye"');
        expect(div.text).toEqual('pre:bye');
      });
    });

    describe('attach/detach', () {
      it('should fire attach after model stabalizes', (Logger logger) {
        var childScope = rootScope.createChild({});
        setup(inputElement,
              scope: childScope,
              attrs: {},
              directives: {
                  MyDirective: new Decorator(bind: { 'value': 'name' }),
                  GenericDirective: new Decorator(bind: { 'value': 'a' })
              });
        MyDirective myDirective = injector.get(MyDirective);
        GenericDirective genericDirective = injector.get(GenericDirective);

        rootScope.apply();
        expect(logger).toEqual(['name=', 'a=', 'attach:my', 'attach:generic']);
        logger.clear();

        childScope.destroy();
        expect(logger).toEqual(['detach:my', 'detach:generic']);
      });
    });

    describe('events', () {
      it('should register on-events', (TestBed tb, Scope scope) {
        setup(inputElement, attrs: {'on-foo': 'event = true'});
        scope.context['event'] = false;
        expect(scope.context['event']).toEqual(false);
        tb.triggerEvent(inputElement, 'foo');
        expect(scope.context['event']).toEqual(true);
      });

    });
  });
}

class MyDirective implements AttachAware, DetachAware {
  Logger logger;
  var _title = 'default';
  get title => _title;
  set title(v) { logger('title=$v'); _title = v;}

  var _name = 'default';
  get name => _name;
  set name(v) { logger('name=$v'); _name = v;}

  MyDirective(this.logger);

  onNameChange(value, old) => logger('My: $value <- $old');
  attach() => logger('attach:my');
  detach() => logger('detach:my');
}

class GenericDirective implements AttachAware, DetachAware {
  Logger logger;
  var _a;
  get a => _a;
  set a(v) { logger('a=$v'); _a = v;}
  
  var _b;
  get b => _b;
  set b(v) { logger('b=$v'); _b = v;}

  GenericDirective(this.logger);

  onAChange(value, old) => logger('Generic: $value <- $old');
  attach() => logger('attach:generic');
  detach() => logger('detach:generic');
}
