library object_parser_spec;
import '../_specs.dart';
import 'package:angular/object_parser/module.dart';

main() {
  describe('object_parser', () {
    describe('JsonParser reviver', () {
      it('should decode datetime iso formats without timezone', () {
        DateTime standardDate = new DateTime(1970, 1, 1);
        DateTime standardDateWithTime = new DateTime(1970, 1, 1, 12, 43);
        List<String> isoFormatDateWithTime = ['1970-01-01T12:43:00.000', '1970-01-01T12:43:00', '1970-01-01T12:43'];
        String isoFormatDate = '1970-01-01';
        JsonParser parser = new JsonParser();

        isoFormatDateWithTime.forEach((format) {
          expect(parser.reviver(null, format)).toEqual(standardDateWithTime);
        });
        expect(parser.reviver(null, isoFormatDate)).toEqual(standardDate);

        List malFormatedIsoDates = ['2000-30-30T12:34:5'];
        malFormatedIsoDates.forEach((format) {
          expect(parser.reviver(null, format)).toBe(format);
        });
      });

      it('should decode dates that colapse a sum', () {
        DateTime standardDate = new DateTime(1970, 1, 1, 1);
        JsonParser parser = new JsonParser();
        List smartDates = ['1969-12-31T24:59:60', '1969-12-31T24:60', '1969-12-31T25:00', '1969-12-32T01:00'];
        smartDates.forEach((_) {
          expect(parser.reviver(null, _)).toEqual(standardDate);
        });
      });

      it('should decode dates with UTC timezone', () {
        DateTime standardDateWithTime = new DateTime.utc(1970, 1, 1, 12, 43);
        JsonParser parser = new JsonParser();
        List<String> isoFormatUTC = ['1970-01-01T12:43:00.000Z', '1970-01-01T12:43:00Z', '1970-01-01T12:43Z'];
        isoFormatUTC.forEach((format) {
          expect(parser.reviver(null, format)).toEqual(standardDateWithTime);
        });
      });

      it('should decode dates with local timezone', () {
        DateTime standardDateWithTime = new DateTime.utc(1970, 1, 1, 11, 43);
        JsonParser parser = new JsonParser();
        List<String> isoFormatLocalOffset = ['1970-01-01T12:43:00.000+01:00', '1970-01-01T12:43:00+01:00',
         '1970-01-01T12:43+01:00', '1970-01-01T10:43-01:00', '1970-01-01T10:43-01', '1970-01-01T12:43+01',
         '1970-01-01T10:43-0100'];
        isoFormatLocalOffset.forEach((format) {
          expect(parser.reviver(null, format)).toEqual(standardDateWithTime);
        });
      });
    });

    describe('JsonParser toEncodable', () {
      it('should use toIso8601String() for DateTime', () {
        DateTime dateTime = new DateTime(1970, 1, 1);
        JsonParser parser = new JsonParser();
        expect(parser.toEncodable(dateTime)).toEqual(dateTime.toIso8601String());
      });
      it('should return the item if not date', () {
        String item = "Item";
        JsonParser parser = new JsonParser();
        expect(parser.toEncodable(item)).toEqual(item);
      });
    });

  });
}