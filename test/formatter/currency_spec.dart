library curerncy_spec;

import '../_specs.dart';
import 'package:intl/intl.dart';

void main() {
  describe('number', () {
    var currency;

    beforeEach((FormatterMap map, Injector injector) {
      currency = injector.get(map[new Formatter(name: 'currency')]);
    });


    it('should do basic currency filtering', () {
      expect(currency(0)).toEqual(r'$0.00');
      expect(currency(-999)).toEqual(r'($999.00)');
      expect(currency(1234.5678, r"USD$")).toEqual(r'USD$1,234.57');
    });


    it('should return empty string for non-numbers', () {
      expect(currency(null)).toEqual(null);
    });

    it('should handle zero and nearly-zero values properly', () {
      // This expression is known to yield 4.440892098500626e-16 instead of 0.0.
      expect(currency(1.07 + 1 - 2.07)).toEqual(r'$0.00');
      expect(currency(0.008)).toEqual(r'$0.01');
      expect(currency(0.003)).toEqual(r'$0.00');
    });

    it('should accept various locales', () {
      expect(Intl.withLocale('de', () => currency(0.008, '€', false))).toEqual(r'0,01€');
    });
  });
}
