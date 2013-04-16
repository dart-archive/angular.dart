import 'package:unittest/unittest.dart';
import 'jasmineSyntax.dart';
import '../src/angular.dart';
import 'dart:html';

class BindDirective extends Directive {
  var element;
  var value;

  BindDirective(this.element, this.value) {
    print(element);
  }

  attach(scope) {
    scope.$watch(value, (value) => element.text = value);
  }
}

main() {
  describe('compiler', () {
    Compiler compiler;
    Directives directives;
    Element element;
    Scope scope;

    beforeEach(() {
      scope = new Scope();
      directives = new Directives();
      compiler = new Compiler(directives);
      element = new BodyElement();
    });

    it('should perform basic binding', () {
      directives.register('[bind]', (e, v) => new BindDirective(e, v));

      element.innerHtml = '<span bind="name"></span>';
      BlockType blockType = compiler.compile(element.children);
      Block block = blockType.instantiate(element.children);
      block.attach(scope);
      scope['name'] = 'foo';
      scope.$apply();

      expect(element.text, equals('foo'));
    });
  });
}


