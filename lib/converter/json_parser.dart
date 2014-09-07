part of angular.converter;
/**
 * This parser is used for Http Service Interceptor to create and consume
 * Json Serialization
 */
@Injectable()
class JsonParser {
  /**
   * This function is called for serialization. It follow dart SDK JSON.encode toEncodable function signature
   */
  dynamic toEncodable(dynamic item) {
    if (item is DateTime) {
      return item.toIso8601String();
    }
    return item;
  }

  /**
   * Function Called for deserialization. This function is called for each item in Json.
   *
   * It follows dart SDK JSON.decode reviver function signature.
   *
   * The RegExp to parse is the closest possible to http://www.w3.org/TR/NOTE-datetime.
   *
   * Dart SDK have an unique behavior. It is able to parse dates with granularity less than the month
   * that explode the common strict dates. Example: 2000-01-32 becomes 2000-02-01, 2000-01-01T24:00 becomes 2000-01-02.
   *
   */

  dynamic reviver(var key, var value) {
    if (value is String) {
      // It use the same ReExp that DateTime in dart uses.
      RegExp dateIso8601 = new RegExp(r'^([+-]?\d{4,6})-?(\d\d)-?(\d\d)' // The day part.
      r'(?:[ T](\d\d)(?::?(\d\d)(?::?(\d\d)(.\d{1,6})?)?)?' // The time part
      r'( ?[zZ]| ?([-+])(\d\d)(?::?(\d\d))?)?)?$'); // The timezone part
      if (dateIso8601.hasMatch(value)) {
        return DateTime.parse(value);
      }
    }
    return value;
  }
}
