library angular.query_spec;

import '../_specs.dart';
import 'package:angular/core_dom/directive_injector.dart';
import 'package:angular/core_dom/query.dart';

void main() {
  describe('Query', () {
    DirectiveInjector root;
    RootScope scope;

    DirectiveInjector cdi(DirectiveInjector parent, Type componentType, Object component) =>
        new ComponentDirectiveInjector(parent, null, null, scope, null, null, null, null, null)
          ..bind(new Key(componentType), toValue: component)
          ..get(componentType);

    DirectiveInjector di(DirectiveInjector parent) =>
        new DirectiveInjector(parent, null, null, null, null, scope, null, null, null);

    beforeEach((RootScope _scope) {
      scope = _scope;
      root = new DirectiveInjector(null, null, null, null, null, scope, null, null, null);
    });

    beforeEachModule((Module m) {
      m.bind(_Component);
      m.bind(_HasComponentInTemplate);
    });

    it("should be empty when not components matching the query", () {
      final q = new Query(root, Query.DEPTH_DESCENDANTS, _Component)..invalidate();

      expect(q.isEmpty).toBeTrue();
    });

    it("should return all the descendant components matching the query", () {
      final c = new _Component("c");
      final gc1 = new _Component("gc1");
      final gc2 = new _Component("gc2");

      /*
        root DI
        |
        child DI
           |-----------------------
      child CDI                   |
                              -----------------
                  grand child 1 DI     grand child 2 DI
                      |                       |
                  grand child 1 CDI    grand child 2 CDI
       */
      final childLightDom = di(root);
      cdi(childLightDom, _Component, c);
      cdi(di(childLightDom), _Component, gc1);
      cdi(di(childLightDom), _Component, gc2);

      final q = new Query(root, Query.DEPTH_DESCENDANTS, _Component)..invalidate();

      expect(q.toList()).toEqual([c,gc1,gc2]);
    });

    it("should return only the direct children matching the query", () {
      final c = new _Component("c");
      final gc = new _Component("gc");

      /*
        root DI
        |
        child DI
           |-----------------------
      child CDI                   |
                              -----------
                  grand child DI
                      |
                  grand child CDI
       */
      final childLightDom = di(root);
      cdi(childLightDom, _Component, c);
      cdi(di(childLightDom), _Component, gc);

      final q = new Query(root, Query.DEPTH_CHILDREN, _Component)..invalidate();

      expect(q.toList()).toEqual([c]);
    });

    it("should not cross component boundaries", () {
      /*
        root DI
           |
        child DI for _HasComponentInTemplate
           |
        child CDI
        ----------------------------- This is the boundary
           |
        grand child DI (hidden)
           |
        grand child CDI
       */
      final childShadowDom = cdi(di(root), _HasComponentInTemplate, new _HasComponentInTemplate());
      cdi(di(childShadowDom), _Component, new _Component("hidden"));

      final q = new Query(root, Query.DEPTH_DESCENDANTS, _Component)..invalidate();

      expect(q.isEmpty).toBeTrue();
    });
  });

  describe("QueryRef", () {
    describe("buildChildRef", () {
      it("should return an inherited query ref", () {
        final r = new QueryRef(new Query(null, Query.DEPTH_CHILDREN, null), false);
        expect(r.buildChildRef().inherited).toBeTrue();
      });

      it("should return null when depth = DEPTH_CHILDREN and inherited", () {
        final r = new QueryRef(new Query(null, Query.DEPTH_CHILDREN, null), true);
        expect(r.buildChildRef()).toBeNull();
      });
    });
  });
}

@Component(selector: 'component')
class _Component {
  final String desc;
  _Component(this.desc);
  String toString() => desc;
}

@Component(
    selector: 'has-component-in-shadow-dom',
    template: '<component></component>'
)
class _HasComponentInTemplate {
}

