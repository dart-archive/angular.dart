library angular.dom.element_binder_spec;

import '../_specs.dart';
import 'dart:mirrors';

@Component(selector:'component')            class _Component{}
@Decorator(selector:'[ignore-children]',
           children: Directive.IGNORE_CHILDREN)
                                            class _IgnoreChildren{}
@Decorator(selector:'[structural]',
           children: Directive.TRANSCLUDE_CHILDREN)
                                            class _Structural{}
@Decorator(selector:'[directive]')          class _DirectiveAttr{}

@Decorator(selector: '[templates]',
          children: Directive.TRANSCLUDE_CHILDREN)
                                            class _Template1{}
@Decorator(selector: '[templates]',
          children: Directive.TRANSCLUDE_CHILDREN)
                                            class _Template2{}


directiveFor(i) {
  ClassMirror cm = reflectType(i);

}
void main() {
  describe('ElementBinderBuilder', () {
    ElementBinderBuilder builder;
    ElementBinder binder;
    var directives;
    var node = new DivElement();

    beforeEachModule((Module module) {
      module..bind(_DirectiveAttr)
            ..bind(_Component)
            ..bind(_IgnoreChildren)
            ..bind(_Structural)
            ..bind(_Template1)
            ..bind(_Template2);
    });

    beforeEach((DirectiveMap d, ElementBinderFactory f, Injector i) {
      directives = d;
      builder = f.builder(null, null, i);
    });

    addDirective(selector) {
      directives.forEach((Directive annotation, Type type) {
        if (annotation.selector == selector)
          builder.addDirective(new DirectiveRef(node, type, annotation, new Key(type), null));
      });
      binder = builder.binder;
    }

    it('should add a decorator', () {
      expect(builder.decorators.length).toEqual(0);

      addDirective('[directive]');

      expect(binder.decorators.length).toEqual(1);
      expect(binder.componentData).toBeNull();
      expect(binder.childMode).toEqual(Directive.COMPILE_CHILDREN);

    });

    it('should add a component', async(() {
      addDirective('component');

      expect(binder.decorators.length).toEqual(0);
      expect(binder.componentData).toBeNotNull();
    }));

    it('should add a template', () {
      addDirective('[structural]');

      expect(binder.template).toBeNotNull();
    });

    it('could have at most one template', () {
      expect(() => addDirective(('[templates]')))
          .toThrowWith(message: "There could be at most one transcluding directive on a node. The "
                                "node '<div></div>' has both '[templates]' and '[templates]'.");
    });

    it('should add a directive that ignores children', () {
      addDirective('[ignore-children]');

      expect(binder.decorators.length).toEqual(1);
      expect(binder.componentData).toBeNull();
      expect(binder.childMode).toEqual(Directive.IGNORE_CHILDREN);
    });
  });
}
