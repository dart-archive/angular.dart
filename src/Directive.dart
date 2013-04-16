part of angular;

abstract class Directive {
  attach(Scope scope);
}

class DirectiveDef {
  DirectiveFactory factory;
  String value;
  Map blockTypes;

  DirectiveDef(this.factory, this.value, [this.blockTypes]);

  Boolean isComponent() => !!this.blockTypes;
}

