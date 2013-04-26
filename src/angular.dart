library angular;

import "dart:mirrors";
import 'dart:html' as dom;
import 'package:di/di.dart';

part 'Block.dart';
part 'BlockList.dart';
part 'BlockType.dart';
part 'Directive.dart';
part 'dom_utilities.dart';
part 'ExceptionHandler.dart';
part 'NodeCursor.dart';
part 'Scope.dart';
part 'Selector.dart';

ASSERT(condition) {
  if (!condition) {
    throw new AssertionError();
  }
}

num id = 0;

nextUid() {
  return '_${id++}}';
}
