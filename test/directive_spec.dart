library directive_spec;

import '_specs.dart';

main() => describe('DirectiveRegistry', () {
  DirectiveRegistry registry;
  beforeEach(inject((DirectiveRegistry r) {
    registry = r;
  }));

  it('should throw a useful error for directives missing metadata', () {
    expect(() {
    registry.register(NotADirective);
    }).toThrow('directive needs to have either @NgDirective or @NgComponent metadata');
  });
});

class NotADirective {}
