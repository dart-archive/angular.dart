part of angular.core.dom_internal;

@NgInjectableService()
class NullTreeSanitizer implements dom.NodeTreeSanitizer {
  void sanitizeTree(dom.Node node) {}
}
