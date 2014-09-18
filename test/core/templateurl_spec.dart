library component_template_and_css_spec;

import '../_specs.dart';
import 'package:angular/core_dom/type_to_uri_mapper.dart';
import 'package:angular/core_dom/type_to_uri_mapper_dynamic.dart';
import 'package:angular/core_dom/resource_url_resolver.dart';

@Injectable()
class StaticTypeToUriMapper extends TypeToUriMapper {
  DynamicTypeToUriMapper dynamicMapper;

  StaticTypeToUriMapper(this.dynamicMapper);

  // to be rewritten for dynamic and static cases
  Uri uriForType(Type type) {
    if (type == _SimpleUrlComponent ||
        type == _HtmlAndCssComponent ||
        type == _ShadowComponentWithTranscludingComponent ||
        type == _TranscludingComponent ||
        type == _OnlyCssComponent) {
      return Uri.parse("package:test.angular.core_dom/templateUrlSpec.dart");
    }
    return dynamicMapper.uriForType(type);
  }
}

@Component(
    selector: 'simple-url',
    templateUrl: 'simple.html')
class _SimpleUrlComponent {
}

@Component(
    selector: 'html-and-css',
    templateUrl: 'simple.html',
    cssUrl: 'simple.css')
class _HtmlAndCssComponent {
}

@Component(
    selector: 'only-css',
    cssUrl: 'simple.css')
class _OnlyCssComponent {
}

@Component(
    selector: 'transcluding',
    cssUrl: 'transcluding.css',
    useShadowDom: false
)
class _TranscludingComponent {
}

@Component(
    selector: 'shadow-with-transcluding',
    template: "<transcluding/>",
    cssUrl: 'shadow.css',
    useShadowDom: true
)
class _ShadowComponentWithTranscludingComponent {
}


@Injectable()
class PrefixedUrlRewriter extends UrlRewriter {
  call(url) => "PREFIX:$url";
}

void shadowDomAndTranscluding(name, fn) {
  describe(name, (){
    describe('transcluding components', () {
      beforeEachModule((Module m) {
        m.bind(ComponentFactory, toImplementation: TranscludingComponentFactory);
      });
      fn();
    });

    describe('shadow dom components', () {
      beforeEachModule((Module m) {
        m.bind(ComponentFactory, toImplementation: ShadowDomComponentFactory);
      });
      fn();
    });
  });
}

_run({resolveUrls, staticMode}) {
  var prefix;
  if (!resolveUrls) prefix = "";
  else if (staticMode) prefix = "packages/test.angular.core_dom/";
  else prefix = TEST_SERVER_BASE_PREFIX + "test/core/";

  describe('template url resolveUrls=${resolveUrls}, mode=${staticMode ? 'static' : 'dynamic'}', () {
    TestBed _;

    beforeEach((TestBed tb) => _ = tb);

    beforeEachModule((Module m) {
      m.bind(ResourceResolverConfig, toValue:
      new ResourceResolverConfig.resolveRelativeUrls(resolveUrls));

      if (staticMode) {
        m.bind(TypeToUriMapper, toImplementation: StaticTypeToUriMapper);
        m.bind(DynamicTypeToUriMapper);
      }
    });

    afterEach((MockHttpBackend backend, CacheRegister cacheRegister) {
      backend.verifyNoOutstandingExpectation();
      backend.verifyNoOutstandingRequest();
      // clear our cache's between states since we're changing some fundamental
      // things (uri resolution) that makes the caches out of sync.
      cacheRegister.clear();
    });


    describe('loading with http rewriting', () {
      beforeEachModule((Module module) {
        module
          ..bind(_HtmlAndCssComponent)
          ..bind(UrlRewriter, toImplementation: PrefixedUrlRewriter);
      });

      it('should use the UrlRewriter for both HTML and CSS URLs', async((
          MockHttpBackend backend) {
        var element = _.compile('<div><html-and-css log>ignore</html-and-css><div>');

        backend
            ..flushGET('PREFIX:${prefix}simple.css').respond('.hello{}')
            ..flushGET('PREFIX:${prefix}simple.html').respond('<div log="SIMPLE">Simple!</div>');

        microLeap();

        expect(element).toHaveText('.hello{}Simple!');
        expect(element.children[0].shadowRoot).toHaveHtml(
            '<style>.hello{}</style><div log="SIMPLE">Simple!</div>'
        );
      }));
    });


    shadowDomAndTranscluding('template loading', () {
      beforeEachModule((Module module) {
        module
            ..bind(LogAttrDirective)
            ..bind(_SimpleUrlComponent);
      });

      it('should replace element with template from url', async((
          Logger log, MockHttpBackend backend) {
        var element = _.compile('<div><simple-url log>ignore</simple-url><div>');

        backend.flushGET('${prefix}simple.html').respond(200, '<div log="SIMPLE">Simple!</div>');
        microLeap();

        expect(element).toHaveText('Simple!');
        _.rootScope.apply();
        // Note: There is no ordering.  It is who ever comes off the wire first!
        expect(log.result()).toEqual('LOG; SIMPLE');
      }));

      it('should load template from URL once', async((
          Logger log, MockHttpBackend backend) {
        var element = _.compile(
            '<div>'
            '<simple-url log>ignore</simple-url>'
            '<simple-url log>ignore</simple-url>'
            '<div>');

        backend.flushGET('${prefix}simple.html').respond(200, '<div log="SIMPLE">Simple!</div>');
        microLeap();

        expect(element).toHaveText('Simple!Simple!');
        _.rootScope.apply();

        // Note: There is no ordering.  It is who ever comes off the wire first!
        expect(log.result()).toEqual('LOG; LOG; SIMPLE; SIMPLE');
      }));
    });

    describe('css loading (shadow dom components)', () {
      beforeEachModule((Module module) {
        module
          ..bind(LogAttrDirective)
          ..bind(_HtmlAndCssComponent)
          ..bind(_OnlyCssComponent);
      });

      it("should append the component's CSS to the shadow root", async((
          Logger log, MockHttpBackend backend) {
        var element = _.compile('<div><html-and-css log>ignore</html-and-css><div>');

        backend
            ..flushGET('${prefix}simple.css').respond(200, '.hello{}')
            ..flushGET('${prefix}simple.html').respond(200, '<div log="SIMPLE">Simple!</div>');

        microLeap();

        expect(element).toHaveText('.hello{}Simple!');
        expect(element.children[0].shadowRoot).toHaveHtml(
            '<style>.hello{}</style><div log="SIMPLE">Simple!</div>'
        );
        _.rootScope.apply();
        // Note: There is no ordering.  It is who ever comes off the wire first!
        expect(log.result()).toEqual('LOG; SIMPLE');
      }));
    });

    describe('css loading (transcluding components)', () {
      beforeEachModule((Module module) {
        module
          ..bind(_TranscludingComponent)
          ..bind(_ShadowComponentWithTranscludingComponent);
      });

      afterEach(() {
        document.head.querySelectorAll("style").forEach((s) => s.remove());
      });

      it("should append the component's CSS to the closest shadow root", async((
          MockHttpBackend backend) {
        backend
            ..whenGET('${prefix}shadow.css').respond(200, '.shadow{}')
            ..whenGET('${prefix}transcluding.css').respond(200, '.transcluding{}');

        final e = _.compile('<div><shadow-with-transcluding></shadow-with-transcluding><div>');
        backend.flush(1); _.rootScope.apply(); microLeap();
        backend.flush(1); _.rootScope.apply(); microLeap();

        expect(e.children[0].shadowRoot).toHaveHtml(
            '<style>.shadow{}</style><style>.transcluding{}</style><transcluding></transcluding>'
        );
      }));

      it("should append the component's CSS to head when no enclosing shadow roots", async((
           MockHttpBackend backend) {
        backend
            ..whenGET('${prefix}transcluding.css').respond(200, '.transcluding{}');

        final e = _.compile('<div><transcluding/><div>');
        backend.flush(); _.rootScope.apply(); microLeap();

        expect(document.head.text).toContain('.transcluding{}');
      }));
    });
  });
}

void main() {
  _run(resolveUrls: true, staticMode: true);
  _run(resolveUrls: true, staticMode: false);
  _run(resolveUrls: false, staticMode: true);
  _run(resolveUrls: false, staticMode: false);
}
