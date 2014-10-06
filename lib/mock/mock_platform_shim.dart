part of angular.mock;

/**
 * The mock platform exists to smooth out browser differences for tests that
 * do not wish to take browser variance into account. This mock provides null
 * implementations of all operations, but they can be overwritten if needed.
 */
@Injectable()
class MockWebPlatformShim implements PlatformJsBasedShim, DefaultPlatformShim {
  bool shimRequired = false;

  Function cssCompiler = (css, {String selector}) => css;
  Function shimDom = (root, String selector) {};

  String shimCss(String css, { String selector, String cssUrl }) =>
      cssCompiler(css, selector: selector);

  void shimShadowDom(Element root, String selector) {
    shimDom(root, selector);
  }
}