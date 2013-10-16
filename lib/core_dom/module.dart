library angular.core.dom;

import 'dart:async' as async;
import 'dart:json' as json;
import 'dart:html' as dom;
import 'dart:mirrors';

import 'package:di/di.dart';
import 'package:perf_api/perf_api.dart';

import '../core/module.dart';
import '../core/parser/parser_library.dart';

part 'block.dart';
part 'block_factory.dart';
part 'common.dart';
part 'compiler.dart';
part 'directive.dart';
part 'http.dart';
part 'ng_mustache.dart';
part 'node_cursor.dart';
part 'selector.dart';
part 'template_cache.dart';
part 'tree_sanitizer.dart';

class NgCoreDomModule extends Module {
  NgCoreDomModule() {
    value(TextChangeListener, null);
    factory(TemplateCache, (_) => new TemplateCache(capacity: 0));
    type(dom.NodeTreeSanitizer, implementedBy: NullTreeSanitizer);

    type(NgTextMustacheDirective);
    type(NgAttrMustacheDirective);

    type(Compiler);
    type(Http);
    type(UrlRewriter);
    factory(HttpBackend, (i) { throw "Why not Override????"; });
    type(HttpDefaultHeaders);
    type(HttpDefaults);
    type(HttpInterceptors);
    type(BlockCache);
    type(GetterSetter);

  }
}
