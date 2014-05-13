library angular.core_dom.node_property_binder_spec;

import '../_specs.dart';
import 'package:angular/core_dom/node_property_binder.dart';
import 'dart:html';
import 'package:angular/change_detection/change_detection.dart' show
  CollectionChangeRecord, MapChangeRecord;


main() {
  describe('node_property_binder', () {
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
          injector.get(ExceptionHandler),
          injector.get(AutoSelectComponentFactory));
      expando[appElement] = new ElementProbe(null, appElement, injector, rootScope);
    });

    afterEach(() {
      injector = rootScope = context = inputElement = nodePropertiesBinderBuilder = null;
    });

    setup(Element element,
          { Scope scope,
            Map attrs: const {},
            List<String> events: const ['change'],
            Map<Type, Directive> directives: const {} }) {
      appElement.append(element);
      Map<String, String> bindings = {};
      List<String> onEvents = <String>[];
      attrs.forEach((name, value) {
        element.attributes[name] = value;
        if (name.startsWith('bind-')) {
          bindings[name.substring('bind-'.length)] = value;
        }
        if (name.startsWith('on-')) {
          onEvents.add(name.substring('on-'.length));
        }
      });
      if (scope == null) scope = rootScope;
      NodeBinder binder = nodePropertiesBinderBuilder.build(
          element, events, attrs, bindings, onEvents, directives);
      var ngElement = new NgElement(element, scope, null, null);
      binder.bind(injector, scope, injector.get(FormatterMap), injector.get(EventHandler), ngElement);
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


      it('should bind iterable properties', (Logger logger) {
        setup(inputElement,
        attrs: { 'bind-collection': 'list' },
        directives: {
            GenericDirective: new Decorator(
                canChangeModel: false,
                bind: { 'collection': 'a', },
                observe: { 'a': '*onAChange' }),
            MyDirective: new Decorator(
                bind: { 'collection': 'title' })
        });
        var list = rootScope.context['list'] = [];
        rootScope.apply();
        expect(logger).toEqual(
            ['title=[]', 'attach:generic', 'attach:my', 'a=[]', 'Generic: [] <- default']);
        logger.clear();
        list.add('a');
        rootScope.apply();
        expect(logger).toEqual(['title=[a]', 'a=[a]', 'Generic: CollectionChangeRecord <- null']);
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
           'attach:my', 'attach:generic', 'flush']);
      logger.clear();

      genericDirective.a = '123';
      rootScope.domWrite(() => logger('flush'));
      rootScope.apply();
      expect(inputElement.value).toEqual('123');
      expect(myDirective.name).toEqual('123');
      expect(genericDirective.a).toEqual('123');
      expect(logger).toEqual(
          ['a=123', 'name=123', 'My: 123 <- ABC', 'Generic: 123 <- ABC', 'flush']);
      logger.clear();
    });

    describe('canChangeModel', () {
      it('should schedule only one way and flush phase binding', (Logger logger) {
        setup(inputElement,
              attrs: {
                  'bind-value': 'exp'},
              directives: {
                  MyDirective: new Decorator(
                      bind: { 'value': 'name' },
                      observe: { 'name': 'onNameChange' },
                      canChangeModel: false)});

        MyDirective myDirective = injector.get(MyDirective);
        rootScope.domWrite(() => logger('flushStart'));
        rootScope.domRead(() => logger('flushEnd'));
        rootScope.apply('exp = "ABC"');
        expect(myDirective.name).toEqual('ABC');
        expect(logger).toEqual(
            ['attach:my', 'flushStart', 'name=ABC', 'My: ABC <- null', 'flushEnd']);
        logger.clear();

        myDirective.name = 'foo';
        logger.clear(); // clear assignment
        rootScope.apply();
        expect(myDirective.name).toEqual('foo');
        expect(rootScope.context['exp']).toEqual('ABC');
        expect(logger).toEqual([]);
      });

      it('should support mix canChangeModel', (Logger logger) {
        setup(inputElement,
              attrs: {
                  'bind-value': 'exp'},
              directives: {
                  MyDirective: new Decorator(
                      bind: { 'value': 'name' },
                      observe: { 'name': 'onNameChange' },
                      canChangeModel: false),
                  GenericDirective: new Decorator(
                      bind: { 'value': 'a' },
                      observe: {'a': 'onAChange'},
                      canChangeModel: true)
              });
        rootScope.apply();
        expect(logger).toEqual(
            [ 'a=null', 'Generic: null <- null', 'attach:my', 'attach:generic',
              // canChangeModel false
              'name=null', 'My: null <- initial a' ]);
        logger.clear();

        MyDirective myDirective = injector.get(MyDirective);
        rootScope.domWrite(() => logger('flushStart'));
        rootScope.domRead(() => logger('flushEnd'));
        rootScope.apply('exp = "ABC"');
        expect(myDirective.name).toEqual('ABC');
        expect(logger).toEqual(
            ['a=ABC', 'Generic: ABC <- null',
             'flushStart', 'name=ABC', 'My: ABC <- null', 'flushEnd']);
        logger.clear();
      });
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

    describe('transclusion', () {
      it('should split bindings by template directive', () {
        var events = ['event'];
        var onEvents = ['onEvent'];
        var attrs = {};
        var bindings = { 'name': 'nameExp', 'value': 'valueExp' };
        var directives = {
            MyDirective: new Decorator(
                children: Directive.TRANSCLUDE_CHILDREN,
                bind: { 'name': 'name' },
                observe: { 'name': 'onNameChange' },
                canChangeModel: false),
            GenericDirective: new Decorator(
                bind: { 'value': 'a' },
                observe: {'a': 'onAChange'},
                canChangeModel: true)
        };
        NodeBinder binder = nodePropertiesBinderBuilder.build(
            inputElement, events, attrs, bindings, onEvents, directives);

        expect(binder.templateElement).toEqual(inputElement);
        expect(binder.events).toEqual([]);
        expect(binder.onEvents).toEqual([]);
        expect(binder.nodePropertyBinders.length).toEqual(1);
        var nodePropertyBinders = binder.nodePropertyBinders;
        expect(nodePropertyBinders.length).toEqual(1);
        expect(nodePropertyBinders[0].property).toEqual('name');
        expect(nodePropertyBinders[0].directivePropertyBinders.length).toEqual(1);
        expect(nodePropertyBinders[0].directivePropertyBinders[0].watchExp).toEqual('name');
        expect(binder.directiveTypes).toEqual([MyDirective]);

        NodeBinder transcludeBinder = binder.transcludeBinder;
        expect(transcludeBinder.templateElement).toEqual(inputElement);
        expect(transcludeBinder.events).toEqual(['event']);
        expect(transcludeBinder.onEvents).toEqual(['onEvent']);
        nodePropertyBinders = transcludeBinder.nodePropertyBinders;
        expect(nodePropertyBinders.length).toEqual(1);
        expect(nodePropertyBinders[0].property).toEqual('value');
        expect(nodePropertyBinders[0].directivePropertyBinders.length).toEqual(1);
        expect(nodePropertyBinders[0].directivePropertyBinders[0].watchExp).toEqual('a');
        expect(transcludeBinder.directiveTypes).toEqual([GenericDirective]);
        expect(nodePropertyBinders[0].directivePropertyBinders[0].index).toEqual(0);
      });
    });

    describe('default values', () {
      it('should take directive initial value', (Logger log) {
        inputElement.value = 'initialValue';
        setup(inputElement,
            directives: {
                MyDirective: new Decorator(
                    bind: {
                      'value': 'name',
                      'nonStandardAttribute': 'title'
                    },
                    observe: {
                      'title': 'onNameChange'
                    })});

        rootScope.apply();

        MyDirective directive = injector.get(MyDirective);

        expect(log).toEqual(['name=initialValue', 'My: default <- null', 'attach:my']);
        expect(inputElement.value).toEqual('initialValue');
        print('title: ${directive.title}; name: ${directive.name}');
        expect(directive.name).toEqual('initialValue');
        expect(directive.title).toEqual('default');
      });

      it('should take binding intitial value over directive', () {
        inputElement.value = 'initialValue';
        setup(inputElement,
            attrs: {
              'bind-value': 'myValue',
              'title': 'Title'
            },
            directives: {
                MyDirective: new Decorator(
                    bind: {
                        'value': 'name',
                        'title': 'title'
                    })});

        rootScope.context['myValue'] = 'Value123';
        rootScope.apply();
        MyDirective directive = injector.get(MyDirective);

        expect(inputElement.value).toEqual('Value123');
        expect(inputElement.title).toEqual('Title');

        expect(directive.name).toEqual('Value123');
        expect(directive.title).toEqual('Title');
      });
    });
  });
}

_verifyAssignment(name, logger, value, oldValue) {
  if (identical(value, oldValue) && value is! List) {
    throw "Reasignment error for $name=$value <- $oldValue!";
  }
  logger('$name=$value');
  return value;
}

class MyDirective implements AttachAware, DetachAware {
  Logger logger;
  var _title = 'default';
  get title => _title;
  set title(v) => _title = _verifyAssignment('title', logger, v, _title);
  
  var _name = 'default';
  get name => _name;
  set name(v) => _name = _verifyAssignment('name', logger, v, _name);

  MyDirective(this.logger);

  onNameChange(value, old) => logger('My: $value <- $old');
  attach() => logger('attach:my');
  detach() => logger('detach:my');
}

class GenericDirective implements AttachAware, DetachAware {
  Logger logger;
  var _a = 'initial a';
  get a => _a;
  set a(v) => _a = _verifyAssignment('a', logger, v, _a);
  
  var _b = 'initial b';
  get b => _b;
  set b(v) => _b = _verifyAssignment('b', logger, v, _b);

  GenericDirective(this.logger);

  onAChange(value, old) =>
      logger('Generic: ${value is CollectionChangeRecord ? 'CollectionChangeRecord' : value} <- $old');
  attach() => logger('attach:generic');
  detach() => logger('detach:generic');
}
