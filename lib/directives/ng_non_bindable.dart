library angular.directive.ng_non_bindable;

import 'dart:html' as dom;
import '../dom/directive.dart';
import '../parser/parser_library.dart';
import '../scope.dart';

/**
 * Causes the compiler to ignore all other directives and Angular markup present
 * on the matched elements and all of their descendants.  This allows one to
 * have DOM nodes that contains Angular markup but should not be processed as a
 * template.
 *
 * Example:
 *
 *     <div foo="{{a}}" ng-non-bindable>
 *       <span ng-bind="b"></span>{{b}}
 *     </div>
 *
 * In the above example, because the `div` element has the `ng-non-bindable`
 * attribute set on it, `foo` attribute won't be processed.  The `ng-bind`
 * directive and the interpolation for `{{b}}` are also not processed because
 * Angular will not process the `span` child element.
 */
@NgNonBindable(selector: '[ng-non-bindable]')
class NgNonBindableAttrDirective {}
