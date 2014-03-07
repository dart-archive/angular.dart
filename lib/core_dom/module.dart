library angular.core.dom;

import 'dart:async' as async;
import 'dart:convert' show JSON;
import 'dart:html' as dom;

import 'package:di/di.dart';
import 'package:perf_api/perf_api.dart';

import 'package:angular/core/module.dart';
import 'package:angular/core/parser/parser.dart';
import 'package:angular/core_dom/dom_util.dart' as util;

part 'animation.dart';
part 'view.dart';
part 'view_factory.dart';
part 'cookies.dart';
part 'common.dart';
part 'compiler.dart';
part 'directive.dart';
part 'directive_map.dart';
part 'element_binder.dart';
part 'event_handler.dart';
part 'http.dart';
part 'ng_mustache.dart';
part 'node_cursor.dart';
part 'selector.dart';
part 'tagging_compiler.dart';
part 'tagging_view_factory.dart';
part 'template_cache.dart';
part 'tree_sanitizer.dart';
part 'walking_compiler.dart';
part 'ng_element.dart';

class NgCoreDomModule extends Module {
  NgCoreDomModule() {
    value(dom.Window, dom.window);
    value(ElementProbe, null);

    factory(TemplateCache, (_) => new TemplateCache(capacity: 0));
    type(dom.NodeTreeSanitizer, implementedBy: NullTreeSanitizer);

    type(NgTextMustacheDirective);
    type(NgAttrMustacheDirective);

    type(Compiler, implementedBy: TaggingCompiler);
    type(Http);
    type(UrlRewriter);
    type(HttpBackend);
    type(HttpDefaultHeaders);
    type(HttpDefaults);
    type(HttpInterceptors);
    type(NgAnimate);
    type(ViewCache);
    type(BrowserCookies);
    type(Cookies);
    type(LocationWrapper);
    type(DirectiveMap);
    type(DirectiveSelectorFactory);
    type(ElementBinderFactory);
    type(NgElement);
    type(EventHandler);
  }
}

/**
 * Implementing components [onShadowRoot] method will be called when
 * the template for the component has been loaded and inserted into Shadow DOM.
 * It is guaranteed that when [onShadowRoot] is invoked, that shadow DOM
 * has been loaded and is ready.
 */
abstract class NgShadowRootAware {
  void onShadowRoot(dom.ShadowRoot shadowRoot);
}
