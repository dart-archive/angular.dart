/**
 *
 * Formatters for [angular.dart](#angular/angular), a web framework for Dart. A formatter is a
 * pure function that performs a transformation on input data from an expression.
 *
 * This library is included as part of [angular.dart](#angular/angular). It provides all of
 * the core formatters available in Angular. You can extend Angular by writing your own formatters
 * and providing them as part of a custom library.
 *
 * Formatters are typically used within `{{ }}` to
 * convert data to human-readable form. They may also be used inside repeaters to transform arrays.
 *
 * For example:
 *
 *      {{ _some_expression_ | json }}
 *
 * or, in a repeater:
 *
 *      <div ng-repeat="item in items | filter:_predicate_">
 *
 *
 */
library angular.formatter;

export "package:angular/formatter/module_internal.dart" show
    Currency,
    Date,
    Filter,
    Json,
    LimitTo,
    Lowercase,
    Arrayify,
    Number,
    OrderBy,
    Uppercase,
    Stringify;
