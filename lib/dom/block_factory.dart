library angular.dom.block_factory;

import "dart:async" as async;
import "dart:html" as dom;
import "dart:mirrors";
import "package:di/di.dart";
import 'package:perf_api/perf_api.dart';

import "block.dart";
import "block_factory.dart";
import "common.dart";
import "compiler.dart";
import "directive.dart";
import "http.dart";
import "selector.dart";  // TODO(misko): import DirectiveRef only
import "../cache.dart";
import "../directives/ng_mustache.dart";
import "../parser/parser_library.dart";
import "../interpolate.dart";
import "../scope.dart";

/**
 * BoundBlockFactory is a [BlockFactory] which does not need Injector because
 * it is pre-bound to an injector from the parent. This means that this
 * BoundBlockFactory can only be used from within a specific Directive such
 * as [NgRepeat], but it can not be stored in a cache.
 *
 * The BoundBlockFactory needs [Scope] to be created.
 */

class BoundBlockFactory {
  BlockFactory blockFactory;

  Injector injector;

  BoundBlockFactory(BlockFactory this.blockFactory, Injector this.injector);

  Block call(Scope scope) {
    return blockFactory(injector.createChild([new Module()..value(Scope, scope)]));
  }
}

/**
 * BlockFactory is used to create new [Block]s. BlockFactory is created by the
 * [Compiler] as a result of compiling a template.
 */

class BlockFactory {
  List directivePositions;

  List<dom.Node> templateElements;

  Profiler _perf;

  BlockFactory(this.templateElements, this.directivePositions, this._perf);

  BoundBlockFactory bind(Injector injector) {
    return new BoundBlockFactory(this, injector);
  }

  Block call(Injector injector, [List<dom.Node> elements]) {
    if (elements == null) {
      elements = cloneElements(templateElements);
    }
    var block = new Block(elements);
    _link(block, elements, directivePositions, injector);
    return block;
  }

  _link(Block block, List<dom.Node> nodeList, List directivePositions, Injector parentInjector) {
    var preRenderedIndexOffset = 0;
    var directiveDefsByName = {
    };

    for (num i = 0, ii = directivePositions.length; i < ii;) {
      num index = directivePositions[i++];

      List<DirectiveRef> directiveRefs = directivePositions[i++];
      List childDirectivePositions = directivePositions[i++];
      var nodeListIndex = index + preRenderedIndexOffset;
      dom.Node node = nodeList[nodeListIndex];

      // if node isn't attached to the DOM, create a parent for it.
      var parentNode = node.parentNode;
      var fakeParent = false;
      if (parentNode == null) {
        fakeParent = true;
        parentNode = new dom.DivElement();
        parentNode.append(node);
      }

      var childInjector = _instantiateDirectives(block, parentInjector, node,
                      directiveRefs, parentInjector.get(Parser));

      if (childDirectivePositions != null) {
        _link(block, node.nodes, childDirectivePositions, childInjector);
      }

      if (fakeParent) {
        // extract the node from the parentNode.
        nodeList[nodeListIndex] = parentNode.nodes[0];
      }
    }
  }

  Injector _instantiateDirectives(Block block, Injector parentInjector,
                                  dom.Node node, List<DirectiveRef> directiveRefs,
                                  Parser parser) =>
    _perf.time('angular.blockFactory.instantiateDirectives', () {
    if (directiveRefs == null || directiveRefs.length == 0) return parentInjector;
    var nodeModule = new Module();
    var blockHoleFactory = (_) => null;
    var blockFactory = (_) => null;
    var boundBlockFactory = (_) => null;
    var nodeAttrs = node is dom.Element ? new NodeAttrs(node) : null;
    var nodesAttrsDirectives = null;
    Map<Type, _ComponentFactory> fctrs;

    nodeModule.value(Block, block);
    nodeModule.value(dom.Element, node);
    nodeModule.value(dom.Node, node);
    nodeModule.value(NodeAttrs, nodeAttrs);
    directiveRefs.forEach((DirectiveRef ref) {
      Type type = ref.directive.type;
      NgAnnotationBase annotation = ref.directive.annotation;
      var visibility = _elementOnly;
      if (ref.directive.$visibility == NgDirective.CHILDREN_VISIBILITY) {
        visibility = null;
      } else if (ref.directive.$visibility == NgDirective.DIRECT_CHILDREN_VISIBILITY) {
        visibility = _elementDirectChildren;
      }
      if (ref.directive.type == NgTextMustacheDirective) {
        nodeModule.factory(NgTextMustacheDirective, (Injector injector) {
          return new NgTextMustacheDirective(node, ref.value, injector.get(Interpolate), injector.get(Scope));
        });
      } else if (ref.directive.type == NgAttrMustacheDirective) {
        if (nodesAttrsDirectives == null) {
          nodesAttrsDirectives = [];
          nodeModule.factory(NgAttrMustacheDirective, (Injector injector) {
            nodesAttrsDirectives.forEach((ref) {
              new NgAttrMustacheDirective(nodeAttrs, ref.value, injector.get(Interpolate), injector.get(Scope));
            });
          });
        }
        nodesAttrsDirectives.add(ref);
      } else if (ref.directive.isComponent) {
        //nodeModule.factory(type, new ComponentFactory(node, ref.directive), visibility: visibility);
        // TODO(misko): there should be no need to wrap function like this.
        nodeModule.factory(type, (Injector injector) {
          Compiler compiler = injector.get(Compiler);
          Scope scope = injector.get(Scope);
          BlockCache blockCache = injector.get(BlockCache);
          Http http = injector.get(Http);
          TemplateCache templateCache = injector.get(TemplateCache);
          // This is a bit of a hack since we are returning different type then we are.
          var componentFactory = new _ComponentFactory(node, ref.directive, injector.get(dom.NodeTreeSanitizer));
          if (fctrs == null) fctrs = new Map<Type, _ComponentFactory>();
          fctrs[type] = componentFactory;
          return componentFactory(injector, compiler, scope, blockCache, http, templateCache);
        }, visibility: visibility);
      } else {
        nodeModule.type(type, visibility: visibility);
      }
      for (var publishType in ref.directive.$publishTypes) {
        nodeModule.factory(publishType, (Injector injector) => injector.get(type), visibility: visibility);
      }
      if (annotation is NgDirective && (annotation as NgDirective).transclude) {
        blockHoleFactory = (_) => new BlockHole([node]);
        blockFactory = (_) => ref.blockFactory;
        boundBlockFactory = (Injector injector) => ref.blockFactory.bind(injector);
      }
    });
    nodeModule.factory(BlockHole, blockHoleFactory);
    nodeModule.factory(BlockFactory, blockFactory);
    nodeModule.factory(BoundBlockFactory, boundBlockFactory);
    var nodeInjector = parentInjector.createChild([nodeModule]);
    var scope = nodeInjector.get(Scope);
    directiveRefs.forEach((ref) {
      var controller = nodeInjector.get(ref.directive.type);
      var shadowScope = (fctrs != null && fctrs.containsKey(ref.directive.type)) ? fctrs[ref.directive.type].shadowScope : null;
      _createAttributeMapping(ref.directive, nodeAttrs == null ? new _AnchorAttrs(ref) : nodeAttrs, scope, shadowScope, controller, parser);
      if (_understands(controller, 'attach')) {
        var removeWatcher;
        removeWatcher = scope.$watch(() {
          removeWatcher();
          controller.attach();
        });
      }
      if (_understands(controller, 'detach')) {
        scope.$on(r'$destroy', controller.detach);
      }
    });
    return nodeInjector;
  });

  // DI visibility callback allowing node-local visibility.

  bool _elementOnly(Injector requesting, Injector defining) {
    if (requesting.name == _SHADOW) {
      requesting = requesting.parent;
    }
    return identical(requesting, defining);
  }

  // DI visibility callback allowing visibility from direct child into parent.

  bool _elementDirectChildren(Injector requesting, Injector defining) {
    if (requesting.name == _SHADOW) {
      requesting = requesting.parent;
    }
    return _elementOnly(requesting, defining) || identical(requesting.parent, defining);
  }
}

/**
 * BlockCache is used to cache the compilation of templates into [Block]s.
 * It can be used synchronously if HTML is known or asynchronously if the
 * template HTML needs to be looked up from the URL.
 */

class BlockCache {
  Cache<BlockFactory> _blockFactoryCache = new Cache<BlockFactory>();

  Http $http;

  TemplateCache $templateCache;

  Compiler compiler;

  dom.NodeTreeSanitizer treeSanitizer;

  BlockCache(Http this.$http, TemplateCache this.$templateCache, Compiler this.compiler, dom.NodeTreeSanitizer this.treeSanitizer);

  BlockFactory fromHtml(String html) {
    BlockFactory blockFactory = _blockFactoryCache.get(html);
    if (blockFactory == null) {
      var div = new dom.Element.tag('div');
      div.setInnerHtml(html, treeSanitizer: treeSanitizer);
      blockFactory = compiler(div.nodes);
      _blockFactoryCache.put(html, blockFactory);
    }
    return blockFactory;
  }

  async.Future<BlockFactory> fromUrl(String url) {
    return $http.getString(url, cache: $templateCache).then((String tmpl) {
      return fromHtml(tmpl);
    });
  }
}

/**
 * A convenience wrapper for "templates" cache, its purpose is
 * to create new Type which can be used for injection.
 */

class TemplateCache extends Cache<HttpResponse> {
}

/**
 * ComponentFactory is responsible for setting up components. This includes
 * the shadowDom, fetching template, importing styles, setting up attribute
 * mappings, publishing the controller, and compiling and caching the template.
 */

class _ComponentFactory {

  dom.Element element;

  Directive directive;

  dom.ShadowRoot shadowDom;

  Scope shadowScope;

  Injector shadowInjector;

  Compiler compiler;

  var controller;

  dom.NodeTreeSanitizer treeSanitizer;

  _ComponentFactory(this.element, this.directive, this.treeSanitizer);

  dynamic call(Injector injector, Compiler compiler, Scope scope, BlockCache $blockCache, Http $http, TemplateCache $templateCache) {
    this.compiler = compiler;
    shadowDom = element.createShadowRoot();
    shadowDom.applyAuthorStyles = directive.$shadowRootOptions.applyAuthorStyles;
    shadowDom.resetStyleInheritance = directive.$shadowRootOptions.resetStyleInheritance;

    shadowScope = scope.$new(true);
    // TODO(pavelgj): fetching CSS with Http is mainly an attempt to
    // work around an unfiled Chrome bug when reloading same CSS breaks
    // styles all over the page. We shouldn't be doing browsers work,
    // so change back to using @import once Chrome bug is fixed or a
    // better work around is found.
    async.Future<String> cssFuture;
    if (directive.$cssUrl != null) {
      cssFuture = $http.getString(directive.$cssUrl, cache: $templateCache);
    } else {
      cssFuture = new async.Future.value(null);
    }
    var blockFuture;
    if (directive.$template != null) {
      blockFuture = new async.Future.value($blockCache.fromHtml(directive.$template));
    } else if (directive.$templateUrl != null) {
      blockFuture = $blockCache.fromUrl(directive.$templateUrl);
    }
    TemplateLoader templateLoader = new TemplateLoader(cssFuture.then((String css) {
      if (css != null) {
        shadowDom.setInnerHtml('<style>$css</style>', treeSanitizer: treeSanitizer);
      }
      if (blockFuture != null) {
        return blockFuture.then((BlockFactory blockFactory) => attachBlockToShadowDom(blockFactory));
      }
      return shadowDom;
    }));
    controller = createShadowInjector(injector, templateLoader).get(directive.type);
    if (directive.$publishAs != null) {
      shadowScope[directive.$publishAs] = controller;
    }
    return controller;
  }

  attachBlockToShadowDom(BlockFactory blockFactory) {
    var block = blockFactory(shadowInjector);
    shadowDom.nodes.addAll(block.elements);
    return shadowDom;
  }

  createShadowInjector(injector, TemplateLoader templateLoader) {
    var shadowModule = new Module()..type(directive.type)..value(Scope, shadowScope)..value(TemplateLoader, templateLoader)..value(dom.ShadowRoot, shadowDom);
    shadowInjector = injector.createChild([shadowModule], name: _SHADOW);
    return shadowInjector;
  }
}

class _AnchorAttrs extends NodeAttrs {
  DirectiveRef _directiveRef;

  _AnchorAttrs(DirectiveRef this._directiveRef):super(null);

  operator [](name) => name == '.' ? _directiveRef.value : null;

  observe(String attributeName, AttributeChanged notifyFn) {
    if (attributeName == '.') {
      notifyFn(_directiveRef.value);
    } else {
      notifyFn(null);
    }
  }
}


RegExp _MAPPING = new RegExp(r'^([\@\=\&\!])(\.?)\s*(.*)$');

_createAttributeMapping(Directive directive, NodeAttrs nodeAttrs, Scope scope, Scope shadowScope, Object controller, Parser parser) {
  directive.$map.forEach((attrName, mapping) {
    Match match = _MAPPING.firstMatch(mapping);
    if (match == null) {
      throw "Unknown mapping '$mapping' for attribute '$attrName'.";
    }
    var mode = match[1];
    var controllerContext = match[2];
    var dstPath = match[3];
    var context = controllerContext == '.' ? controller : shadowScope;

    Expression dstPathFn = parser(dstPath.isEmpty ? attrName : dstPath);
    if (!dstPathFn.assignable) {
      throw "Expression '$dstPath' is not assignable in mapping '$mapping' for attribute '$attrName'.";
    }
    switch (mode) {
      case '@':
        nodeAttrs.observe(attrName, (value) => dstPathFn.assign(context, value));
        break;
      case '=':
        Expression attrExprFn = parser(nodeAttrs[attrName]);
        var shadowValue = null;
        scope.$watch(() => attrExprFn.eval(scope), (v) => dstPathFn.assign(context, shadowValue = v));
        if (shadowScope != null) {
          if (attrExprFn.assignable) {
            shadowScope.$watch(() => dstPathFn.eval(context), (v) {
              if (shadowValue != v) {
                shadowValue = v;
                attrExprFn.assign(scope, v);
              }
            });
          }
        }
        break;
      case '!':
        Expression attrExprFn = parser(nodeAttrs[attrName]);
        var stopWatching;
        stopWatching = scope.$watch(() => attrExprFn.eval(scope), (value) {
          if (dstPathFn.assign(context, value) != null) {
            stopWatching();
          }
        });
        break;
      case '&':
        dstPathFn.assign(context, parser(nodeAttrs[attrName]).bind(scope));
        break;
    }
  });
}


bool _understands(obj, symbol) {
  if (symbol is String) symbol = new Symbol(symbol);
  return reflect(obj).type.methods.containsKey(symbol);
}

String _SHADOW = 'SHADOW_INJECTOR';

