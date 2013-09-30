library angular.filter;

import 'dart:json';
import 'package:di/di.dart';
import '../filter.dart';

part 'uppercase.dart';
part 'lowercase.dart';
part 'json.dart';

void registerFilters(Module module) {
  module.type(UppercaseFilter);
  module.type(LowercaseFilter);
  module.type(JsonFilter);
}
