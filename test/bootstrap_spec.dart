library bootstrap_spec;

import '_specs.dart';

main() => describe('bootstrap', () {
  BodyElement body = window.document.querySelector('body');

  it('should default to whole page', () {
    body.innerHtml = '<div>{{"works"}}</div>';
    ngBootstrap();
    expect(body.innerHtml).toEqual('<div>works</div>');
  });

  it('should compile starting at ng-app node', () {
    body.setInnerHtml(
        '<div>{{ignor me}}<div ng-app ng-bind="\'works\'"></div></div>',
        treeSanitizer: new NullTreeSanitizer());
    ngBootstrap();
    expect(body.text).toEqual('{{ignor me}}works');
  });

  it('should compile starting at ng-app node', () {
    body.setInnerHtml(
        '<div>{{ignor me}}<div ng-bind="\'works\'"></div></div>',
        treeSanitizer: new NullTreeSanitizer());
    ngBootstrap(element:body.querySelector('div[ng-bind]'));
    expect(body.text).toEqual('{{ignor me}}works');
  });
});
