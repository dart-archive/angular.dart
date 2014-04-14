library angular.core.dom_internal;

import 'dart:async' as async;
import 'dart:convert' show JSON;
import 'dart:html' as dom;

import 'package:di/di.dart';
import 'package:perf_api/perf_api.dart';

import 'package:angular/core/annotation.dart';
import 'package:angular/core/annotation_src.dart' show SHADOW_DOM_INJECTOR_NAME;
import 'package:angular/core/module_internal.dart';
import 'package:angular/core/parser/parser.dart';
import 'package:angular/core_dom/dom_util.dart' as util;

import 'package:angular/change_detection/watch_group.dart' show Watch, PrototypeMap;
import 'package:angular/core/registry.dart';

import 'package:angular/directive/module.dart' show NgBaseCss;

part 'animation.dart';
part 'view.dart';
part 'view_factory.dart';
part 'cookies.dart';
part 'common.dart';
part 'compiler.dart';
part 'directive.dart';
part 'directive_map.dart';
part 'element_binder.dart';
part 'element_binder_builder.dart';
part 'event_handler.dart';
part 'http.dart';
part 'mustache.dart';
part 'node_cursor.dart';
part 'selector.dart';
part 'tagging_compiler.dart';
part 'tagging_view_factory.dart';
part 'template_cache.dart';
part 'tree_sanitizer.dart';
part 'walking_compiler.dart';
part 'ng_element.dart';

class CoreDomModule extends Module {
  CoreDomModule() {
    value(dom.Window, dom.window);
    value(ElementProbe, null);

    factory(TemplateCache, (_) => new TemplateCache(capacity: 0));
    type(dom.NodeTreeSanitizer, implementedBy: NullTreeSanitizer);

    type(TextMustache);
    type(AttrMustache);

    type(Compiler, implementedBy: TaggingCompiler);
    type(Http);
    type(UrlRewriter);
    type(HttpBackend);
    type(HttpDefaultHeaders);
    type(HttpDefaults);
    type(HttpInterceptors);
    type(Animate);
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
