library directive_injector_spec;

import '../_specs.dart';
import 'package:angular/core_dom/directive_injector.dart';
import 'package:angular/core_dom/static_keys.dart';
import 'dart:html' as dom;

void main() {
  describe('DirectiveInjector', () {
    var appInjector = new ModuleInjector([new Module()..bind(_Root)]);
    var div = new DivElement();
    var span = new SpanElement();
    var eventHandler = new EventHandler(null, null, null);

    describe('base', () {
      DirectiveInjector injector;
      Scope scope;
      View view;
      Animate animate;

      addDirective(Type type,
          [Visibility visibility, DirectiveInjector targetInjector]) {
        if (targetInjector == null) targetInjector = injector;
        if (visibility == null) visibility = Visibility.LOCAL;
        var reflector = Module.DEFAULT_REFLECTOR;
        targetInjector.bindByKey(new Key(type), reflector.factoryFor(type),
            reflector.parameterKeysFor(type), visibility);
      }

      beforeEach((Scope _scope, Animate _animate) {
        scope = _scope;
        animate = _animate;
        view = new View([], scope);
        injector = new DirectiveInjector(null, appInjector, div,
            new NodeAttrs(div), eventHandler, scope, animate, view);
      });

      it('should return basic types', () {
        expect(injector.scope).toBe(scope);
        expect(injector.get(Injector)).toBe(appInjector);
        expect(injector.get(Scope)).toBe(scope);
        expect((injector.get(View))).toBe(view);
        expect(injector.get(Node)).toBe(div);
        expect(injector.get(Element)).toBe(div);
        expect((injector.get(NodeAttrs) as NodeAttrs).element).toBe(div);
        expect(injector.get(EventHandler)).toBe(eventHandler);
        expect(injector.get(Animate)).toBe(animate);
        expect((injector.get(ElementProbe) as ElementProbe).element).toBe(div);
      });

      it('should support get from parent methods', () {
        var newDiv = new DivElement();
        var childInjector = new DirectiveInjector(injector, appInjector, newDiv,
            new NodeAttrs(newDiv), eventHandler, scope, animate, view);

        expect(childInjector.get(Node)).toBe(newDiv);
        expect(childInjector.getFromParent(Node)).toBe(div);
        expect(childInjector.getFromParentByKey(NODE_KEY)).toBe(div);
      });

      it('should instantiate types', () {
        addDirective(_Type9);
        addDirective(_Type8);
        addDirective(_Type7);
        addDirective(_Type5);
        addDirective(_Type6);
        addDirective(_Type0);
        addDirective(_Type1);
        addDirective(_Type2);
        addDirective(_Type3);
        addDirective(_Type4);
        expect(() => addDirective(_TypeA)).toThrowWith(
            message: 'Maximum number of directives per element reached.');
        var root = injector.get(_Root);
        expect((injector.get(
                _Type9) as _Type9).type8.type7.type6.type5.type4.type3.type2.type1.type0.root)
            .toBe(root);
        expect(() => injector.get(_TypeA)).toThrowWith(
            message: 'No provider found for _TypeA');
      });

      describe("returning SourceLightDom", () {
        it('should return the light dom of the closest host element', () {
          final lightDom = new LightDom(null, null);

          final componentInjector = new ComponentDirectiveInjector(
              injector, null, null, null, null, null, lightDom, null);
          final childInjector = new DirectiveInjector(
              componentInjector, null, null, null, null, null, null, null);
          final grandChildInjector = new DirectiveInjector(
              childInjector, null, null, null, null, null, null, null);

          expect(grandChildInjector.getByKey(SOURCE_LIGHT_DOM_KEY))
              .toBe(lightDom);
        });

        it('should return null otherwise', () {
          expect(injector.getByKey(SOURCE_LIGHT_DOM_KEY)).toBe(null);
        });
      });

      describe("returning DestinationLightDom", () {
        it('should return the light dom of the parent injector', () {
          final lightDom = new LightDom(null, null);
          injector.lightDom = lightDom;

          final childInjector = new DirectiveInjector(
              injector, null, null, null, null, null, null, null);

          expect(childInjector.getByKey(DESTINATION_LIGHT_DOM_KEY))
              .toBe(lightDom);
        });
      });

      describe("returning ShadowBoundary", () {
        it('should return the shadow bounary of the injector', () {
          final root = new dom.DivElement().createShadowRoot();
          final boundary = new ShadowRootBoundary(root);
          final childInjector = new DirectiveInjector(
              injector, null, null, null, null, null, null, null, boundary);

          expect(childInjector.getByKey(SHADOW_BOUNDARY_KEY)).toBe(boundary);
        });

        it('should return the shadow bounary of the parent injector', () {
          final root = new dom.DivElement().createShadowRoot();
          final boundary = new ShadowRootBoundary(root);
          final parentInjector = new DirectiveInjector(
              injector, null, null, null, null, null, null, null, boundary);
          final childInjector = new DirectiveInjector(
              parentInjector, null, null, null, null, null, null, null, null);

          expect(childInjector.getByKey(SHADOW_BOUNDARY_KEY)).toBe(boundary);
        });

        it('should throw we cannot find a shadow boundary', () {
          final childInjector = new DirectiveInjector(
              injector, null, null, null, null, null, null, null, null);

          expect(() => childInjector.getByKey(SHADOW_BOUNDARY_KEY))
              .toThrow("No provider found");
        });
      });

      describe('error handling', () {
        it('should throw circular dependency error', () {
          addDirective(_TypeC0);
          addDirective(_TypeC1, Visibility.CHILDREN);
          addDirective(_TypeC2, Visibility.CHILDREN);
          expect(() => injector.get(_TypeC0)).toThrowWith(where: (e) {
            expect(e is CircularDependencyError).toBeTrue();
          }, message: 'Cannot resolve a circular dependency! '
              '(resolving _TypeC0 -> _TypeC1 -> _TypeC2 -> _TypeC1)');
        });

        it('should throw circular dependency error accross injectors', () {
          var childInjector = new DirectiveInjector(
              injector, appInjector, null, null, null, null, null);

          addDirective(_TypeC0, Visibility.LOCAL, childInjector);
          addDirective(_TypeC1, Visibility.CHILDREN);
          addDirective(_TypeC2, Visibility.CHILDREN);
          expect(() => childInjector.get(_TypeC0)).toThrowWith(where: (e) {
            expect(e is CircularDependencyError).toBeTrue();
          }, message: 'Cannot resolve a circular dependency! '
              '(resolving _TypeC0 -> _TypeC1 -> _TypeC2 -> _TypeC1)');
        });

        it('should throw on invalid visibility', () {
          var childInjector = new DirectiveInjector(
              injector, appInjector, null, null, null, null, null);

          var key = new Key(_InvalidVisibility);
          key.uid = -KEEP_ME_LAST;

          expect(() => childInjector.getByKey(key)).toThrowWith(
              message: 'Invalid visibility "-$KEEP_ME_LAST"');
        });

        it('should throw on invalid id', () {
          var childInjector = new DirectiveInjector(
              injector, appInjector, null, null, null, null, null);

          var key = new Key(_InvalidId);
          key.uid = KEEP_ME_LAST;

          expect(() => childInjector.getByKey(key)).toThrowWith(
              message: 'No provider found for $KEEP_ME_LAST! '
              '(resolving _InvalidId -> $KEEP_ME_LAST)');
        });
      });

      describe('Visibility', () {
        DirectiveInjector childInjector;
        DirectiveInjector leafInjector;

        beforeEach(() {
          childInjector = new DirectiveInjector(
              injector, appInjector, span, null, null, null, null, null);
          leafInjector = new DirectiveInjector(
              childInjector, appInjector, span, null, null, null, null, null);
        });

        it('should not allow reseting visibility', () {
          addDirective(_Type0, Visibility.LOCAL);
          expect(
              () => addDirective(_Type0, Visibility.DIRECT_CHILD)).toThrowWith(
              message: 'Can not set Visibility: DIRECT_CHILD on _Type0, it already has Visibility: LOCAL');
        });

        it('should allow child injector to see types declared at parent injector',
            () {
          addDirective(_Children, Visibility.CHILDREN);
          _Children t = injector.get(_Children);
          expect(childInjector.get(_Children)).toBe(t);
          expect(leafInjector.get(_Children)).toBe(t);
        });

        it('should hide parent injector types when local visibility', () {
          addDirective(_Local, Visibility.LOCAL);
          _Local t = injector.getByKey(_LOCAL);
          expect(() => childInjector.get(_LOCAL)).toThrow();
          expect(() => leafInjector.get(_LOCAL)).toThrow();
        });
      });
    });
  });
}

var _CHILDREN = new Key(_Local);
var _LOCAL = new Key(_Local);
var _TYPE0 = new Key(_Local);

class _Children {}
class _Local {}
class _Direct {}
class _Any {}
class _Root {}
class _Type0 {
  final _Root root;
  _Type0(this.root);
}
class _Type1 {
  final _Type0 type0;
  _Type1(this.type0);
}
class _Type2 {
  final _Type1 type1;
  _Type2(this.type1);
}
class _Type3 {
  final _Type2 type2;
  _Type3(this.type2);
}
class _Type4 {
  final _Type3 type3;
  _Type4(this.type3);
}
class _Type5 {
  final _Type4 type4;
  _Type5(this.type4);
}
class _Type6 {
  final _Type5 type5;
  _Type6(this.type5);
}
class _Type7 {
  final _Type6 type6;
  _Type7(this.type6);
}
class _Type8 {
  final _Type7 type7;
  _Type8(this.type7);
}
class _Type9 {
  final _Type8 type8;
  _Type9(this.type8);
}
class _TypeA {
  final _Type9 type9;
  _TypeA(this.type9);
}

class _TypeC0 {
  final _TypeC1 t;
  _TypeC0(this.t);
}
class _TypeC1 {
  final _TypeC2 t;
  _TypeC1(this.t);
}
class _TypeC2 {
  final _TypeC1 t;
  _TypeC2(this.t);
}

class _InvalidVisibility {}
class _InvalidId {}
