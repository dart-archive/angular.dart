part of angular;

class NgDisabledAttrDirective {
  NgDisabledAttrDirective(dom.Node element, NodeAttrs attrs, Scope scope) {
    scope.$watch(attrs[this], (value, _, __) {
      element.disabled = value == null ? false : toBool(value);
    });
  }
}
