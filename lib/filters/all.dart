library angular.filter;

import 'dart:json';
import 'package:intl/intl.dart';
import 'package:di/di.dart';
import '../filter.dart';
import '../parser/parser_library.dart';
import '../scope.dart';

part 'currency.dart';
part 'date.dart';
part 'json.dart';
part 'limit_to.dart';
part 'lowercase.dart';
part 'number.dart';
part 'order_by.dart';
part 'uppercase.dart';

void registerFilters(Module module) {
  module.type(CurrencyFilter);
  module.type(DateFilter);
  module.type(JsonFilter);
  module.type(LimitToFilter);
  module.type(LowercaseFilter);
  module.type(NumberFilter);
  module.type(OrderByFilter);
  module.type(UppercaseFilter);
}
