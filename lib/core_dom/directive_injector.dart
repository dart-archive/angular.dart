library angular.node_injector;

import 'dart:collection';
import 'dart:html' show Node, Element, ShadowRoot;
import 'dart:profiler';

import 'package:di/di.dart';
import 'package:angular/core/static_keys.dart';
import 'package:angular/core_dom/static_keys.dart';
import 'package:angular/mock/module.dart';

import 'package:angular/core/module.dart' show Scope, RootScope;
import 'package:angular/core/annotation.dart' show Visibility, DirectiveModule;
import 'package:angular/core_dom/module_internal.dart'
  show Animate, View, ViewFactory, BoundViewFactory, ViewPort, NodeAttrs, ElementProbe,
      NgElement, ContentPort, TemplateLoader, ShadowRootEventHandler, EventHandler;

var tag_get = new UserTag('DirectiveInjector.get()');
var tag_instantiate = new UserTag('DirectiveInjector.instantiate()');

final DIRECTIVE_INJECTOR_KEY = new Key(DirectiveInjector);
final CONTENT_PORT_KEY = new Key(ContentPort);
final TEMPLATE_LOADER_KEY = new Key(TemplateLoader);
final SHADOW_ROOT_KEY = new Key(ShadowRoot);

const int VISIBILITY_LOCAL                    = -1;
const int VISIBILITY_DIRECT_CHILD             = -2;
const int VISIBILITY_CHILDREN                 = -3;
const int VISIBILITY_COMPONENT_OFFSET         = VISIBILITY_CHILDREN;
const int VISIBILITY_COMPONENT_LOCAL          = VISIBILITY_LOCAL        + VISIBILITY_COMPONENT_OFFSET;
const int VISIBILITY_COMPONENT_DIRECT_CHILD   = VISIBILITY_DIRECT_CHILD + VISIBILITY_COMPONENT_OFFSET;
const int VISIBILITY_COMPONENT_CHILDREN       = VISIBILITY_CHILDREN     + VISIBILITY_COMPONENT_OFFSET;

const int UNDEFINED_ID              = 0;
const int INJECTOR_KEY_ID           = 1;
const int DIRECTIVE_INJECTOR_KEY_ID = 2;
const int NODE_KEY_ID               = 3;
const int ELEMENT_KEY_ID            = 4;
const int NODE_ATTRS_KEY_ID         = 5;
const int ANIMATE_KEY_ID            = 6;
const int SCOPE_KEY_ID              = 7;
const int VIEW_KEY_ID               = 8;
const int VIEW_PORT_KEY_ID          = 9;
const int VIEW_FACTORY_KEY_ID       = 10;
const int NG_ELEMENT_KEY_ID         = 11;
const int BOUND_VIEW_FACTORY_KEY_ID = 12;
const int ELEMENT_PROBE_KEY_ID      = 13;
const int TEMPLATE_LOADER_KEY_ID    = 14;
const int SHADOW_ROOT_KEY_ID        = 15;
const int CONTENT_PORT_KEY_ID       = 16;
const int EVENT_HANDLER_KEY_ID      = 17;
const int KEEP_ME_LAST              = 18;

class DirectiveInjector implements DirectiveModule {
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
    CONTENT_PORT_KEY.uid       = CONTENT_PORT_KEY_ID;
    EVENT_HANDLER_KEY.uid      = EVENT_HANDLER_KEY_ID;
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
      , CONTENT_PORT_KEY
      , EVENT_HANDLER_KEY
      , KEEP_ME_LAST
      ];
  
  final DirectiveInjector parent;
  final Injector appInjector;
  final Node _node;
  final NodeAttrs _nodeAttrs;
  final Animate _animate;
  final EventHandler _eventHandler;
  Scope scope;  //TODO(misko): this should be final after we get rid of controller

  NgElement _ngElement;
  ElementProbe _elementProbe;

  Key _key0 = null; dynamic _obj0; List<Key> _pKeys0; Factory _factory0;
  Key _key1 = null; dynamic _obj1; List<Key> _pKeys1; Factory _factory1;
  Key _key2 = null; dynamic _obj2; List<Key> _pKeys2; Factory _factory2;
  Key _key3 = null; dynamic _obj3; List<Key> _pKeys3; Factory _factory3;
  Key _key4 = null; dynamic _obj4; List<Key> _pKeys4; Factory _factory4;
  Key _key5 = null; dynamic _obj5; List<Key> _pKeys5; Factory _factory5;
  Key _key6 = null; dynamic _obj6; List<Key> _pKeys6; Factory _factory6;
  Key _key7 = null; dynamic _obj7; List<Key> _pKeys7; Factory _factory7;
  Key _key8 = null; dynamic _obj8; List<Key> _pKeys8; Factory _factory8;
  Key _key9 = null; dynamic _obj9; List<Key> _pKeys9; Factory _factory9;

  static _toVisId(Visibility v) => identical(v, Visibility.LOCAL)
      ? VISIBILITY_LOCAL
      : (identical(v, Visibility.CHILDREN) ? VISIBILITY_CHILDREN : VISIBILITY_DIRECT_CHILD);

  static _toVis(int id) {
    switch (id) {
      case VISIBILITY_LOCAL:                  return Visibility.LOCAL;
      case VISIBILITY_DIRECT_CHILD:           return Visibility.DIRECT_CHILD;
      case VISIBILITY_CHILDREN:               return Visibility.CHILDREN;
      case VISIBILITY_COMPONENT_LOCAL:        return Visibility.LOCAL;
      case VISIBILITY_COMPONENT_DIRECT_CHILD: return Visibility.DIRECT_CHILD;
      case VISIBILITY_COMPONENT_CHILDREN:     return Visibility.CHILDREN;
      default:                                return null;
    }
  }

  DirectiveInjector(parent, appInjector, this._node, this._nodeAttrs, this._eventHandler,
                    this.scope, this._animate)
      : appInjector = appInjector,
        parent = parent == null ? new DefaultDirectiveInjector(appInjector) : parent;

  DirectiveInjector._default(this.appInjector)
      : parent = null,
        _node = null,
        _nodeAttrs = null,
        _eventHandler = null,
        scope = null,
        _animate = null;

  bind(key, {Function toFactory, inject, Visibility visibility: Visibility.LOCAL}) {
    if (key == null) throw 'Key is required';
    if (key is! Key) key = new Key(key);

    if (inject == null) {
      if (toFactory != null) throw "Can not have toFactory without inject";
      inject = Module.DEFAULT_REFLECTOR.parameterKeysFor(key.type);
      toFactory = Module.DEFAULT_REFLECTOR.factoryFor(key.type);
    } else {
      if (inject is! List) inject = [inject];
      for(var i=0; i < inject.length; i++) {
        if (inject[i] is! Key) inject[i] = new Key(inject[i]);
      }
    }

    if (toFactory == null) toFactory = _IDENTITY;
    bindByKey(key, toFactory, inject, visibility);
  }
  static Function _IDENTITY = (p) => p[0];

  bindByKey(Key key, Factory factory, List<Key> parameterKeys, [Visibility visibility]) {
    if (visibility == null) visibility = Visibility.LOCAL;
    int visibilityId = _toVisId(visibility);
    int keyVisId = key.uid;
    if (keyVisId != visibilityId) {
      if (keyVisId == null) {
        key.uid = visibilityId;
      } else {
        throw "Can not set $visibility on $key, it alread has ${_toVis(keyVisId)}";
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

  Object get(Type type) => getByKey(new Key(type));

  Object getByKey(Key key, [int depth = 0]) {
    var oldTag = tag_get.makeCurrent();
    try {
      return _getByKey(key, depth);
    } on ResolvingError catch (e, s) {
      e.appendKey(key);
      rethrow;
    } finally {
      oldTag.makeCurrent();
    }
  }

  Object _getByKey(Key key, int depth) {
    int uid = key.uid;
    if (uid == null || uid == UNDEFINED_ID) return appInjector.getByKey(key, depth + 1);
    bool isDirective = uid < 0;
    return isDirective ? _getDirectiveByKey(key, uid, depth + 1) : _getById(uid);
  }

  _getDirectiveByKey(Key k, int visType, int d) {
    do {
      if (_key0 == null) break; if (identical(_key0, k)) return _obj0 == null ?  _obj0 = _new(_pKeys0, _factory0, d) : _obj0;
      if (_key1 == null) break; if (identical(_key1, k)) return _obj1 == null ?  _obj1 = _new(_pKeys1, _factory1, d) : _obj1;
      if (_key2 == null) break; if (identical(_key2, k)) return _obj2 == null ?  _obj2 = _new(_pKeys2, _factory2, d) : _obj2;
      if (_key3 == null) break; if (identical(_key3, k)) return _obj3 == null ?  _obj3 = _new(_pKeys3, _factory3, d) : _obj3;
      if (_key4 == null) break; if (identical(_key4, k)) return _obj4 == null ?  _obj4 = _new(_pKeys4, _factory4, d) : _obj4;
      if (_key5 == null) break; if (identical(_key5, k)) return _obj5 == null ?  _obj5 = _new(_pKeys5, _factory5, d) : _obj5;
      if (_key6 == null) break; if (identical(_key6, k)) return _obj6 == null ?  _obj6 = _new(_pKeys6, _factory6, d) : _obj6;
      if (_key7 == null) break; if (identical(_key7, k)) return _obj7 == null ?  _obj7 = _new(_pKeys7, _factory7, d) : _obj7;
      if (_key8 == null) break; if (identical(_key8, k)) return _obj8 == null ?  _obj8 = _new(_pKeys8, _factory8, d) : _obj8;
      if (_key9 == null) break; if (identical(_key9, k)) return _obj9 == null ?  _obj9 = _new(_pKeys9, _factory9, d) : _obj9;
    } while (false);
    switch (visType) {
      case VISIBILITY_LOCAL:                  return appInjector.getByKey(k, d);
      case VISIBILITY_DIRECT_CHILD:           return parent._getDirectiveByKey(k, VISIBILITY_LOCAL, d);
      case VISIBILITY_CHILDREN:               return parent._getDirectiveByKey(k, VISIBILITY_CHILDREN, d);
      // SHADOW
      case VISIBILITY_COMPONENT_LOCAL:        return parent._getDirectiveByKey(k, VISIBILITY_LOCAL, d);
      case VISIBILITY_COMPONENT_DIRECT_CHILD: return parent._getDirectiveByKey(k, VISIBILITY_DIRECT_CHILD, d);
      case VISIBILITY_COMPONENT_CHILDREN:     return parent._getDirectiveByKey(k, VISIBILITY_CHILDREN, d);
      default: throw null;
    }
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
      case INJECTOR_KEY_ID:           return appInjector;
      case DIRECTIVE_INJECTOR_KEY_ID: return this;
      case NODE_KEY_ID:               return _node;
      case ELEMENT_KEY_ID:            return _node;
      case NODE_ATTRS_KEY_ID:         return _nodeAttrs;
      case ANIMATE_KEY_ID:            return _animate;
      case SCOPE_KEY_ID:              return scope;
      case ELEMENT_PROBE_KEY_ID:      return elementProbe;
      case NG_ELEMENT_KEY_ID:         return ngElement;
      case EVENT_HANDLER_KEY_ID:      return _eventHandler;
      case CONTENT_PORT_KEY_ID:       return parent._getById(keyId);
      default: new NoProviderError(_KEYS[keyId]);
    }
  }

  dynamic _new(List<Key> paramKeys, Function constructor, int depth) {
    var oldTag = tag_get.makeCurrent();
    var params = new List(paramKeys.length);
    for(var i = 0; i < paramKeys.length; i++) {
      params[i] = _getByKey(paramKeys[i], depth + 1);
    }
    tag_instantiate.makeCurrent();
    var obj = constructor(params);
    oldTag.makeCurrent();
    return obj;
  }


  get elementProbe {
    if (_elementProbe == null) {
      ElementProbe parentProbe = parent is DirectiveInjector ? parent.elementProbe : null;
      _elementProbe = new ElementProbe(parentProbe, _node, this, appInjector, scope);
    }
    return _elementProbe;
  }

  get ngElement {
    if (_ngElement == null) {
      _ngElement = new NgElement(_node, scope, _animate);
    }
    return _ngElement;
  }
}

class TemplateDirectiveInjector extends DirectiveInjector {
  final ViewFactory _viewFactory;
  ViewPort _viewPort;
  BoundViewFactory _boundViewFactory;
  
  TemplateDirectiveInjector(DirectiveInjector parent, Injector appInjector,
                       Node node, NodeAttrs nodeAttrs, EventHandler eventHandler,
                       Scope scope, Animate animate, ViewFactory viewFactory)
    : super(parent, appInjector, node, nodeAttrs, eventHandler, scope, animate),
      _viewFactory = viewFactory;


  Object _getById(int keyId) {
    switch(keyId) {
      case VIEW_FACTORY_KEY_ID: return _viewFactory;
      case VIEW_PORT_KEY_ID: return ((_viewPort) == null) ? _viewPort = new ViewPort(this, appInjector, scope, _node, _animate) : _viewPort;
      case BOUND_VIEW_FACTORY_KEY_ID: return (_boundViewFactory == null) ? _boundViewFactory = _viewFactory.bind(this.parent, appInjector) : _boundViewFactory;
      default: return super._getById(keyId);
    }
  }
  
}

abstract class ComponentDirectiveInjector extends DirectiveInjector {

  final TemplateLoader _templateLoader;
  final ShadowRoot _shadowRoot;

  ComponentDirectiveInjector(DirectiveInjector parent, Injector appInjector,
                        EventHandler eventHandler, Scope scope,
                        this._templateLoader, this._shadowRoot)
      : super(parent, appInjector, parent._node, parent._nodeAttrs, eventHandler, scope, parent._animate);

  Object _getById(int keyId) {
    switch(keyId) {
      case TEMPLATE_LOADER_KEY_ID: return _templateLoader;
      case SHADOW_ROOT_KEY_ID: return _shadowRoot;
      default: return super._getById(keyId);
    }
  }

  _getDirectiveByKey(Key k, int visType, int d)
      => super._getDirectiveByKey(k, visType + VISIBILITY_COMPONENT_OFFSET, d);
}

class ShadowlessComponentDirectiveInjector extends ComponentDirectiveInjector {
  final ContentPort _contentPort;

  ShadowlessComponentDirectiveInjector(DirectiveInjector parent, Injector appInjector,
                                  EventHandler eventHandler, Scope scope,
                                  templateLoader, shadowRoot, this._contentPort)
      : super(parent, appInjector, eventHandler, scope, templateLoader, shadowRoot);

  Object _getById(int keyId) {
    switch(keyId) {
      case CONTENT_PORT_KEY_ID: return _contentPort;
      default: return super._getById(keyId);
    }
  }
}

class ShadowDomComponentDirectiveInjector extends ComponentDirectiveInjector {
  ShadowDomComponentDirectiveInjector(DirectiveInjector parent, Injector appInjector,
                                 Scope scope, templateLoader, shadowRoot)
      : super(parent, appInjector, new ShadowRootEventHandler(shadowRoot,
                                               parent.getByKey(EXPANDO_KEY),
                                               parent.getByKey(EXCEPTION_HANDLER_KEY)),
            scope, templateLoader, shadowRoot);

  ElementProbe get elementProbe {
    if (_elementProbe == null) {
      ElementProbe parentProbe =
        parent is DirectiveInjector ? parent.elementProbe : parent.getByKey(ELEMENT_PROBE_KEY);
      _elementProbe = new ElementProbe(parentProbe, _shadowRoot, this, appInjector, scope);
    }
    return _elementProbe;
  }
}

class DefaultDirectiveInjector extends DirectiveInjector {
  DefaultDirectiveInjector(Injector appInjector): super._default(appInjector);

  Object getByKey(Key key, [int depth = 0]) => appInjector.getByKey(key, depth);
  _getDirectiveByKey(Key key, int visType, int depth) => appInjector.getByKey(key, depth);
  _getById(int keyId) {
    switch (keyId) {
      case CONTENT_PORT_KEY_ID: return null;
      default: throw new NoProviderError(DirectiveInjector._KEYS[keyId]);
    }
  }
}
