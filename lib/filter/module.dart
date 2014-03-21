/**
*
* Filters available in the main [angular.dart](#angular/angular) library.
*
* This package is imported for you as part of [angular.dart](#angular/angular),
* and lists all of the basic filters that are part of Angular.
*
*
*/
library angular.filter;

import 'dart:convert' show JSON;
import 'package:intl/intl.dart';
import 'package:di/di.dart';
import 'package:angular/core/module.dart';
import 'package:angular/core/parser/parser.dart';

part 'currency.dart';
part 'date.dart';
part 'filter.dart';
part 'json.dart';
part 'limit_to.dart';
part 'lowercase.dart';
part 'number.dart';
part 'order_by.dart';
part 'uppercase.dart';

class NgFilterModule extends Module {
  NgFilterModule() {
    type(CurrencyFilter);
    type(DateFilter);
    type(FilterFilter);
    type(JsonFilter);
    type(LimitToFilter);
    type(LowercaseFilter);
    type(NumberFilter);
    type(OrderByFilter);
    type(UppercaseFilter);
  }
}
