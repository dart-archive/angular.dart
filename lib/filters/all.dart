library angular.filter;

import 'package:di/di.dart';
import '../filter.dart';

part 'uppercase.dart';
part 'lowercase.dart';

void registerFilters(Module module) {
  module.type(UppercaseFilter);
  module.type(LowercaseFilter);
}
