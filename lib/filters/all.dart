library angular.filter;

import 'dart:json';
import 'package:intl/intl.dart';
import 'package:di/di.dart';
import '../filter.dart';

part 'currency.dart';
part 'date.dart';
part 'json.dart';
part 'lowercase.dart';
part 'number.dart';
part 'uppercase.dart';

void registerFilters(Module module) {
  module.type(CurrencyFilter);
  module.type(DateFilter);
  module.type(JsonFilter);
  module.type(LowercaseFilter);
  module.type(NumberFilter);
  module.type(UppercaseFilter);
}
