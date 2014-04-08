library angular.dom.element_binder_spec;

import '../_specs.dart';
import 'dart:mirrors';

@NgComponent(selector:'component')            class _Component{}
@NgDirective(selector:'[ignore-children]',
             children: AbstractNgAnnotation.IGNORE_CHILDREN)
                                              class _IgnoreChildren{}
@NgDirective(selector:'[structural]',
             children: AbstractNgAnnotation.TRANSCLUDE_CHILDREN)
                                              class _Structural{}
@NgDirective(selector:'[directive]')          class _DirectiveAttr{}


directiveFor(i) {
  ClassMirror cm = reflectType(i);

}
main() => describe('ElementBinderBuilder', () {
  var b;
  var directives;
  var node = null;

  beforeEachModule((Module module) {
    module
      ..type(_DirectiveAttr)
      ..type(_Component)
      ..type(_IgnoreChildren)
      ..type(_Structural);
  });

  beforeEach((DirectiveMap d, ElementBinderFactory f) {
    directives = d;
    b = f.builder();
  });

  addDirective(selector) {
    directives.forEach((AbstractNgAnnotation annotation, Type type) {
      if (annotation.selector == selector)
        b.addDirective(new DirectiveRef(node, type, annotation, null));
    });
    b = b.binder;
  }

  it('should add a decorator', () {
    expect(b.decorators.length).toEqual(0);

    addDirective('[directive]');

    expect(b.decorators.length).toEqual(1);
    expect(b.component).toBeNull();
    expect(b.childMode).toEqual(AbstractNgAnnotation.COMPILE_CHILDREN);

  });

  it('should add a component', () {
    addDirective('component');

    expect(b.decorators.length).toEqual(0);
    expect(b.component).toBeNotNull();
  });

  it('should add a template', () {
    addDirective('[structural]');

    expect(b.template).toBeNotNull();
  });

  it('should add a directive that ignores children', () {
    addDirective('[ignore-children]');

    expect(b.decorators.length).toEqual(1);
    expect(b.component).toBeNull();
    expect(b.childMode).toEqual(AbstractNgAnnotation.IGNORE_CHILDREN);
  });
});
