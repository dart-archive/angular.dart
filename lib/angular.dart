library angular;

import "dart:mirrors";
import "dart:json" as json;
import 'dart:html' as dom;
import 'package:di/di.dart';
import 'debug.dart';

part 'block.dart';
part 'block_list.dart';
part 'block_type.dart';
part 'compiler.dart';
part 'directive.dart';
part 'directives/ng_bind.dart';
part 'directives/ng_shadow_dom.dart';
part 'directives/ng_repeat.dart';

part 'dom_utilities.dart';
part 'exception_handler.dart';
part 'mirrors.dart';
part 'node_cursor.dart';
part 'parser.dart';
part 'scope.dart';
part 'selector.dart';

ASSERT(condition) {
  if (!condition) {
    throw new AssertionError();
  }
}

num id = 0;

nextUid() {
  return '_${id++}';
}

noop() {}

toJson(obj) {
  try {
    return json.stringify(obj);
  } catch(e) {
    return "NOT-JSONABLE (see toJson(obj) in angular.dart)";
  }
}

angularModule(Module module) {
  module.value(ScopeDigestTTL, new ScopeDigestTTL(5));
}
