library ng_cloak_spec;

import '../_specs.dart';
import '../_test_bed.dart';

main() {
  describe('NgCloak', () {
    TestBed _;

    beforeEach(beforeEachTestBed((tb) => _ = tb));


    it('should get removed when an element is compiled', () {
      var element = $('<div ng-cloak></div>');
      expect(element.attr('ng-cloak')).toEqual('');
      _.compile(element);
      expect(element.attr('ng-cloak')).toBeNull();
    });


    it('should remove ngCloak class from a compiled element with attribute', () {
      var element = $('<div ng-cloak class="foo ng-cloak bar"></div>');

      expect(element.hasClass('foo')).toBe(true);
      expect(element.hasClass('ng-cloak')).toBe(true);
      expect(element.hasClass('bar')).toBe(true);

      _.compile(element);

      expect(element.hasClass('foo')).toBe(true);
      expect(element.hasClass('ng-cloak')).toBe(false);
      expect(element.hasClass('bar')).toBe(true);
    });


    // TODO(pavelgj): enable when/if class directive matching is implemented.
    xit('should remove ngCloak class from a compiled element', () {
      var element = $('<div class="foo ng-cloak bar"></div>');

      expect(element.hasClass('foo')).toBe(true);
      expect(element.hasClass('ng-cloak')).toBe(true);
      expect(element.hasClass('bar')).toBe(true);

      _.compile(element);

      expect(element.hasClass('foo')).toBe(true);
      expect(element.hasClass('ng-cloak')).toBe(false);
      expect(element.hasClass('bar')).toBe(true);
    });
  });
}
