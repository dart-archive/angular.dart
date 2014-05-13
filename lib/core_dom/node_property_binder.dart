library angular.core_dom.node_property_binder;

import 'package:angular/change_detection/watch_group.dart' show
    Watch;

import 'package:angular/core/parser/parser.dart' show
    Parser, Setter, Getter;

import 'package:angular/core/parser/syntax.dart' show
    Expression;

import 'package:angular/core/module_internal.dart' show
    Scope, RootScope, ScopeEvent, FormatterMap, ExceptionHandler, ReactionFn;

import 'package:angular/core_dom/module_internal.dart' show
    EventHandler, ViewFactory, AutoSelectComponentFactory, NG_BINDING, NgElement;

import 'package:angular/core/annotation.dart' show
    Directive, Component, AttachAware, DetachAware;

import 'package:angular/change_detection/change_detection.dart' show
    CollectionChangeRecord, MapChangeRecord;

import 'package:di/di.dart';
import 'dart:html' show Node, Element;

bool same(a, b) =>
    (a is! CollectionChangeRecord && a is! MapChangeRecord && identical(a, b)) ||
    (a is String && b is String && a == b) ||
    (a is num && a.isNaN && b is num && b.isNaN);

Map<Type, Map<String, bool>> _understandsMap = {};
bool _understandsGetter(Object obj, String property, Getter getter) {
  var type = obj.runtimeType;
  var propertyMap = _understandsMap[type];
  if (propertyMap == null) _understandsMap[type] = propertyMap = {};
  var understands = propertyMap[property];
  if (understands == null) {
    try {
      getter(obj);
      understands = true;
    } catch (e) {
      understands = !(e is NoSuchMethodError);
    }
    propertyMap[property] = understands;
  }
  return understands;
}

class Case {
  static final _DASH = new RegExp(r'-+(.)');
  static final _CAMEL = new RegExp(r'([A-Z]+)');
  final _toDash = {};
  final _toCamel = {};

  Case() {
    preset('readonly', 'readOnly');
    preset('class', 'className');
  }

  void preset(String dash, String camel) {
    _toCamel[dash] = camel;
    _toDash[camel] = dash;
  }

  /// Convert `node-property` attribute name to `nodeProperty` property name.
  String camel(String dash) => _toCamel.putIfAbsent(dash, () {
    return dash.replaceAllMapped(_DASH, (Match m) => m.group(1).toUpperCase());
  });

  String dash(String camel) => _toDash.putIfAbsent(camel, () {
    var dash = camel.replaceAllMapped(_CAMEL, (Match m) => '-' + m.group(1).toLowerCase());
    if (dash.startsWith('-')) dash = dash.substring(1);
    return dash;
  });

}

class NodeBinderBuilder {
  static final Case _case = new Case();
  static final RegExp _CHILD = new RegExp(r'^(\d+)-(text)$'); // support text only
  static final RegExp _PREFIX = new RegExp(r'^:?:?'); // support text only
  final Parser _parser;
  final ExceptionHandler exceptionHandler;
  final AutoSelectComponentFactory componentFactory;

  NodeBinderBuilder(this._parser, this.exceptionHandler, this.componentFactory);

  /**
   * Compile a list of binders from a template prototype.
   *
   * - [templateNode]: template node used to determine what properties the node has.
   * - [events]: a list of DOM events which are associated with changes in the DOM properties.
   * - [bindings]: property name to expressions representing bindings between node and model
   * - [directives]: a map of directive [Type]s to [Directive] annotation representing additional
   *   bindings between the directive and node.
   */
  NodeBinder build(
      Element templateElement,
      List<String> nodeChangeEvents,
      Map<String, String> attributes,
      Map<String, String> bindings,
      List<String> onEvents,
      Map<Type, Directive> directives)
  {
    var nodePropertyBinders = <String, NodePropertyBinder>{};
    var childNodePropertyBinders = [];
    var directiveTypes = <Type>[];
    var childNodes;
    var module = new Module();
    var isTerminal = false;
    Type templateType = null;
    bindings.forEach((String propertyName, String propertyBindExp) {
      var match = _CHILD.firstMatch(propertyName);
      if (match != null) {
        var childIndex = int.parse(match.group(1));
        propertyName = _case.camel(match.group(2));
        if (childNodes == null) childNodes = templateElement.childNodes;
        if (childIndex < childNodes.length) {
          childNodePropertyBinders.length = childIndex + 1; // make sure that we have right length
          childNodePropertyBinders[childIndex] = _createNodePropertyBinder(
              childNodes[childIndex], attributes, propertyName, propertyBindExp);
        }
      } else {
        propertyName = _case.camel(propertyName);
        nodePropertyBinders[propertyName] =
            _createNodePropertyBinder(templateElement, attributes, propertyName, propertyBindExp);
      }
    });
    directives.forEach((Type directiveType, Directive annotation) {
      if (_isTransclusionDirective(annotation)) {
        // process transclusion directives separate.
        templateType = directiveType;
      } else {
        if (annotation.children == Directive.IGNORE_CHILDREN) isTerminal = true;
        _processDirectiveBindings(directiveType, annotation, module, attributes, directiveTypes,
            nodePropertyBinders, templateElement);
      }
    });
    var templatePropertyBinders = null;
    var templateDirectiveTypes;
    var templateModule;
    if (templateType != null) {
      // remove the transclusion bindings
      templatePropertyBinders = <String, NodePropertyBinder>{};
      templateDirectiveTypes = <Type>[];
      templateModule = new Module();
      Directive annotation = directives[templateType];
      _forEach(annotation.bind, (String property, String directiveExp) {
        NodePropertyBinder binder = nodePropertyBinders.remove(property);
        if (binder != null) {
          if (binder.directivePropertyBinders.isNotEmpty) {
            throw "Property '$property' can not be bound to both Template and non-Template directive.";
          }
          templatePropertyBinders[property] = binder;
        }
      });
      _processDirectiveBindings(templateType, annotation, templateModule, attributes,
          templateDirectiveTypes, templatePropertyBinders, templateElement);
    }

    var nodeBinder = new NodeBinder(
        templateElement,
        nodeChangeEvents,
        onEvents.map((n) => _case.camel(n)).toList(),
        nodePropertyBinders.values.toList(),
        childNodePropertyBinders,
        directiveTypes,
        module,
        isTerminal);

    if (templateType != null) {
      nodeBinder = new NodeBinder(templateElement, [], [],
          templatePropertyBinders.values.toList(), [], templateDirectiveTypes,
          templateModule, true, nodeBinder);
    }

    return nodeBinder;
  }

  _processDirectiveBindings(Type directiveType, Directive annotation, Module module,
                            Map<String, String> attributes, List<Type> directiveTypes,
                            Map<String, NodePropertyBinder> nodePropertyBinders, templateElement) {
    if (annotation.module != null) module.install(annotation.module());
    if (annotation is Component) {
      module.bind(directiveType,
                  toFactory: componentFactory(directiveType, annotation),
                  visibility: annotation.visibility);
    } else {
      module.bind(directiveType, visibility: annotation.visibility);
    }
    var directiveIndex = directiveTypes.length;
    directiveTypes.add(directiveType);
    var directivePropertyBinders = <String, DirectivePropertyBinder>{
    };
    _forEach(annotation.bind, (String nodeProp, String directiveExp) {
      var nodePropertyBinder = nodePropertyBinders.putIfAbsent(nodeProp, () {
        return _createNodePropertyBinder(templateElement, attributes, nodeProp);
      });
      var cDirExp = _parse(directiveExp);
      var directivePropertyBinder = new DirectivePropertyBinder(
          directiveIndex, directiveExp, annotation.canChangeModel,
          cDirExp.eval, getter(cDirExp), setter(cDirExp));
      directivePropertyBinders[directiveExp] = directivePropertyBinder;
      nodePropertyBinder.addDirectivePropertyBinder(directivePropertyBinder);
    });
    _forEach(annotation.observe, (String watchExp, String reactionFnExp) {
      var directivePropBinder = directivePropertyBinders.putIfAbsent(watchExp, () {
        // This means that this watcher does not have corresponding node property binding
        var nakedDirectivePropBinder = new DirectivePropertyBinder(
            directiveIndex, watchExp, annotation.canChangeModel);
        return nodePropertyBinders
            .putIfAbsent('', () => new NodePropertyBinder())
            ..addDirectivePropertyBinder(nakedDirectivePropBinder);
      });
      directivePropBinder.isCollection = reactionFnExp.startsWith('*');
      if (directivePropBinder.isCollection) reactionFnExp = reactionFnExp.substring(1);
      var cReactionFnExp = _parse(reactionFnExp);
      directivePropBinder.reactionFnGetter = getter(cReactionFnExp);
    });
  }



  /// Extract getter from [Expression] and wrap it in try-catch block.
  Getter getter(Expression expression) {
    if (expression == null) return null;
    var nakedGetter = expression.eval;
    return (obj) {
      try {
        return nakedGetter(obj);
      } catch (e, s) {
        exceptionHandler(e, s);
      }
    };
  }

  /// Extract setter from [Expression] and wrap it in try-catch block.
  Setter setter(Expression expression) {
    if (expression == null || !expression.isAssignable) return null;
    var nakedSetter = expression.assign;
    return (obj, value) {
      try {
        if (value is CollectionChangeRecord) value = value.iterable;
        if (value is MapChangeRecord) value = value.map;
        nakedSetter(obj, value);
      } catch (e, s) {
        exceptionHandler(e, s);
      }
    };
  }

  void _forEach(collection, forEachFn) {
    if (collection != null) {
      collection.forEach(forEachFn);
    }
  }

  NodePropertyBinder _createNodePropertyBinder(
      Node templateElement,
      Map<String, String> attributes,
      String propertyName,
      [String propertyBindExp])
  {
    assert(!propertyName.contains('-'));
    var propertyExp = _parse(propertyName);
    var nodePropertyGetter;
    var nodePropertySetter;
    bool isNaked = false;
    String attributeValue;
    if (_understandsGetter(templateElement, propertyName, propertyExp.eval)) {
      attributeValue = propertyName;
      nodePropertyGetter = getter(propertyExp);
      nodePropertySetter = setter(propertyExp);
    } else if (templateElement is Element) {
      var attrName = _case.dash(propertyName);
      if (!attributes.containsKey(attrName) && propertyBindExp == null) isNaked = true;
      var emulatedValue = propertyBindExp == null ? attributeValue = attributes[attrName] : null;
      nodePropertyGetter = (_) => emulatedValue;
      nodePropertySetter = (_, value) => emulatedValue = value;
    }
    return new NodePropertyBinder(
        propertyName, isNaked, attributeValue,
        nodePropertyGetter, nodePropertySetter, propertyBindExp,
        propertyBindExp == null ? null : setter(_parse(propertyBindExp)));
  }

  _isTransclusionDirective(Directive annotation) =>
      annotation.children == Directive.TRANSCLUDE_CHILDREN;

  _parse(String exp) => _parser(exp.replaceAll(_PREFIX, ''));
}

class NodeBinder {
  final Element templateElement;
  final List<String> events;
  final List<String> onEvents;
  final List<NodePropertyBinder> nodePropertyBinders;
  final List<NodePropertyBinder> childNodePropertyBinders;
  final List<Type> directiveTypes;
  final Module module;
  final NodeBinder transcludeBinder;
  final bool isTerminal;

  int parentBinderOffset = -1;
  ViewFactory viewFactory;
  bool isEmpty;

  NodeBinder(
      this.templateElement,
      this.events,
      this.onEvents,
      this.nodePropertyBinders,
      this.childNodePropertyBinders,
      this.directiveTypes,
      this.module,
      this.isTerminal,
      [this.transcludeBinder]) {

    isEmpty =
        onEvents.isEmpty &&
        nodePropertyBinders.isEmpty &&
        childNodePropertyBinders.isEmpty &&
        directiveTypes.isEmpty;

    if (!isEmpty && transcludeBinder == null) {
      templateElement.classes.add(NG_BINDING);
    }
  }

  NodeBinder.root()
    : templateElement = null,
      transcludeBinder = null,
      events = const [],
      onEvents = const [],
      nodePropertyBinders = const [],
      childNodePropertyBinders = <NodePropertyBinder>[],
      directiveTypes = const [],
      isTerminal = false,
      module = new Module()
  {
    isEmpty = false;
  }

  get isNotEmpty => !isEmpty;

  addChildTextInterpolation(int index, String interpolation) {
    if (templateElement != null) {
      templateElement.attributes['bind-$index-text'] = interpolation;
      if (isEmpty) templateElement.classes.add(NG_BINDING);
    }
    isEmpty = false;
    if (childNodePropertyBinders.length <= index) {
      childNodePropertyBinders.length = index + 1;
    }
    childNodePropertyBinders[index] = new NodePropertyBinder(
        'text', false, '', (n) => n.text, (n, v) => n.text = v, interpolation);
  }

  NodeBindings bind(Injector injector, Scope scope, FormatterMap formatters,
                    EventHandler eventHandler, NgElement element) {
    var directives = [];
    for(Type type in directiveTypes) {
      var directive = injector.get(type);
      directives.add(directive);
      if (directive is AttachAware) scope.rootScope.runAsync(directive.attach, stable: true);
      if (directive is DetachAware) scope.on(ScopeEvent.DESTROY).listen((_) => directive.detach());
    }
    var nodePropertyBindings = [];
    for(NodePropertyBinder binder in nodePropertyBinders) {
      nodePropertyBindings.add(binder.bind(scope, formatters, element.node, element, directives));
    }
    for(var i = 0, childNodes = element.node.childNodes; i < childNodePropertyBinders.length; i++) {
      var binder = childNodePropertyBinders[i];
      if (binder != null) {
        binder.bind(scope, formatters, childNodes[i], null, null);
      }
    }
    var nodeBindings = new NodeBindings(nodePropertyBindings, directives);
    for(String onEvent in onEvents) {
      eventHandler.register(onEvent);
    }
    // TODO(misko): use EventHandler for this;
    //events.forEach((e) => element.node.addEventListener(e, (e) => nodeBindings.check(true)));
    return nodeBindings;
  }

  Map<String, String> get anchorAttrs {
    assert(directiveTypes.length == 1);
    var attrs = {'type': 'ng/ViewPort/${directiveTypes.first}'};
    nodePropertyBinders.forEach((NodePropertyBinder binder) {
      if (binder.bindExp == null) {
        attrs[binder.property] = binder.attributeValue;
      } else {
        attrs['bind-${binder.property}'] = binder.bindExp;
      }
    });
    return attrs;
  }

  toString() => 'NodeBinder' + _props({
      'parentBinderOffset': parentBinderOffset,
      'bind': nodePropertyBinders,
      'Type': directiveTypes,
      'child': childNodePropertyBinders});
}

/**
 * Represents a facade to all of the individual bindings in the Node and Directive instance.
 */
class NodeBindings {
  final List<NodePropertyBinding> nodePropertyBindings;
  final List directives;

  NodeBindings(this.nodePropertyBindings, this.directives);

  /// Dirty check the Node for changes in properties.
  check(bool fromEvent) {
    for(NodePropertyBinding binding in nodePropertyBindings) {
      binding.check(fromEvent);
    }
  }
}

/**
 * Represents a prototype of a node binding. (A way to build binding).
 */
class NodePropertyBinder {
  final String property;
  final bool isNaked;
  final String attributeValue;
  final String bindExp;
  final Setter bindExpSetter;
  final Getter getter;
  final Setter setter;
  final List<DirectivePropertyBinder> directivePropertyBinders = <DirectivePropertyBinder>[];
  bool canChangeModel = false;
  bool get isCollection => directivePropertyBinders.where((b) => b.isCollection).isNotEmpty;

  NodePropertyBinder([this.property, bool isNaked, this.attributeValue,
                      this.getter, this.setter,
                      this.bindExp, this.bindExpSetter])
      : isNaked = isNaked == null ? true : isNaked;

  addDirectivePropertyBinder(DirectivePropertyBinder propertyBinder) {
    canChangeModel = canChangeModel || propertyBinder.canChangeModel;
    directivePropertyBinders.add(propertyBinder);
  }

  /// Construct an instance node binding from the prototype.
  NodePropertyBinding bind(Scope scope, FormatterMap formatters, Node node, NgElement element, List directives) {
    var binding = new NodePropertyBinding(scope, formatters, node, element, this);
    for(DirectivePropertyBinder directivePropertyBinder in directivePropertyBinders) {
      var directive = directives[directivePropertyBinder.index];
      binding.directiveBindings.add(directivePropertyBinder.bind(binding, scope, directive));
    }
    binding.check(false);
    return binding;
  }


  toString() => 'NodePropretyBinder' + _props({
      'property': property,
      'bindExp': bindExp,
      'dir': directivePropertyBinders});

}

/**
 * Represents a prototype of a directive binding. (A way to build binding).
 */
class DirectivePropertyBinder {
  static final _PROP_NAME_ONLY = new RegExp(r'^[_\w][_\w\d]*$');
  /// Directive index in the list of directives for fast lookup.
  final int index;
  final Getter getter;
  final Getter nakedGetter;
  final Setter setter;
  final String watchExp;
  final bool canChangeModel;
  Getter reactionFnGetter;
  bool isCollection = false;
  bool canRead = null;

  DirectivePropertyBinder(this.index, this.watchExp, this.canChangeModel,
                          [this.nakedGetter, this.getter, this.setter]) {
    if (watchExp == null) {
      canRead = false;
    } else if (!_PROP_NAME_ONLY.hasMatch(watchExp)) {
      canRead = true;
    }
  }

  /// Construct an instance directive binding from the prototype.
  DirectivePropertyBinding bind(NodePropertyBinding nodeBinding, Scope scope, Object directive) {
    if (canRead == null) {
      canRead = _understandsGetter(directive, watchExp, nakedGetter);
    }
    return new DirectivePropertyBinding(this, scope, nodeBinding, directive);
  }

  toString() => 'DirectivePropertyBinder' + _props({
      'exp': watchExp,
      'reaction': reactionFnGetter});
}

/**
 * Represents a binding between the Node instance and bind-* expressions.
 */
class NodePropertyBinding implements FlushAware {
  final Scope scope;
  final Node node;
  final NgElement element;
  final NodePropertyBinder binder;
  final List<DirectivePropertyBinding> directiveBindings = <DirectivePropertyBinding>[];
  Watch _watch;
  FlushQueue _nodePropertyWriteflushQueue;
  var _newValue, _lastValue, _currentValue;

  NodePropertyBinding(Scope this.scope,
                      FormatterMap formatters,
                      this.node,
                      this.element,
                      this.binder)
  {
    var canChangeModel = binder.canChangeModel;
    _currentValue = this;
    _nodePropertyWriteflushQueue = new FlushQueue(this, scope.rootScope, !canChangeModel);
    var bindExp = binder.bindExp;
    if (bindExp != null && bindExp.isNotEmpty) {
      _watch = scope.watch(bindExp, setValue, formatters: formatters,
          canChangeModel: canChangeModel, collection: binder.isCollection);
    }
  }

  /// Manually check to see if the Node instance property has changed. Usually invoked as a result
  /// of DOM event.
  check(bool fromDomEvent) {
    if (fromDomEvent || _watch == null && !binder.isNaked) {
      var value = binder.getter(node);
      if (same(_currentValue, value)) return;
      setValue(value, _currentValue);
      if(binder.bindExpSetter != null) binder.bindExpSetter(scope.context, value);
    }
  }

  /// Notify binding of change, (either from the [check] method or from [DirectivePropertyBinding]).
  setValue(value, lastValue, [DirectivePropertyBinding source]) {
    if (same(value, _currentValue)) return;
    _newValue = value;
    _lastValue = lastValue;
    if (binder.setter != null) {
      _nodePropertyWriteflushQueue.schedule();
    }
    if(source !=null && binder.bindExpSetter != null) binder.bindExpSetter(scope.context, value);
    for(DirectivePropertyBinding directiveBinding in directiveBindings) {
      if (source != directiveBinding) {
        directiveBinding.setValue(value, lastValue);
      }
    }
  }

  flush() {
    _currentValue = _newValue;
    if (binder.property == 'className') {
      _toSet(_lastValue).forEach(element.removeClass);
      _toSet(_newValue).forEach(element.addClass);
    } else {
      binder.setter(node, _newValue);
    }
  }

  Set<String> _toSet(String list) {
    var set = new Set();
    if (list is String) {
      set.addAll(list.split(' '));
    }
    return set;
  }
}

/**
 * Represents a binding between the directive instance and node instance.
 */
class DirectivePropertyBinding implements FlushAware {
  final DirectivePropertyBinder binder;

  /// Associated NodePropertyBinding
  final NodePropertyBinding nodeBinding;
  /// Directive instance
  final Object directive;

  /**
   * Directives `directiveReactionMethod` which needs to be called when `directiveExpression`
   * changes. This is a way to set up [Watch]es in a declarative manner.
   *
   *     @Directive({ observe: const {'directiveExpression': 'directiveReactionMethod'}})
   */
  final ReactionFn reactionFn;
  /// The [Watch] if the directive needs to be observed. This is either from [Directive.bind]
  /// or [Directive.observe] annotation.
  Watch _watch;

  var _skipInitialWatchChange = true;
  var _newValue, _lastValue, _currentValue;

  FlushQueue _flushQueue;

  DirectivePropertyBinding(
      DirectivePropertyBinder binder,
      Scope scope,
      this.nodeBinding,
      dynamic directive)
    : binder = binder,
      directive = directive,
      reactionFn = binder.reactionFnGetter == null ? null : binder.reactionFnGetter(directive)
  {
    _currentValue = _newValue = this;
    var immediate = nodeBinding.binder.canChangeModel == binder.canChangeModel;
    if (nodeBinding.binder.isNaked) {
      _skipInitialWatchChange = false;
    }
    _flushQueue = new FlushQueue(this, scope.rootScope, immediate);
    if (binder.watchExp != null && binder.canRead &&
        binder.watchExp.isNotEmpty && binder.canChangeModel) {
      scope.watch(binder.watchExp, onPropertyChange, context: directive,
          collection: binder.isCollection);
    }
  }

  /// called by [Scope.watch]
  onPropertyChange(value, lastValue) {
    if(_skipInitialWatchChange) {
      _skipInitialWatchChange = false;
      // skip the first check if the node property is naked.
      return;
    }
    nodeBinding.setValue(value, lastValue, this);
    if (reactionFn != null && !same(_currentValue, value)) reactionFn(_currentValue = value, lastValue);
  }

  /// Notify binding of a change to value. This change could come from [Watch] or from
  /// [NodePropertyBinding]
  setValue(value, lastValue) {
    _newValue = value;
    _lastValue = lastValue;
    _flushQueue.schedule();
  }

  flush() {
    if (same(_currentValue, _newValue)) return;
    if (binder.setter != null) binder.setter(directive, _currentValue = _newValue);
    if (reactionFn != null) reactionFn(_newValue, _lastValue);
  }
}

abstract class FlushAware {
  flush();
}

class FlushQueue {
  final RootScope rootScope;
  final FlushAware flushAware;
  final bool immediate;
  bool _isPending = false;
  Function _flushFn;

  FlushQueue(this.flushAware, this.rootScope, this.immediate) {
    _flushFn = () {
      _isPending = false;
      flushAware.flush();
    };
  }
  
  void schedule() {
    if (immediate) {
      _flushFn();
    } else if (!_isPending) {
      rootScope.domWrite(_flushFn);
    }
  }
}

_props(Map<String, dynamic> map) =>
    '{' + map.keys.map((k) => _prop(k, map[k])).where((t) => t.isNotEmpty).join(', ') + '}';
_prop(name, value) => value == null || (value is List && value.isEmpty) ? '' : '$name=$value';
