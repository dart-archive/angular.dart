library directive_spec;

import 'package:angular/directive.dart';
import '_specs.dart';

main() => describe('DirectiveRegistry', () {
  DirectiveRegistry registry;
  beforeEach(inject((DirectiveRegistry r) {
    registry = r;
  }));

  iit('should throw a useful error for directives missing metadata', () {
    expect(() {
    registry.register(NotADirective);
    }).toThrow('directive needs to have either @NgDirective or @NgComponent metadata');
  });
});

class NotADirective {}
