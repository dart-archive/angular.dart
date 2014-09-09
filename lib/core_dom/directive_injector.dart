library angular.node_injector;

import 'dart:collection';
import 'dart:html' show Node, Element, ShadowRoot;
import 'dart:profiler';

import 'package:di/di.dart';
import 'package:di/annotations.dart';
import 'package:di/src/module.dart' show DEFAULT_VALUE, Binding;
import 'package:angular/core/static_keys.dart';
import 'package:angular/core_dom/static_keys.dart';

import 'package:angular/core/module.dart' show Scope, RootScope;
import 'package:angular/core/annotation.dart' show Visibility, DirectiveBinder;
import 'package:angular/core_dom/module_internal.dart'
  show Animate, View, ViewFactory, BoundViewFactory, ViewPort, NodeAttrs, ElementProbe,
      NgElement, DestinationLightDom, SourceLightDom, LightDom, TemplateLoader, ShadowRootEventHandler,
      EventHandler, ShadowBoundary, DefaultShadowBoundary;

var _TAG_GET = new UserTag('DirectiveInjector.get()');
var _TAG_INSTANTIATE = new UserTag('DirectiveInjector.instantiate()');

final DIRECTIVE_INJECTOR_KEY = new Key(DirectiveInjector);
final COMPONENT_DIRECTIVE_INJECTOR_KEY = new Key(ComponentDirectiveInjector);
final DESTINATION_LIGHT_DOM_KEY = new Key(DestinationLightDom);
final SOURCE_LIGHT_DOM_KEY = new Key(SourceLightDom);
final TEMPLATE_LOADER_KEY = new Key(TemplateLoader);
final SHADOW_ROOT_KEY = new Key(ShadowRoot);

const int _NO_CONSTRUCTION = 0;

// Maximum parent directive injectors that would be traversed.
const int _MAX_TREE_DEPTH = 1 << 30;

// Maximum number of concurrent constructions a directive injector would
// support before throwing an error.
const int _MAX_CONSTRUCTION_DEPTH = 50;

const int VISIBILITY_LOCAL                    = -1;
const int VISIBILITY_DIRECT_CHILD             = -2;
const int VISIBILITY_CHILDREN                 = -3;

const int UNDEFINED_ID                  = 0;
const int INJECTOR_KEY_ID               = 1;
const int DIRECTIVE_INJECTOR_KEY_ID     = 2;
const int NODE_KEY_ID                   = 3;
const int ELEMENT_KEY_ID                = 4;
const int NODE_ATTRS_KEY_ID             = 5;
const int ANIMATE_KEY_ID                = 6;
const int SCOPE_KEY_ID                  = 7;
const int VIEW_KEY_ID                   = 8;
const int VIEW_PORT_KEY_ID              = 9;
const int VIEW_FACTORY_KEY_ID           = 10;
const int NG_ELEMENT_KEY_ID             = 11;
const int BOUND_VIEW_FACTORY_KEY_ID     = 12;
const int ELEMENT_PROBE_KEY_ID          = 13;
const int TEMPLATE_LOADER_KEY_ID        = 14;
const int SHADOW_ROOT_KEY_ID            = 15;
const int DESTINATION_LIGHT_DOM_KEY_ID  = 16;
const int SOURCE_LIGHT_DOM_KEY_ID       = 17;
const int EVENT_HANDLER_KEY_ID          = 18;
const int SHADOW_BOUNDARY_KEY_ID        = 19;
const int COMPONENT_DIRECTIVE_INJECTOR_KEY_ID = 20;
const int KEEP_ME_LAST                  = 21;

EventHandler eventHandler(DirectiveInjector di) => di._eventHandler;

class DirectiveInjector implements DirectiveBinder {
  static bool _isInit = false;

  static initUID() {
    if (_isInit) return;
    _isInit = true;
    INJECTOR_KEY.uid           = INJECTOR_KEY_ID;
    DIRECTIVE_INJECTOR_KEY.uid = DIRECTIVE_INJECTOR_KEY_ID;
    NODE_KEY.uid               = NODE_KEY_ID;
    ELEMENT_KEY.uid            = ELEMENT_KEY_ID;
    NODE_ATTRS_KEY.uid         = NODE_ATTRS_KEY_ID;
    SCOPE_KEY.uid              = SCOPE_KEY_ID;
    VIEW_KEY.uid               = VIEW_KEY_ID;
    VIEW_PORT_KEY.uid          = VIEW_PORT_KEY_ID;
    VIEW_FACTORY_KEY.uid       = VIEW_FACTORY_KEY_ID;
    NG_ELEMENT_KEY.uid         = NG_ELEMENT_KEY_ID;
    BOUND_VIEW_FACTORY_KEY.uid = BOUND_VIEW_FACTORY_KEY_ID;
    ELEMENT_PROBE_KEY.uid      = ELEMENT_PROBE_KEY_ID;
    TEMPLATE_LOADER_KEY.uid    = TEMPLATE_LOADER_KEY_ID;
    SHADOW_ROOT_KEY.uid        = SHADOW_ROOT_KEY_ID;
    DESTINATION_LIGHT_DOM_KEY.uid = DESTINATION_LIGHT_DOM_KEY_ID;
    SOURCE_LIGHT_DOM_KEY.uid   = SOURCE_LIGHT_DOM_KEY_ID;
    EVENT_HANDLER_KEY.uid    = EVENT_HANDLER_KEY_ID;
    SHADOW_BOUNDARY_KEY.uid    = SHADOW_BOUNDARY_KEY_ID;
    COMPONENT_DIRECTIVE_INJECTOR_KEY.uid = COMPONENT_DIRECTIVE_INJECTOR_KEY_ID;
    ANIMATE_KEY.uid            = ANIMATE_KEY_ID;
    for(var i = 1; i < KEEP_ME_LAST; i++) {
      if (_KEYS[i].uid != i) throw 'MISSORDERED KEYS ARRAY: ${_KEYS} at $i';
    }
  }

  static List<Key> _KEYS =
      [ UNDEFINED_ID
      , INJECTOR_KEY
      , DIRECTIVE_INJECTOR_KEY
      , NODE_KEY
      , ELEMENT_KEY
      , NODE_ATTRS_KEY
      , ANIMATE_KEY
      , SCOPE_KEY
      , VIEW_KEY
      , VIEW_PORT_KEY
      , VIEW_FACTORY_KEY
      , NG_ELEMENT_KEY
      , BOUND_VIEW_FACTORY_KEY
      , ELEMENT_PROBE_KEY
      , TEMPLATE_LOADER_KEY
      , SHADOW_ROOT_KEY
      , DESTINATION_LIGHT_DOM_KEY
      , SOURCE_LIGHT_DOM_KEY
      , EVENT_HANDLER_KEY
      , SHADOW_BOUNDARY_KEY
      , COMPONENT_DIRECTIVE_INJECTOR_KEY
      , KEEP_ME_LAST
      ];

  final DirectiveInjector _parent;
  final Injector _appInjector;
  final Node _node;
  final NodeAttrs _nodeAttrs;
  final Animate _animate;
  final EventHandler _eventHandler;
  final ShadowBoundary _shadowBoundary;
  LightDom lightDom;
  Scope scope;  //TODO(misko): this should be final after we get rid of controller
  final View _view;

  NgElement _ngElement;
  ElementProbe _elementProbe;

  // Keys, instances, parameter keys and factory functions
  Key _key0 = null; dynamic _obj0; List<Key> _pKeys0; Function _factory0;
  Key _key1 = null; dynamic _obj1; List<Key> _pKeys1; Function _factory1;
  Key _key2 = null; dynamic _obj2; List<Key> _pKeys2; Function _factory2;
  Key _key3 = null; dynamic _obj3; List<Key> _pKeys3; Function _factory3;
  Key _key4 = null; dynamic _obj4; List<Key> _pKeys4; Function _factory4;
  Key _key5 = null; dynamic _obj5; List<Key> _pKeys5; Function _factory5;
  Key _key6 = null; dynamic _obj6; List<Key> _pKeys6; Function _factory6;
  Key _key7 = null; dynamic _obj7; List<Key> _pKeys7; Function _factory7;
  Key _key8 = null; dynamic _obj8; List<Key> _pKeys8; Function _factory8;
  Key _key9 = null; dynamic _obj9; List<Key> _pKeys9; Function _factory9;

  // Keeps track of how many dependent constructions are being performed
  // in the directive injector.
  // It should be NO_CONSTRUCTION, until first call into _new sets it to 1
  // incremented on after each next call.
  int _constructionDepth;

  @Deprecated("Deprecated. Use getFromParent instead.")
  Object get parent => this._parent;

  static _toVisibilityId(Visibility v) => identical(v, Visibility.LOCAL)
      ? VISIBILITY_LOCAL
      : (identical(v, Visibility.CHILDREN) ? VISIBILITY_CHILDREN : VISIBILITY_DIRECT_CHILD);

  static Visibility _toVisibility(int id) {
    switch (id) {
      case VISIBILITY_LOCAL:                  return Visibility.LOCAL;
      case VISIBILITY_DIRECT_CHILD:           return Visibility.DIRECT_CHILD;
      case VISIBILITY_CHILDREN:               return Visibility.CHILDREN;
      default:                                return null;
    }
  }

  static Binding _tempBinding = new Binding();

  DirectiveInjector(DirectiveInjector parent, appInjector, this._node, this._nodeAttrs,
      this._eventHandler, this.scope, this._animate, [View view, this._shadowBoundary])
      : _parent = parent,
      _appInjector = appInjector,
      _view = view == null && parent != null ? parent._view : view,
      _constructionDepth = _NO_CONSTRUCTION;

  void bind(key, {dynamic toValue: DEFAULT_VALUE,
            Function toFactory: DEFAULT_VALUE,
            Type toImplementation,
            toInstanceOf,
            inject: const[],
            Visibility visibility: Visibility.LOCAL}) {
    assert(key != null);
    if (key is! Key) key = new Key(key);
    if (inject is! List) inject = [inject];

    _tempBinding.bind(key, Module.DEFAULT_REFLECTOR, toValue: toValue, toFactory: toFactory,
        toImplementation: toImplementation, inject: inject, toInstanceOf: toInstanceOf);

    bindByKey(key, _tempBinding.factory, _tempBinding.parameterKeys, visibility);
  }

  void bindByKey(Key key, Function factory, List<Key> parameterKeys, [Visibility visibility]) {
    assert(_isInit);
    if (visibility == null) visibility = Visibility.CHILDREN;
    int visibilityId = _toVisibilityId(visibility);
    int keyVisId = key.uid;
    if (keyVisId != visibilityId) {
      if (keyVisId == null) {
        key.uid = visibilityId;
      } else {
        throw "Can not set $visibility on $key, it already has ${_toVisibility(keyVisId)}";
      }
    }
    if      (_key0 == null || identical(_key0, key)) { _key0 = key; _pKeys0 = parameterKeys; _factory0 = factory; }
    else if (_key1 == null || identical(_key1, key)) { _key1 = key; _pKeys1 = parameterKeys; _factory1 = factory; }
    else if (_key2 == null || identical(_key2, key)) { _key2 = key; _pKeys2 = parameterKeys; _factory2 = factory; }
    else if (_key3 == null || identical(_key3, key)) { _key3 = key; _pKeys3 = parameterKeys; _factory3 = factory; }
    else if (_key4 == null || identical(_key4, key)) { _key4 = key; _pKeys4 = parameterKeys; _factory4 = factory; }
    else if (_key5 == null || identical(_key5, key)) { _key5 = key; _pKeys5 = parameterKeys; _factory5 = factory; }
    else if (_key6 == null || identical(_key6, key)) { _key6 = key; _pKeys6 = parameterKeys; _factory6 = factory; }
    else if (_key7 == null || identical(_key7, key)) { _key7 = key; _pKeys7 = parameterKeys; _factory7 = factory; }
    else if (_key8 == null || identical(_key8, key)) { _key8 = key; _pKeys8 = parameterKeys; _factory8 = factory; }
    else if (_key9 == null || identical(_key9, key)) { _key9 = key; _pKeys9 = parameterKeys; _factory9 = factory; }
    else { throw 'Maximum number of directives per element reached.'; }
  }

  // Get a key from the directive injector chain. When it is exhausted, get from
  // the current application injector chain.
  Object get(Type type) => getByKey(new Key(type));
  Object getFromParent(Type type) => getFromParentByKey(new Key(type));

  Object getByKey(Key key) {
    var oldTag = _TAG_GET.makeCurrent();
    try {
      return _getByKey(key, _appInjector);
    } finally {
      oldTag.makeCurrent();
    }
  }

  Object getFromParentByKey(Key key) {
    if (_parent == null) {
      return _appInjector.getByKey(key);
    } else {
      return _parent._getByKey(key, _appInjector);
    }
  }

  Object _getByKey(Key key, Injector appInjector) {
    try {
      int uid = key.uid;
      if (uid == null || uid == UNDEFINED_ID) return appInjector.getByKey(key);
      bool isDirective = uid < 0;
      return isDirective ? _getDirectiveByKey(key, uid, appInjector) : _getById(uid);
    } on ResolvingError catch (e) {
      e.appendKey(key);
      rethrow;
    }
  }

  num _getDepth(int visibility) {
    switch(visibility) {
      case VISIBILITY_LOCAL:        return 0;
      case VISIBILITY_DIRECT_CHILD: return 1;
      case VISIBILITY_CHILDREN:     return _MAX_TREE_DEPTH;
      default: throw 'Invalid visibility "$visibility"';
    }
  }

  _getDirectiveByKey(Key k, int visibility, Injector appInjector) {
    num treeDepth = _getDepth(visibility);
    // ci stands for currentInjector, abbreviated for readability.
    var ci = this;
    while (ci != null && treeDepth >= 0) {
      do {
        if (ci._key0 == null) break; if (identical(ci._key0, k)) return ci._obj0 == null ?  ci._obj0 = ci._new(k, ci._pKeys0, ci._factory0) : ci._obj0;
        if (ci._key1 == null) break; if (identical(ci._key1, k)) return ci._obj1 == null ?  ci._obj1 = ci._new(k, ci._pKeys1, ci._factory1) : ci._obj1;
        if (ci._key2 == null) break; if (identical(ci._key2, k)) return ci._obj2 == null ?  ci._obj2 = ci._new(k, ci._pKeys2, ci._factory2) : ci._obj2;
        if (ci._key3 == null) break; if (identical(ci._key3, k)) return ci._obj3 == null ?  ci._obj3 = ci._new(k, ci._pKeys3, ci._factory3) : ci._obj3;
        if (ci._key4 == null) break; if (identical(ci._key4, k)) return ci._obj4 == null ?  ci._obj4 = ci._new(k, ci._pKeys4, ci._factory4) : ci._obj4;
        if (ci._key5 == null) break; if (identical(ci._key5, k)) return ci._obj5 == null ?  ci._obj5 = ci._new(k, ci._pKeys5, ci._factory5) : ci._obj5;
        if (ci._key6 == null) break; if (identical(ci._key6, k)) return ci._obj6 == null ?  ci._obj6 = ci._new(k, ci._pKeys6, ci._factory6) : ci._obj6;
        if (ci._key7 == null) break; if (identical(ci._key7, k)) return ci._obj7 == null ?  ci._obj7 = ci._new(k, ci._pKeys7, ci._factory7) : ci._obj7;
        if (ci._key8 == null) break; if (identical(ci._key8, k)) return ci._obj8 == null ?  ci._obj8 = ci._new(k, ci._pKeys8, ci._factory8) : ci._obj8;
        if (ci._key9 == null) break; if (identical(ci._key9, k)) return ci._obj9 == null ?  ci._obj9 = ci._new(k, ci._pKeys9, ci._factory9) : ci._obj9;
      } while (false);
      // Future feature: Component Injectors fall-through only if directly called.
      // if ((ci is ComponentDirectiveInjector) && !identical(ci, this)) break;
      ci = ci._parent;
      treeDepth--;
    }
    return appInjector.getByKey(k);
  }

  List get directives {
    var directives = [];
    if (_obj0 != null) directives.add(_obj0);
    if (_obj1 != null) directives.add(_obj1);
    if (_obj2 != null) directives.add(_obj2);
    if (_obj3 != null) directives.add(_obj3);
    if (_obj4 != null) directives.add(_obj4);
    if (_obj5 != null) directives.add(_obj5);
    if (_obj6 != null) directives.add(_obj6);
    if (_obj7 != null) directives.add(_obj7);
    if (_obj8 != null) directives.add(_obj8);
    if (_obj9 != null) directives.add(_obj9);
    return directives;
  }

  Object _getById(int keyId) {
    switch(keyId) {
      case INJECTOR_KEY_ID:               return _appInjector;
      case DIRECTIVE_INJECTOR_KEY_ID:     return this;
      case NODE_KEY_ID:                   return _node;
      case ELEMENT_KEY_ID:                return _node;
      case NODE_ATTRS_KEY_ID:             return _nodeAttrs;
      case ANIMATE_KEY_ID:                return _animate;
      case SCOPE_KEY_ID:                  return scope;
      case ELEMENT_PROBE_KEY_ID:          return elementProbe;
      case NG_ELEMENT_KEY_ID:             return ngElement;
      case EVENT_HANDLER_KEY_ID:          return _eventHandler;
      case SHADOW_BOUNDARY_KEY_ID:        return _findShadowBoundary();
      case DESTINATION_LIGHT_DOM_KEY_ID:  return _destLightDom;
      case SOURCE_LIGHT_DOM_KEY_ID:       return _sourceLightDom;
      case VIEW_KEY_ID:                   return _view;
      default: throw new NoProviderError(_KEYS[keyId]);
    }
  }

  dynamic _new(Key k, List<Key> paramKeys, Function fn) {
    if (_constructionDepth > _MAX_CONSTRUCTION_DEPTH) {
      _constructionDepth = _NO_CONSTRUCTION;
      throw new _CircularDependencyError(k);
    }
    bool isFirstConstruction = (_constructionDepth++ == _NO_CONSTRUCTION);
    var oldTag = _TAG_GET.makeCurrent();
    int size = paramKeys.length;
    var obj;
    var appInjector = this._appInjector;
    if (size > 15) {
      var params = new List(paramKeys.length);
      for(var i = 0; i < paramKeys.length; i++) {
        params[i] = _getByKey(paramKeys[i], appInjector);
      }
      _TAG_INSTANTIATE.makeCurrent();
      obj = Function.apply(fn, params);
    } else {
      var a01 = size >= 01 ? _getByKey(paramKeys[00], appInjector) : null;
      var a02 = size >= 02 ? _getByKey(paramKeys[01], appInjector) : null;
      var a03 = size >= 03 ? _getByKey(paramKeys[02], appInjector) : null;
      var a04 = size >= 04 ? _getByKey(paramKeys[03], appInjector) : null;
      var a05 = size >= 05 ? _getByKey(paramKeys[04], appInjector) : null;
      var a06 = size >= 06 ? _getByKey(paramKeys[05], appInjector) : null;
      var a07 = size >= 07 ? _getByKey(paramKeys[06], appInjector) : null;
      var a08 = size >= 08 ? _getByKey(paramKeys[07], appInjector) : null;
      var a09 = size >= 09 ? _getByKey(paramKeys[08], appInjector) : null;
      var a10 = size >= 10 ? _getByKey(paramKeys[09], appInjector) : null;
      var a11 = size >= 11 ? _getByKey(paramKeys[10], appInjector) : null;
      var a12 = size >= 12 ? _getByKey(paramKeys[11], appInjector) : null;
      var a13 = size >= 13 ? _getByKey(paramKeys[12], appInjector) : null;
      var a14 = size >= 14 ? _getByKey(paramKeys[13], appInjector) : null;
      var a15 = size >= 15 ? _getByKey(paramKeys[14], appInjector) : null;
      _TAG_INSTANTIATE.makeCurrent();
      switch(size) {
        case 00: obj = fn(); break;
        case 01: obj = fn(a01); break;
        case 02: obj = fn(a01, a02); break;
        case 03: obj = fn(a01, a02, a03); break;
        case 04: obj = fn(a01, a02, a03, a04); break;
        case 05: obj = fn(a01, a02, a03, a04, a05); break;
        case 06: obj = fn(a01, a02, a03, a04, a05, a06); break;
        case 07: obj = fn(a01, a02, a03, a04, a05, a06, a07); break;
        case 08: obj = fn(a01, a02, a03, a04, a05, a06, a07, a08); break;
        case 09: obj = fn(a01, a02, a03, a04, a05, a06, a07, a08, a09); break;
        case 10: obj = fn(a01, a02, a03, a04, a05, a06, a07, a08, a09, a10); break;
        case 11: obj = fn(a01, a02, a03, a04, a05, a06, a07, a08, a09, a10, a11); break;
        case 12: obj = fn(a01, a02, a03, a04, a05, a06, a07, a08, a09, a10, a11, a12); break;
        case 13: obj = fn(a01, a02, a03, a04, a05, a06, a07, a08, a09, a10, a11, a12, a13); break;
        case 14: obj = fn(a01, a02, a03, a04, a05, a06, a07, a08, a09, a10, a11, a12, a13, a14); break;
        case 15: obj = fn(a01, a02, a03, a04, a05, a06, a07, a08, a09, a10, a11, a12, a13, a14, a15);
      }
    }
    oldTag.makeCurrent();
    if (isFirstConstruction) _constructionDepth = _NO_CONSTRUCTION;
    return obj;
  }

  ElementProbe get elementProbe {
    if (_elementProbe == null) {
      ElementProbe parentProbe = _parent == null ? null : _parent.elementProbe;
      _elementProbe = new ElementProbe(parentProbe, _node, this, scope);
    }
    return _elementProbe;
  }

  NgElement get ngElement {
    if (_ngElement == null) {
      _ngElement = new NgElement(_node, _appInjector.getByKey(ROOT_SCOPE_KEY), _animate, _destLightDom);
    }
    return _ngElement;
  }

  SourceLightDom get _sourceLightDom {
    var curr = _parent;
    while (curr != null && curr is! ComponentDirectiveInjector) {
      curr = curr.parent;
    }
    return curr == null || curr.parent == null ? null : curr.parent.lightDom;
  }

  DestinationLightDom get _destLightDom => _parent == null ? null : _parent.lightDom;

  ShadowBoundary _findShadowBoundary() =>
      _shadowBoundary != null ? _shadowBoundary : getFromParentByKey(SHADOW_BOUNDARY_KEY);
}

class TemplateDirectiveInjector extends DirectiveInjector {
  final ViewFactory _viewFactory;
  ViewPort _viewPort;
  BoundViewFactory _boundViewFactory;

  TemplateDirectiveInjector(DirectiveInjector parent, Injector appInjector,
                       Node node, NodeAttrs nodeAttrs, EventHandler eventHandler,
                       Scope scope, Animate animate, this._viewFactory,
                       [View view, ShadowBoundary shadowBoundary])
    : super(parent, appInjector, node, nodeAttrs, eventHandler, scope, animate,
        view, shadowBoundary);


  Object _getById(int keyId) {
    switch(keyId) {
      case VIEW_FACTORY_KEY_ID: return _viewFactory;
      case VIEW_PORT_KEY_ID: return ((_viewPort) == null) ?
            _viewPort = _createViewPort() : _viewPort;
      case BOUND_VIEW_FACTORY_KEY_ID: return (_boundViewFactory == null) ?
            _boundViewFactory = _viewFactory.bind(_parent) : _boundViewFactory;
      default: return super._getById(keyId);
    }
  }

  ViewPort _createViewPort() {
    final viewPort = new ViewPort(this, scope, _node, _animate, _destLightDom);
    if (_destLightDom != null) _destLightDom.addViewPort(viewPort);
    return viewPort;
  }

}

class ComponentDirectiveInjector extends DirectiveInjector {

  final TemplateLoader _templateLoader;
  final ShadowRoot _shadowRoot;
  // The key for the directive that triggered the creation of this injector.
  final Key _typeKey;

  ComponentDirectiveInjector(DirectiveInjector parent, Injector appInjector,
                        EventHandler eventHandler, Scope scope,
                        this._templateLoader, this._shadowRoot, LightDom lightDom, this._typeKey,
                        [View view, ShadowBoundary shadowBoundary])
      : super(parent, appInjector, parent._node, parent._nodeAttrs, eventHandler, scope,
              parent._animate, view, shadowBoundary) {
    // A single component creates a ComponentDirectiveInjector and its DirectiveInjector parent,
    // so parent should never be null.
    assert(parent != null);
    _parent.lightDom = lightDom;
  }

  Object _getById(int keyId) {
    switch(keyId) {
      case TEMPLATE_LOADER_KEY_ID: return _templateLoader;
      case SHADOW_ROOT_KEY_ID: return _shadowRoot;
      case DIRECTIVE_INJECTOR_KEY_ID: return _parent;
      case COMPONENT_DIRECTIVE_INJECTOR_KEY_ID: return this;
      // Currently, this is guaranteed to be called after controller creation.
      case SCOPE_KEY_ID:
        if (scope == null) {
          Scope parentScope = _parent.scope;
          scope = parentScope.createChild(getByKey(_typeKey));
        }
        return scope;
      default: return super._getById(keyId);
    }
  }

  ElementProbe get elementProbe {
    if (_elementProbe == null) {
      ElementProbe parentProbe = _parent == null ? null : _parent.elementProbe;
      _elementProbe = new ElementProbe(parentProbe, _shadowRoot, this, scope);
    }
    return _elementProbe;
  }

  // Add 1 to visibility to allow to skip over current component injector.
  // For example, a local directive is visible from its component injector children.
  num _getDepth(int visibility) => super._getDepth(visibility) + 1;
}


// For efficiency we run through the maximum resolving depth and unwind
// instead of setting 'resolving' key per type.
class _CircularDependencyError extends CircularDependencyError {
  _CircularDependencyError(key) : super(key);

  // strips the cyclical part of the chain.
  List<Key> get stripCycle {
    List<Key> rkeys = keys.reversed.toList();
    for (num i = 0; i < rkeys.length; i++) {
      // Skipping 'cycles' of length 1, which represent resolution
      // switching injectors and not true cycles.
      for (num j = i + 2; j < rkeys.length; j++) {
        if (rkeys[i] == rkeys[j]) return rkeys.sublist(0, j + 1);
      }
    }
    return rkeys;
  }

  String get resolveChain {
    StringBuffer buffer = new StringBuffer()
        ..write("(resolving ")
        ..write(stripCycle.join(' -> '))
        ..write(")");
    return buffer.toString();
  }

}
