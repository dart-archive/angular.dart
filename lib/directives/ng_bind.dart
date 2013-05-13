part of angular;

// TODO(deboer)
// Move this helper classes somewhere else

class BindValue {
  String value;
  BindValue() : this.value = "ERROR DEFAULT";
  BindValue.fromString(this.value);
}

class NgBindAttrDirective  {

  List<dom.Node> nodeList;
  BindValue value;

  NgBindAttrDirective(List<dom.Node> this.nodeList, BindValue this.value) {
  }

  attach(Scope scope) {
    scope.$watch(value.value, (value) { nodeList[0].text = value; });
  }

}
