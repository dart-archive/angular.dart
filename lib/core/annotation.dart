/**
 * Angular class annotations for Directives, Filters, and Services.
 */
library angular.core.annotation;

import "dart:html" show ShadowRoot;

export "package:angular/core/annotation_src.dart" show
    NgAttachAware,
    NgDetachAware,
    NgShadowRootAware,

    NgFilter,
    NgInjectableService,

    AbstractNgAnnotation,
    AbstractNgAttrAnnotation,
    NgTemplate,
    NgComponent,
    NgController,
    NgDirective,

    AbstractNgFieldAnnotation,
    NgAttr,
    NgCallback,
    NgOneWay,
    NgOneWayOneTime,
    NgTwoWay;


/**
 * Implementing components [onShadowRoot] method will be called when
 * the template for the component has been loaded and inserted into Shadow DOM.
 * It is guaranteed that when [onShadowRoot] is invoked, that shadow DOM
 * has been loaded and is ready.
 */
abstract class NgShadowRootAware {
  void onShadowRoot(ShadowRoot shadowRoot);
}
