library angular.dom.element_binder_spec;

import '../_specs.dart';
import 'dart:mirrors';

@NgComponent(selector:'component')            class _Component{}
@NgDirective(selector:'[ignore-children]',
             children: NgAnnotation.IGNORE_CHILDREN)
                                              class _IgnoreChildren{}
@NgDirective(selector:'[structural]',
             children: NgAnnotation.TRANSCLUDE_CHILDREN)
                                              class _Structural{}
@NgDirective(selector:'[directive]')          class _DirectiveAttr{}


directiveFor(i) {
  ClassMirror cm = reflectType(i);

}
main() => describe('ElementBinder', () {
  var b;
  var directives;
  var node = null;

  beforeEach(module((Module module) {
    module
      ..type(_DirectiveAttr)
      ..type(_Component)
      ..type(_IgnoreChildren)
      ..type(_Structural);
  }));

  beforeEach(inject((DirectiveMap d, ElementBinderFactory f) {
    directives = d;
    b = f.binder();
  }));

  addDirective(selector) {
    directives.forEach((NgAnnotation annotation, Type type) {
      if (annotation.selector == selector)
        b.addDirective(new DirectiveRef(node, type, annotation, null));
    });
  }

  it('should add a decorator', () {
    expect(b.decorators.length).toEqual(0);

    addDirective('[directive]');

    expect(b.decorators.length).toEqual(1);
    expect(b.component).toBeNull();
    expect(b.template).toBeNull();
    expect(b.childMode).toEqual(NgAnnotation.COMPILE_CHILDREN);

  });

  it('should add a component', () {
    addDirective('component');

    expect(b.decorators.length).toEqual(0);
    expect(b.component).toBeNotNull();
    expect(b.template).toBeNull();
  });

  it('should add a template', () {
    addDirective('[structural]');

    expect(b.decorators.length).toEqual(0);
    expect(b.component).toBeNull();
    expect(b.template).toBeNotNull();
  });

  it('should add a directive that ignores children', () {
    addDirective('[ignore-children]');

    expect(b.decorators.length).toEqual(1);
    expect(b.component).toBeNull();
    expect(b.template).toBeNull();
    expect(b.childMode).toEqual(NgAnnotation.IGNORE_CHILDREN);
  });
});
