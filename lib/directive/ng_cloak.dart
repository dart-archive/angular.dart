part of angular.directive;

/**
 * The `ngCloak` directive is used to prevent the Angular html template from
 * being briefly displayed by the browser in its raw (uncompiled) form while
 * your application is loading. Use this directive to avoid the undesirable
 * flicker effect caused by the html template display.
 *
 * The directive can be applied to the `<body>` element, but typically a
 * fine-grained application is preferred in order to benefit from progressive
 * rendering of the browser view.
 *
 * `ngCloak` works in cooperation with a css. Following is the css rule:
 *
 *     [ng-cloak], [data-ng-cloak], .ng-cloak {
 *        display: none !important;
 *     }
 *
 * When this css rule is loaded by the browser, all html elements (including
 * their children) that are tagged with the `ng-cloak` directive are hidden.
 * When Angular comes across this directive during the compilation of the
 * template it deletes the `ngCloak` element attribute, which makes the compiled
 * element visible.
 */
@Decorator(selector: '[ng-cloak]')
@Decorator(selector: '.ng-cloak')
class NgCloak {
  NgCloak(dom.Element element, Animate animate) {
    element.attributes.remove('ng-cloak');
    animate.removeClass(element, 'ng-cloak');
  }
}
