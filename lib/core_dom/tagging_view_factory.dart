part of angular.core.dom_internal;

const NG_BINDING = 'ng-binding';
const NG_BINDING_SELECTOR = '.$NG_BINDING';

class TaggingViewFactory implements ViewFactory {
  final List<NodeBinder> elementBinders;
  final dom.Element template;
  final Profiler _perf;
  final bool compileInPlace;

  TaggingViewFactory(this.template, this.elementBinders, this._perf, { this.compileInPlace: false }) {
    assert(this.template.querySelectorAll(NG_BINDING_SELECTOR).length + 1 == elementBinders.length);
  }

  BoundViewFactory bind(Injector injector) =>
  new BoundViewFactory(this, injector);

  View call(Injector injector, Scope scope) {
    assert(injector != null);
    assert(scope != null);
    var timerId;
    try {
      assert((timerId = _perf.startTimer('ng.view')) != false);
      dom.Element instance = compileInPlace ? template : template.clone(true);
      List<dom.Element> elements = [instance];
      elements.addAll(instance.querySelectorAll(NG_BINDING_SELECTOR));
      _bindElements(elements, elementBinders, injector, scope,
          injector.get(Animate), injector.get(EventHandler), injector.get(FormatterMap),
          injector.get(Expando));
      elements.removeAt(0);
      return new View(compileInPlace ? [template] : instance.childNodes.toList());
    } finally {
      assert(_perf.stopTimer(timerId) != false);
    }
  }

  void _bindElements(List<dom.Element> elements, List<NodeBinder> binders, Injector rootInjector,
             Scope scope, Animate animate, EventHandler eventHandler, FormatterMap formatters, Expando expando) {
    assert(elements.length == binders.length);

    var injectors = new List<Injector>(binders.length);
    const NODE = Directive.LOCAL_VISIBILITY;
    const SHOULD_BE_NODE = null; // TODO(misko): fix me.

    for (var i = 0; i < binders.length; i++) {
      var module = new Module();
      ElementProbe elementProbe;
      NodeBinder binder = binders[i];
      var parentIndex = binder.parentBinderOffset;
      dom.Element element = elements[i];
      var ngElement = new NgElement(element, scope, animate, eventHandler);
      if (binder.transcludeBinder != null) {
        module.bind(ViewPort, visibility: NODE);
        module.bind(ViewFactory, toValue: binder.viewFactory/**, visibility: NODE**/);
        module.bind(BoundViewFactory, toFactory: BoundViewFactory.factory, visibility: NODE);
      }
      module.bind(dom.Node, toValue: element, visibility: SHOULD_BE_NODE);
      module.bind(dom.Element, toValue: element, visibility: SHOULD_BE_NODE);
      module.bind(NgElement, toValue: ngElement, visibility: SHOULD_BE_NODE);
      module.bind(OnEvent, toImplementation: NgElement, visibility: SHOULD_BE_NODE);
      module.bind(ElementProbe, toFactory: (i) => elementProbe);
      Injector parentInjector;
      if (parentIndex < 0) {
        parentInjector = rootInjector;
        module.bind(Scope, toValue: scope);
      } else {
        parentInjector = injectors[parentIndex];
      }
      var injector = injectors[i] = parentInjector.createChild([module, binder.module]);
      ElementProbe parentProbe = parentInjector.get(ElementProbe);
      elementProbe = expando[element] = new ElementProbe(parentProbe, element, injector, scope);
      NodeBindings bindings = binder.bind(injector, scope, formatters, eventHandler, ngElement);
      elementProbe.directives.addAll(bindings.directives);
    }
  }
}
