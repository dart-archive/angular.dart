library angular.core.dom_internal;

import 'dart:async' as async;
import 'dart:convert' show JSON;
import 'dart:html' as dom;
import 'dart:js' as js;

import 'package:di/di.dart';
import 'package:di/annotations.dart';
import 'package:perf_api/perf_api.dart';

import 'package:angular/cache/module.dart';

import 'package:angular/core/annotation.dart';
import 'package:angular/core/module_internal.dart';
import 'package:angular/core/parser/parser.dart';
import 'package:angular/core_dom/dom_util.dart' as util;
import 'package:angular/core_dom/static_keys.dart';
import 'package:angular/core_dom/directive_injector.dart';
export 'package:angular/core_dom/directive_injector.dart' show DirectiveInjector;

import 'package:angular/change_detection/watch_group.dart' show Watch, PrototypeMap;
import 'package:angular/change_detection/ast_parser.dart';
import 'package:angular/core/registry.dart';

import 'package:angular/directive/module.dart' show NgBaseCss;
import 'dart:collection';

part 'animation.dart';
part 'cookies.dart';
part 'common.dart';
part 'compiler.dart';
part 'compiler_config.dart';
part 'directive.dart';
part 'directive_map.dart';
part 'element_binder.dart';
part 'element_binder_builder.dart';
part 'event_handler.dart';
part 'http.dart';
part 'mustache.dart';
part 'ng_element.dart';
part 'node_cursor.dart';
part 'selector.dart';
part 'shadow_dom_component_factory.dart';
part 'shadowless_shadow_root.dart';
part 'template_cache.dart';
part 'transcluding_component_factory.dart';
part 'tree_sanitizer.dart';
part 'view.dart';
part 'view_factory.dart';
part 'web_platform.dart';

class CoreDomModule extends Module {
  CoreDomModule() {
    bind(dom.Window, toValue: dom.window);
    bind(ElementProbe, toValue: null);

    // Default to a unlimited-sized TemplateCache
    bind(TemplateCache, toFactory: (CacheRegister register) {
      var templateCache = new TemplateCache();
      register.registerCache("TemplateCache", templateCache);
      return templateCache;
    }, inject: [CACHE_REGISTER_KEY]);
    bind(dom.NodeTreeSanitizer, toImplementation: NullTreeSanitizer);

    bind(TextMustache);
    bind(AttrMustache);

    bind(Compiler);
    bind(CompilerConfig);

    bind(ComponentFactory, toInstanceOf: SHADOW_DOM_COMPONENT_FACTORY_KEY);
    bind(ShadowDomComponentFactory);
    bind(TranscludingComponentFactory);
    bind(Content);
    bind(ContentPort, toValue: null);
    bind(ComponentCssRewriter);
    bind(WebPlatform);

    bind(Http);
    bind(UrlRewriter);
    bind(HttpBackend);
    bind(HttpDefaultHeaders);
    bind(HttpDefaults);
    bind(HttpInterceptors);
    bind(HttpConfig, toValue: new HttpConfig());
    bind(Animate);
    bind(ViewCache);
    bind(BrowserCookies);
    bind(Cookies);
    bind(LocationWrapper);
    bind(DirectiveMap);
    bind(DirectiveSelectorFactory);
    bind(ElementBinderFactory);
    bind(NgElement);
    bind(EventHandler);
  }
}
