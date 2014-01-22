library introspection_spec;

import '_specs.dart';

main() => describe('introspection', () {
  it('should retrieve ElementProbe', inject((TestBed _) {
    _.compile('<div ng-bind="true"></div>');
    ElementProbe probe = ngProbe(_.rootElement);
    expect(probe.injector.parent).toBe(_.injector);
    expect(ngInjector(_.rootElement).parent).toBe(_.injector);
    expect(probe.directives[0] is NgBindDirective).toBe(true);
    expect(ngDirectives(_.rootElement)[0] is NgBindDirective).toBe(true);
    expect(probe.scope).toBe(_.rootScope);
    expect(ngScope(_.rootElement)).toBe(_.rootScope);
  }));

  toHtml(List list) => list.map((e) => e.outerHtml).join('');

  it('should select elements using CSS selector', () {
    var div = new Element.html('<div><p><span></span></p></div>');
    var span = div.querySelector('span');
    var shadowRoot = span.createShadowRoot();
    shadowRoot.innerHtml = '<ul><li>stash</li><li>secret</li><ul>';

    expect(toHtml(ngQuery(div, 'li'))).toEqual('<li>stash</li><li>secret</li>');
    expect(toHtml(ngQuery(div, 'li', 'stash'))).toEqual('<li>stash</li>');
    expect(toHtml(ngQuery(div, 'li', 'secret'))).toEqual('<li>secret</li>');
    expect(toHtml(ngQuery(div, 'li', 'xxx'))).toEqual('');
  });

  it('should select elements in the root shadow root', () {
    var div = new Element.html('<div></div>');
    var shadowRoot = div.createShadowRoot();
    shadowRoot.innerHtml = '<ul><li>stash</li><li>secret</li><ul>';
    expect(toHtml(ngQuery(div, 'li'))).toEqual('<li>stash</li><li>secret</li>');
  });
});
