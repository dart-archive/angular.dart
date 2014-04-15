library core_directive_spec;

import '../_specs.dart';
import 'package:angular/application_factory.dart';

void main() {
  describe('DirectiveMap on AbstractNgAttrAnnotation', () {

    beforeEachModule((Module module) {
      module..type(AnnotatedIoComponent);
    });

    it('should extract attr map from annotated component', (DirectiveMap directives) {
      var annotations = directives.annotationsFor(AnnotatedIoComponent);
      expect(annotations.length).toEqual(1);
      expect(annotations[0] is NgComponent).toBeTruthy();

      NgComponent annotation = annotations[0];
      expect(annotation.selector).toEqual('annotated-io');
      expect(annotation.visibility).toEqual(NgDirective.LOCAL_VISIBILITY);
      expect(annotation.exportExpressions).toEqual(['exportExpressions']);
      expect(annotation.module).toEqual(AnnotatedIoComponent.module);
      expect(annotation.template).toEqual('template');
      expect(annotation.templateUrl).toEqual('templateUrl');
      expect(annotation.cssUrls).toEqual(['cssUrls']);
      expect(annotation.publishAs).toEqual('ctrl');
      expect(annotation.map).toEqual({
          'foo': '=>foo',
          'attr': '@attr',
          'expr': '<=>expr',
          'expr-one-way': '=>exprOneWay',
          'expr-one-way-one-shot': '=>!exprOneWayOneShot',
          'callback': '&callback',
          'expr-one-way2': '=>exprOneWay2',
          'expr-two-way': '<=>exprTwoWay'});
    });

    describe('exceptions', () {
      var baseModule;
      beforeEach(() {
        baseModule = new Module()
            ..type(DirectiveMap)
            ..type(DirectiveSelectorFactory)
            ..type(MetadataExtractor);
      });

      it('should throw when annotation is for existing mapping', () {
        var module = new Module()..type(Bad1Component);

        var injector = applicationFactory().addModule(module).createInjector();
        expect(() {
          injector.get(DirectiveMap);
        }).toThrow('Mapping for attribute foo is already defined (while '
                   'processing annotation for field foo of Bad1Component)');
      });

      it('should throw when annotated both getter and setter', () {
        var module = new Module()..type(Bad2Component);

        var injector = applicationFactory().addModule(module).createInjector();
        expect(() {
          injector.get(DirectiveMap);
        }).toThrow('Attribute annotation for foo is defined more than once '
                   'in Bad2Component');
      });
    });
  });

  describe('DirectiveMapping on NgTemplate', () {

    beforeEachModule((Module module) {
      module..type(AnnotatedTemplate);
    });

    it('should extract attr map from annotated template', (DirectiveMap directives) {
      var annotations = directives.annotationsFor(AnnotatedTemplate);
      expect(annotations.length).toEqual(1);
      expect(annotations[0] is NgTemplate).toBeTruthy();

      NgTemplate annotation = annotations[0];
      expect(annotation.selector).toEqual('template');
      expect(annotation.mapping).toEqual('=>expression');
    });

    describe('exceptions', () {
      var baseModule;
      beforeEach(() {
        baseModule = new Module()
          ..type(DirectiveMap)
          ..type(DirectiveSelectorFactory)
          ..type(MetadataExtractor);
      });

      it('should throw when annotation is for existing mapping', () {
        var module = new Module()..type(Bad1Template);

        var injector = applicationFactory().addModule(module).createInjector();
        expect(() {
          injector.get(DirectiveMap);
        }).toThrow('The mapping must be defined either in the @NgTemplate '
                   'annotation or on an attribute');
      });

      it('should throw when multiple attribute annotations are added', () {
        var module = new Module()..type(Bad2Template);

        var injector = applicationFactory().addModule(module).createInjector();
        expect(() {
          injector.get(DirectiveMap);
        }).toThrow('There could be only one attribute annotation for @NgTemplate'
                   ' annotated classes, 2 found on expression, expression2');
      });
    });
  });

}

class NullParser implements Parser {
  call(x) {
    throw "NullParser";
  }
}

@NgTemplate(
    selector: 'template',
    mapping: '=>expression')
class AnnotatedTemplate {
  var expression;
}

@NgTemplate(
    selector: 'badTemplate1',
    mapping: '=>expression')
class Bad1Template {
  var expression;

  // The mapping is already defined in the @NgTemplate annotation
  @NgOneWay('epxression2')
  var expression2;
}

@NgTemplate(selector: 'badTemplate2')
class Bad2Template {
  // The mapping is defined twice
  @NgOneWay('epxression')
  var expression;

  @NgOneWay('epxression2')
  var expression2;
}

@NgComponent(
    selector: 'annotated-io',
    template: 'template',
    templateUrl: 'templateUrl',
    cssUrl: const ['cssUrls'],
    publishAs: 'ctrl',
    module: AnnotatedIoComponent.module,
    visibility: NgDirective.LOCAL_VISIBILITY,
    exportExpressions: const ['exportExpressions'],
    map: const {
      'foo': '=>foo'})
class AnnotatedIoComponent {
  static module() => new Module()..factory(String,
      (i) => i.get(AnnotatedIoComponent),
      visibility: NgDirective.LOCAL_VISIBILITY);

  AnnotatedIoComponent(Scope scope) {
    scope.rootScope.context['ioComponent'] = this;
  }

  String foo;

  @NgAttr('attr')
  String attr;

  @NgTwoWay('expr')
  String expr;

  @NgOneWay('expr-one-way')
  String exprOneWay;

  @NgOneWayOneTime('expr-one-way-one-shot')
  String exprOneWayOneShot;

  @NgCallback('callback')
  Function callback;

  @NgOneWay('expr-one-way2')
  set exprOneWay2(val) {}

  @NgTwoWay('expr-two-way')
  get exprTwoWay => null;
  set exprTwoWay(val) {}
}

@NgComponent(
    selector: 'bad1',
    template: r'<content></content>',
    map: const {'foo': '=>foo'})
class Bad1Component {
  // The mapping for foo is already defined in @NgComponent
  @NgOneWay('foo')
  String foo;
}

@NgComponent(
    selector: 'bad2',
    template: r'<content></content>')
class Bad2Component {
  // The mapping for foo is defined on two different attribute
  @NgOneWay('foo')
  get foo => null;

  @NgOneWay('foo')
  set foo(val) {}
}
