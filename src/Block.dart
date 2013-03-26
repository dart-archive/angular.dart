part of angular;

class Block {

  var elements;
  var directives;

  Block(this.elements, this.directives);

  attach(Scope scope) {
    directives.forEach((directive) => directive.attach(scope));
  }
}
