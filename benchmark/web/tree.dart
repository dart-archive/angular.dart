import 'package:di/di.dart';
import 'package:angular/angular.dart';
import 'package:angular/core_dom/module_internal.dart';
import 'package:angular/application_factory.dart';

import 'dart:html';
import 'dart:math';
import 'dart:js' as js;

@Component(
    selector: 'tree',
    template: '<span> {{ctrl.data.value}}'
    '<span ng-if="ctrl.data.right != null"><tree data=ctrl.data.right></span>'
    '<span ng-if="ctrl.data.left != null"><tree data=ctrl.data.left></span>'
    '</span>',
    publishAs: 'ctrl')
class TreeComponent {
  @NgOneWay('data')
  var data;
}


// This is a baseline implementation of TreeComponent.
// It assumes the data never changes and simply throws elements on the DOM
@Component(
  selector: 'ng-free-tree',
  template: ''
  )
class NgFreeTree implements ShadowRootAware {
  var _data;

  @NgOneWay('data')
  set data(v) {
    _data = v;
    if (sroot != null)
    updateElement(sroot, _data);
  }

  ShadowRoot sroot;

  void onShadowRoot(root) {
    sroot = root;
    if (_data != null) updateElement(sroot, _data);
  }

  Element newFreeTree(tree) {
    var elt = new Element.tag('ng-fre-tree');
    var root = elt.createShadowRoot();

    var s = new SpanElement();
    root.append(s);
    var value = tree['value'];
    if (value != null) {
      s.text = " $value";
    }
    if (tree.containsKey('right')) {
      s.append(new SpanElement()
          ..append(newFreeTree(tree['right'])));
    }
    if (tree.containsKey('left')) {
      s.append(new SpanElement()
        ..append(newFreeTree(tree['left'])));
    }
    return elt;
  }

  updateElement(root, tree) {
    // Not quite acurate
    root.innerHtml = '';
    root.append(newFreeTree(tree));
  }
}

/**
 *  A baseline version of TreeComponent which uses Angular's Scope to
 *  manage data.  This version is setting up data binding so arbitrary
 *  elements in the tree can change.
 *
 *  Note that removing subtrees is not implemented as that feature
 *  is never exercised in the benchmark.
 */
@Component(
  selector: 'ng-free-tree-scoped',
  template: ''
  )
class NgFreeTreeScoped implements ShadowRootAware {
  var _data;

  @NgOneWay('data')
  set data(v) {
    _data = v;
    if (sroot != null)
    updateElement(sroot, _data);
  }

  ShadowRoot sroot;
  Scope scope;
  NgFreeTreeScoped(Scope this.scope);

  void onShadowRoot(root) {
    sroot = root;
    if (_data != null) updateElement(sroot, _data);
  }

  Element newFreeTree(parentScope, treeExpr) {
    var elt = new Element.tag('ng-fre-tree');
    var root = elt.createShadowRoot();
    var scope = parentScope.createChild({});

    parentScope.watch(treeExpr, (v, _) {
      scope.context['tree'] = v;
    });

    var s = new SpanElement();
    root.append(s);
    scope.watch('tree.value', (v, _) {
      if (v != null) {
        s.text = " $v";
      }
    });

    scope.watch('tree.right != null', (v, _) {
      if (v != true) return;
      s.append(new SpanElement()
          ..append(newFreeTree(scope, 'tree.right')));
    });

    scope.watch('tree.left != null', (v, _) {
      if (v != true) return;
      s.append(new SpanElement()
        ..append(newFreeTree(scope, 'tree.left')));
    });

    return elt;
  }

  Scope treeScope;
  updateElement(root, tree) {
    // Not quite acurate
    if (treeScope != null) {
      treeScope.destroy();
    }
    treeScope = scope.createChild({});
    treeScope.context['tree'] = tree;
    root.innerHtml = '';
    root.append(newFreeTree(treeScope, 'tree'));
  }
}


/**
 * A scope-backed baseline that data-binds through a Dart object.
 * This is the pattern that we are using in Components.
 *
 * The benchmark does not show this approach as any slower than
 * binding to the model directly.
 */
class FreeTreeClass {
  // One-way bound
  var tree;
  Scope parentScope;

  FreeTreeClass(this.parentScope, treeExpr) {
    parentScope.watch(treeExpr, (v, _) {
      tree = v;
    });
  }

  Element element() {
    var elt = new Element.tag('ng-fre-tree');
    var root = elt.createShadowRoot();
    var scope = parentScope.createChild(this);

    var s = new SpanElement();
    root.append(s);
    scope.watch('tree.value', (v, _) {
      if (v != null) {
        s.text = " $v";
      }
    });
    
    scope.watch('tree.right != null', (v, _) {
      if (v != true) return;
      s.append(new SpanElement()
          ..append(new FreeTreeClass(scope, 'tree.right').element()));
    });
    
    scope.watch('tree.left != null', (v, _) {
      if (v != true) return;
      s.append(new SpanElement()
        ..append(new FreeTreeClass(scope, 'tree.left').element()));
    });
    
    return elt;
  }
}

@Component(
  selector: 'ng-free-tree-class',
  template: ''
  )
class NgFreeTreeClass implements ShadowRootAware {
  var _data;

  @NgOneWay('data')
  set data(v) {
    _data = v;
    if (sroot != null)
    updateElement(sroot, _data);
  }

  ShadowRoot sroot;
  Scope scope;
  NgFreeTreeClass(Scope this.scope);

  void onShadowRoot(root) {
    sroot = root;
    if (_data != null) updateElement(sroot, _data);
  }


  var treeScope;
  updateElement(root, tree) {
    // Not quite acurate
    if (treeScope != null) {
      treeScope.destroy();
    }
    treeScope = scope.createChild({});
    treeScope.context['tree'] = tree;
    root.innerHtml = '';
    root.append(new FreeTreeClass(treeScope, 'tree').element());
  }
}


// Main function runs the benchmark.
main() {
  var cleanup, createDom;

  var module = new Module()
      ..type(TreeComponent)
      ..type(NgFreeTree)
      ..type(NgFreeTreeScoped)
      ..type(NgFreeTreeClass)
      ..factory(ScopeDigestTTL, (i) => new ScopeDigestTTL.value(15));

  var injector = applicationFactory().addModule(module).run();
  assert(injector != null);
  VmTurnZone zone = injector.get(VmTurnZone);
  Scope scope = injector.get(Scope);

  scope.context['initData'] = {
      "value": "top",
      "right": {
          "value": "right"
      },
      "left": {
          "value": "left"
      }
  };

  buildTree(maxDepth, values, curDepth) {
    if (maxDepth == curDepth) return {};
    return {
        "value": values[curDepth],
        "right": buildTree(maxDepth, values, curDepth+1),
        "left": buildTree(maxDepth, values, curDepth+1)

    };
  }
  cleanup = (_) => zone.run(() {
    scope.context['initData'] = {};
  });

  var count = 0;
  createDom = (_) => zone.run(() {
    var maxDepth = 9;
    var values = count++ % 2 == 0 ?
    ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '*'] :
    ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', '-'];
    scope.context['initData'] = buildTree(maxDepth, values, 0);
  });

  js.context['benchmarkSteps'].add(new js.JsObject.jsify({
      "name": "cleanup", "fn": new js.JsFunction.withThis(cleanup)
  }));
  js.context['benchmarkSteps'].add(new js.JsObject.jsify({
      "name": "createDom", "fn": new js.JsFunction.withThis(createDom)
  }));
}
