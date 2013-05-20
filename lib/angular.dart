library angular;

import "dart:mirrors";
import 'dart:html' as dom;
import 'package:di/di.dart';
import 'debug.dart';

part 'block.dart';
part 'block_list.dart';
part 'block_type.dart';
part 'compiler.dart';
part 'directive.dart';
part 'directives/ng_bind.dart';
part 'dom_utilities.dart';
part 'exception_handler.dart';
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
