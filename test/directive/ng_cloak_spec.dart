library ng_cloak_spec;

import '../_specs.dart';

main() {
  describe('NgCloak', () {
    TestBed _;

    beforeEach((TestBed tb) => _ = tb);


    it('should get removed when an element is compiled', () {
      var element = e('<div ng-cloak></div>');
      expect(element.attributes['ng-cloak']).toEqual('');
      _.compile([element]);
      expect(element.attributes['ng-cloak']).toBeNull();
    });


    it('should remove ngCloak class from a compiled element with attribute', () {
      var element = e('<div ng-cloak class="foo ng-cloak bar"></div>');

      expect(element).toHaveClass('foo');
      expect(element).toHaveClass('ng-cloak');
      expect(element).toHaveClass('bar');

      _.compile(element);

      expect(element).toHaveClass('foo');
      expect(element).not.toHaveClass('ng-cloak');
      expect(element).toHaveClass('bar');
    });


    it('should remove ngCloak class from a compiled element', () {
      var element = e('<div class="foo ng-cloak bar"></div>');

      expect(element).toHaveClass('foo');
      expect(element).toHaveClass('ng-cloak');
      expect(element).toHaveClass('bar');

      _.compile(element);

      expect(element).toHaveClass('foo');
      expect(element).not.toHaveClass('ng-cloak');
      expect(element).toHaveClass('bar');
    });
  });
}
