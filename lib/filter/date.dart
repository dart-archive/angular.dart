part of angular.filter;

/**
 * Formats date to a string based on the requested format.
 * See Dart http://api.dartlang.org/docs/releases/latest/intl/DateFormat.html
 * for full formating options.
 *
 * - `medium`: equivalent to `MMM d, y h:mm:ss a` for en_US locale (e.g. Sep 3, 2010 12:05:08 pm)
 * - `short`: equivalent to `M/d/yy h:mm a` for en_US locale (e.g. 9/3/10 12:05 pm)
 * - `fullDate`: equivalent to `EEEE, MMMM d, y` for en_US locale (e.g. Friday, September 3, 2010)
 * - `longDate`: equivalent to `MMMM d, y` for en_US locale (e.g. September 3, 2010)
 * - `mediumDate`: equivalent to `MMM d, y` for en_US locale (e.g. Sep 3, 2010)
 * - `shortDate`: equivalent to `M/d/yy` for en_US locale (e.g. 9/3/10)
 * - `mediumTime`: equivalent to `h:mm:ss a` for en_US locale (e.g. 12:05:08 pm)
 * - `shortTime`: equivalent to `h:mm a` for en_US locale (e.g. 12:05 pm)
 *
 *
 * Usage:
 *
 *     {{ date_expression | date[:format] }}
 *
 */
@NgFilter(name:'date')
class DateFilter {
  static Map<String, String> MAP = {
    'medium':     'MMM d, y h:mm:ss a',
    'short':      'M/d/yy h:mm a',
    'fullDate':   'EEEE, MMMM d, y',
    'longDate':   'MMMM d, y',
    'mediumDate': 'MMM d, y',
    'shortDate':  'M/d/yy',
    'mediumTime': 'h:mm:ss a',
    'shortTime':  'h:mm a',
  };

  Map<num, NumberFormat> nfs = new Map<num, NumberFormat>();

  /**
   *  [date]: Date to format either as Date object, milliseconds
   *    ([string] or [num]) or various ISO 8601 datetime string formats
   *    (e.g. `yyyy-MM-ddTHH:mm:ss.SSSZ` and its shorter versions like
   *    `yyyy-MM-ddTHH:mmZ`, `yyyy-MM-dd` or `yyyyMMddTHHmmssZ`). If no
   *    timezone is specified in the string input, the time is considered to
   *    be in the local timezone.
   *
   *  [format]: Formatting rules (see Description). If not specified,
   *    mediumDate is used
   *
   */
  call(date, [format = r'mediumDate']) {
    if (date == '' || date == null) return date;
    if (date is String) date = DateTime.parse(date);
    if (date is num) date = new DateTime.fromMillisecondsSinceEpoch(date);
    if (date is! DateTime) return date;
    var nf = nfs[format];
    if (nf == null) {
      if (MAP.containsKey(format)) {
        format = MAP[format];
      }
      nf = new DateFormat(format);
    }
    return nf.format(date);
  }
}
