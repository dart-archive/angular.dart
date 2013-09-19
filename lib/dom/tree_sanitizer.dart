library angular.dom.tree_sanitizer;

import 'dart:html';

class NullTreeSanitizer implements NodeTreeSanitizer {
  void sanitizeTree(Node node) {}
}
