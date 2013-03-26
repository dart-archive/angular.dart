part of angular;

abstract class Directive {
  attach(Scope scope);
}

class DirectiveDef {
  Type directiveType;
  String value;
  Map blockTypes;

  DirectiveDef(this.directiveType, this.value, [this.blockTypes]);

  Boolean isComponent() => !!this.blockTypes;
}

