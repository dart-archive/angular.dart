part of angular.core.dom;

@NgInjectableService()
class NullTreeSanitizer implements dom.NodeTreeSanitizer {
  void sanitizeTree(dom.Node node) {}
}
