library angular.filter;

import 'dart:json';
import 'package:intl/intl.dart';
import 'package:di/di.dart';
import '../core/module.dart';
import '../core/parser/parser_library.dart';

part 'currency.dart';
part 'date.dart';
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
    type(JsonFilter);
    type(LimitToFilter);
    type(LowercaseFilter);
    type(NumberFilter);
    type(OrderByFilter);
    type(UppercaseFilter);
  }
}
