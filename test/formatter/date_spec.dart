library date_spec;

import '../_specs.dart';
import 'package:intl/intl.dart';

void main() {
  describe('date', () {
    var morning = DateTime.parse('2010-09-03T07:05:08.008Z'); //7am
    var noon = DateTime.parse('2010-09-03T12:05:08.012Z'); //12pm
    var midnight = DateTime.parse('2010-09-03T12:05:08.123Z'); //12am
    var earlyDate = DateTime.parse('0001-09-03T05:05:08.000Z');

    var date;

    beforeEach((FormatterMap map, Injector injector) {
      date = injector.get(map['date']);
    });

    it('should ignore falsy inputs', () {
      expect(date(null)).toBeNull();
      expect(date('')).toEqual('');
    });

    it('should do basic formatter', () {
      expect(date(noon)).toEqual(date(noon, 'mediumDate'));
    });

    it('should accept various format strings', () {
      expect(date(morning, "yy-MM-dd HH:mm:ss")).toEqual('10-09-03 07:05:08');
      expect(date(morning, "yy-MM-dd HH:mm:ss.sss"))
          .toEqual('10-09-03 07:05:08.008');
    });

    it('should accept default formats', () {
      expect(date(noon, "medium")).toEqual('Sep 3, 2010 12:05:08 PM');
      expect(date(noon, "short")).toEqual('9/3/10 12:05 PM');
      expect(date(noon, "fullDate")).toEqual('Friday, September 3, 2010');
      expect(date(noon, "longDate")).toEqual('September 3, 2010');
      expect(date(noon, "mediumDate")).toEqual('Sep 3, 2010');
      expect(date(noon, "shortDate")).toEqual('9/3/10');
      expect(date(noon, "mediumTime")).toEqual('12:05:08 PM');
      expect(date(noon, "shortTime")).toEqual('12:05 PM');
    });

    it('should use cache without any error', () {
      date(noon, "shortTime");
      date(noon, "shortTime");
    });

    it('should accept various locales', async(() {
      // Angular's pubspec for intl spans versions with breaking changes.  This
      // is ok for Angular, because they are not breaking changes for us (e.g.
      // date formatting changes would be breaking changes, but CLDR updates are
      // not.)  The tests below use SV and FR which are mostly stable across
      // different versions of the intl package (as opposed to DE which received
      // CLDR updates.)
      expect(Intl.withLocale('sv', () => date(noon, "medium")))
          .toEqual('3 sep 2010 12:05:08');
      expect(Intl.withLocale('fr', () => date(noon, "medium")))
          .toEqual('3 sept. 2010 12:05:08');
    }));
  });
}
