library angular.query;

import 'dart:collection';
import 'package:angular/core_dom/directive_injector.dart';

class Query<T> extends Object with IterableMixin<T> {
  static const int DEPTH_CHILDREN = 1;
  static const int DEPTH_DESCENDANTS = 2;
  static final Function _noop = (){};

  Function onChange = _noop;

  final DirectiveInjector _inj;
  final int _depth;
  final Type _componentType;
  final List<T> _cache = [];
  var _dirty = false;
  Query(this._inj, this._depth, this._componentType);

  Iterator<T> get iterator {
    if (_dirty) {
      _updateCache();
      _dirty = false;
    }
    return _cache.iterator;
  }

  void _updateCache() {
    _cache.clear();
    if (_depth == DEPTH_DESCENDANTS) {
      _inj.children.forEach(_traverseDescendants);
    } else {
      _inj.children.forEach(_traverseChildren);
    }
  }

  void _traverseDescendants(DirectiveInjector injector) {
    _processDirectiveInjector(injector);
    if (injector is! ComponentDirectiveInjector) {
      injector.children.forEach(_traverseDescendants);
    }
  }

  void _traverseChildren(DirectiveInjector injector) {
    _processDirectiveInjector(injector);
    if (injector is! ComponentDirectiveInjector) {
      injector.children.forEach(_processDirectiveInjector);
    }
  }

  bool _processDirectiveInjector(DirectiveInjector injector) {
    if (injector is ComponentDirectiveInjector && matches(injector.component)) {
      _cache.add(injector.component);
    }
  }

  void invalidate(){
    if (! _dirty) {
      _dirty = true;
      _inj.scope.rootScope.runAsync(onChange);
    }
  }

  bool matches(Object component) =>
      component.runtimeType == _componentType ||
      component.runtimeType.toString() == "QueriedComponent"; // TODO: delete before merging into master
}

class QueryRef {
  final Query query;
  final bool inherited;

  QueryRef(this.query, this.inherited);

  QueryRef buildChildRef() {
    if (query._depth == Query.DEPTH_CHILDREN && inherited) return null;
    return new QueryRef(query, true);
  }
}
