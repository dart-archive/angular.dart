library angular.directive.ng_template;

import 'dart:html' as dom;
import '../dom/http.dart';
import '../dom/directive.dart';
import '../dom/template_cache.dart';

/**
 * The [NgTemplateElementDirective] allows one to preload an Angular template
 * into the [TemplateCache].  It only works on `<template>` elements that have
 * `type="text/ng-template`.  For such elements, The entire contents of the
 * elements are loaded into the [TemplateCache] under the URL specified by the
 * `id` attribute.
 *
 * Sample usage:
 *
 *     <template id="url" type="text/ng-template">TEMPLATE CONTENTS</template>
 *
 * Refer [TemplateCache] for a **full example** as well as more information.
 */
@NgDirective(
  selector: 'template[type=text/ng-template]',
  map: const {'id': '@.templateUrl'})
class NgTemplateElementDirective {
  dom.Element element;
  TemplateCache templateCache;

  NgTemplateElementDirective(dom.Element this.element, TemplateCache this.templateCache);
  set templateUrl(url) => templateCache.put(url, new HttpResponse(200, element.content.innerHtml));
}
