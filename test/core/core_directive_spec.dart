library core_directive_spec;

import '../_specs.dart';

main() => describe('DirectiveMap', () {

  beforeEach(module((Module module) {
    module..type(AnnotatedIoComponent);
  }));

  it('should extract attr map from annotated component', inject((DirectiveMap directives) {
    var annotations = directives.annotationsFor(AnnotatedIoComponent);
    expect(annotations.length).toEqual(1);
    expect(annotations[0] is NgComponent).toBeTruthy();

    NgComponent annotation = annotations[0];
    expect(annotation.selector).toEqual('annotated-io');
    expect(annotation.visibility).toEqual(NgDirective.LOCAL_VISIBILITY);
    expect(annotation.exportExpressions).toEqual(['exportExpressions']);
    expect(annotation.publishTypes).toEqual([String]);
    expect(annotation.template).toEqual('template');
    expect(annotation.templateUrl).toEqual('templateUrl');
    expect(annotation.cssUrls).toEqual(['cssUrls']);
    expect(annotation.applyAuthorStyles).toEqual(true);
    expect(annotation.resetStyleInheritance).toEqual(true);
    expect(annotation.publishAs).toEqual('ctrl');
    expect(annotation.map).toEqual({
      'foo': '=>foo',
      'attr': '@attr',
      'expr': '<=>expr',
      'expr-one-way': '=>exprOneWay',
      'expr-one-way-one-shot': '=>!exprOneWayOneShot',
      'callback': '&callback',
      'expr-one-way2': '=>exprOneWay2',
      'expr-two-way': '<=>exprTwoWay'
    });
  }));

  describe('exceptions', () {
    it('should throw when annotation is for existing mapping', () {
      var module = new Module()
          ..type(DirectiveMap)
          ..type(Bad1Component)
          ..type(MetadataExtractor)
          ..type(FieldMetadataExtractor);

      var injector = new DynamicInjector(modules: [module]);
      expect(() {
        injector.get(DirectiveMap);
      }).toThrow('Mapping for attribute foo is already defined (while '
                 'processing annottation for field foo of Bad1Component)');
    });

    it('should throw when annotated both getter and setter', () {
        var module = new Module()
            ..type(DirectiveMap)
            ..type(Bad2Component)
            ..type(MetadataExtractor)
            ..type(FieldMetadataExtractor);

      var injector = new DynamicInjector(modules: [module]);
      expect(() {
        injector.get(DirectiveMap);
      }).toThrow('Attribute annotation for foo is defined more than once '
                 'in Bad2Component');
    });
  });
});

@NgComponent(
    selector: 'annotated-io',
    template: 'template',
    templateUrl: 'templateUrl',
    cssUrl: const ['cssUrls'],
    applyAuthorStyles: true,
    resetStyleInheritance: true,
    publishAs: 'ctrl',
    publishTypes: const [String],
    visibility: NgDirective.LOCAL_VISIBILITY,
    exportExpressions: const ['exportExpressions'],
    map: const {
      'foo': '=>foo'
    })
class AnnotatedIoComponent {
  AnnotatedIoComponent(Scope scope) {
    scope.rootScope.context['ioComponent'] = this;
  }

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
    map: const {
      'foo': '=>foo'
    })
class Bad1Component {
  @NgOneWay('foo')
  String foo;
}

@NgComponent(
    selector: 'bad2',
    template: r'<content></content>')
class Bad2Component {
  @NgOneWay('foo')
  get foo => null;

  @NgOneWay('foo')
  set foo(val) {}
}
