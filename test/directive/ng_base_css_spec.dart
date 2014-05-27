library ng_base_css_spec;

import '../_specs.dart';

@Component(
    selector: 'html-and-css',
    templateUrl: 'simple.html',
    cssUrl: 'simple.css')
class _HtmlAndCssComponent {}

@Component(
    selector: 'no-base-css',
    templateUrl: 'simple.html',
    cssUrl: 'simple.css',
    useNgBaseCss: false)
class _NoBaseCssComponent {}


main() => describe('NgBaseCss', () {
  beforeEachModule((Module module) {
    module
      ..bind(_HtmlAndCssComponent)
      ..bind(_NoBaseCssComponent);
  });

  it('should load css urls from ng-base-css', async((TestBed _, MockHttpBackend backend) {
    backend
      ..expectGET('base.css').respond(200, '.base{}')
      ..expectGET('simple.css').respond(200, '.simple{}')
      ..expectGET('simple.html').respond(200, '<div>Simple!</div>');

    var element = e('<div ng-base-css="base.css"><html-and-css>ignore</html-and-css></div>');
    _.compile(element);

    microLeap();
    backend.flush();
    microLeap();

    expect(element.children[0].shadowRoot).toHaveHtml(
            '<style>.base{}</style><style>.simple{}</style><div>Simple!</div>'
        );
  }));

  it('ng-base-css should overwrite parent ng-base-csses', async((TestBed _, MockHttpBackend backend) {
    backend
      ..expectGET('base.css').respond(200, '.base{}')
      ..expectGET('simple.css').respond(200, '.simple{}')
      ..expectGET('simple.html').respond(200, '<div>Simple!</div>');

    var element = e('<div ng-base-css="hidden.css"><div ng-base-css="base.css"><html-and-css>ignore</html-and-css></div></div>');
    _.compile(element);

    microLeap();
    backend.flush();
    microLeap();

    expect(element.children[0].children[0].shadowRoot).toHaveHtml(
        '<style>.base{}</style><style>.simple{}</style><div>Simple!</div>'
    );
  }));

  it('should respect useNgBaseCss', async((TestBed _, MockHttpBackend backend) {
    backend
      ..expectGET('simple.css').respond(200, '.simple{}')
      ..expectGET('simple.html').respond(200, '<div>Simple!</div>');

    var element = e('<div ng-base-css="base.css"><no-base-css>ignore</no-base-css></div>');
    _.compile(element);

    microLeap();
    backend.flush();
    microLeap();

    expect(element.children[0].shadowRoot).toHaveHtml(
        '<style>.simple{}</style><div>Simple!</div>'
    );
  }));

  describe('from injector', () {
    beforeEachModule((Module module) {
      module.bind(NgBaseCss, toValue: new NgBaseCss()..urls = ['injected.css']);
    });

    it('ng-base-css should be available from the injector', async((TestBed _, MockHttpBackend backend) {
      backend
        ..expectGET('injected.css').respond(200, '.injected{}')
        ..expectGET('simple.css').respond(200, '.simple{}')
        ..expectGET('simple.html').respond(200, '<div>Simple!</div>');

      var element = e('<div><html-and-css>ignore</html-and-css></div></div>');
      _.compile(element);

      microLeap();
      backend.flush();
      microLeap();

      expect(element.children[0].shadowRoot).toHaveHtml(
          '<style>.injected{}</style><style>.simple{}</style><div>Simple!</div>'
      );
    }));

    it('should respect useNgBaseCss', async((TestBed _, MockHttpBackend backend) {
      backend
        ..expectGET('simple.css').respond(200, '.simple{}')
        ..expectGET('simple.html').respond(200, '<div>Simple!</div>');

      var element = e('<div><no-base-css>ignore</no-base-css></div>');
      _.compile(element);

      microLeap();
      backend.flush();
      microLeap();

      expect(element.children[0].shadowRoot).toHaveHtml(
          '<style>.simple{}</style><div>Simple!</div>'
      );
    }));
  });
});
