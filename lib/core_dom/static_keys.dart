library angular.core_dom.static_keys;

import 'dart:html' as dom;
import 'package:di/di.dart';
import 'package:angular/core/static_keys.dart';
import 'package:angular/core_dom/module_internal.dart';

export 'package:angular/directive/static_keys.dart' show NG_BASE_CSS_KEY;
export 'package:angular/core/static_keys.dart';

// Keys used to call Injector.getByKey and Module.bindByKey

Key ANIMATE_KEY = new Key(Animate);
Key BOUND_VIEW_FACTORY_KEY = new Key(BoundViewFactory);
Key COMPILER_KEY = new Key(Compiler);
Key COMPONENT_CSS_REWRITER_KEY = new Key(ComponentCssRewriter);
Key DIRECTIVE_MAP_KEY = new Key(DirectiveMap);
Key ELEMENT_KEY = new Key(dom.Element);
Key ELEMENT_PROBE_KEY = new Key(ElementProbe);
Key EVENT_HANDLER_KEY = new Key(EventHandler);
Key HTTP_KEY = new Key(Http);
Key NG_ELEMENT_KEY = new Key(NgElement);
Key NODE_ATTRS_KEY = new Key(NodeAttrs);
Key NODE_KEY = new Key(dom.Node);
Key NODE_TREE_SANITIZER_KEY = new Key(dom.NodeTreeSanitizer);
Key SHADOW_ROOT_KEY = new Key(dom.ShadowRoot);
Key TEMPLATE_CACHE_KEY = new Key(TemplateCache);
Key TEMPLATE_LOADER_KEY = new Key(TemplateLoader);
Key TEXT_MUSTACHE_KEY = new Key(TextMustache);
Key VIEW_CACHE_KEY = new Key(ViewCache);
Key VIEW_FACTORY_KEY = new Key(ViewFactory);
Key VIEW_KEY = new Key(View);
Key VIEW_PORT_KEY = new Key(ViewPort);
Key WEB_PLATFORM_KEY = new Key(WebPlatform);
Key WINDOW_KEY = new Key(dom.Window);
