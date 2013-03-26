part of angular;


class Compiler {
  Directives directives;
  Compiler(this.directives);

  BlockType compile(domElements) {
    var templateElements = cloneElements(domElements);
    var directivePositions = [];

    _compileBlock(new NodeCursor(domElements), new NodeCursor(templateElements),
        directivePositions);

    return new BlockType(templateElements, directivePositions);
  }

  _compileBlock(NodeCursor domCursor, NodeCursor templateCursor, directivePositions) {
    var directiveUsage = new DirectiveDef(directives['[bind]'], 'name');
    directivePositions.add(0);
    directivePositions.add(directiveUsage);
    directivePositions.add(null);
  }
}
