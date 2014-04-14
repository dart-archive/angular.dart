library number_spec;

import '../_specs.dart';
import 'package:intl/intl.dart';

void main() {
  describe('number', () {
    var number;

    beforeEach((FormatterMap map, Injector injector) {
      number = injector.get(map[new Formatter(name: 'number')]);
    });


    it('should do basic formatter', () {
      expect(number(0, 0)).toEqual('0');
      expect(number(-999)).toEqual('-999');
      expect(number(123)).toEqual('123');
      expect(number(1234567)).toEqual('1,234,567');
      expect(number(1234)).toEqual('1,234');
      expect(number(1234.5678)).toEqual('1,234.568');
      expect(number(double.NAN)).toEqual('');
      expect(number("1234.5678")).toEqual('1,234.568');
      expect(number(1/0)).toEqual("∞");
      expect(number(1,        2)).toEqual("1.00");
      expect(number(.1,       2)).toEqual("0.10");
      expect(number(.01,      2)).toEqual("0.01");
      expect(number(.001,     3)).toEqual("0.001");
      expect(number(.0001,    3)).toEqual("0.000");
      expect(number(9,        2)).toEqual("9.00");
      expect(number(.9,       2)).toEqual("0.90");
      expect(number(.99,      2)).toEqual("0.99");
      expect(number(.999,     3)).toEqual("0.999");
      expect(number(.9999,    3)).toEqual("1.000");
      expect(number(1234.567, 0)).toEqual("1,235");
      expect(number(1234.567, 1)).toEqual("1,234.6");
      expect(number(1234.567, 2)).toEqual("1,234.57");
    });

    it('should formatter exponentially small numbers', () {
      expect(number(1e-50, 0)).toEqual('0');
      expect(number(1e-6, 6)).toEqual('0.000001');
      expect(number(1e-7, 6)).toEqual('0.000000');

      expect(number(-1e-50, 0)).toEqual('-0');
      expect(number(-1e-6, 6)).toEqual('-0.000001');
      expect(number(-1e-7, 6)).toEqual('-0.000000');
    });

    it('should accept various locales', () {
      expect(Intl.withLocale('de', () => number(1234.567, 2))).toEqual('1.234,57');
    });
  });
}
