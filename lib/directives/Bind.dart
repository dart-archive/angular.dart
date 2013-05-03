part of angular;

// TODO(deboer)
// Move these helper classes somewhere else

class TextAccessor {
  List<dom.Node> jquery;
  TextAccessor(List<dom.Node> this.jquery);

  call(String value) {
    jquery[0].text = value;
  }
}

class BindValue {
  String value;
  BindValue() : this.value = "ERROR DEFAULT";
  BindValue.fromString(this.value);
}

class BindDirective  {
  static String name = ['bind'];

  TextAccessor text;
  BindValue value;

  BindDirective(TextAccessor this.text, BindValue this.value) {
    dump('BIND');
  }

  attach(Scope scope) {
    dump('BIND attach');
    scope.$watch(value.value, text);
  }

}
