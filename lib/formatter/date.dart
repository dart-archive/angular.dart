part of angular.formatter_internal;

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
@Formatter(name:'date')
class Date implements Function {
  static final _MAP = const <String, String> {
    'medium':     'MMM d, y h:mm:ss a',
    'short':      'M/d/yy h:mm a',
    'fullDate':   'EEEE, MMMM d, y',
    'longDate':   'MMMM d, y',
    'mediumDate': 'MMM d, y',
    'shortDate':  'M/d/yy',
    'mediumTime': 'h:mm:ss a',
    'shortTime':  'h:mm a',
  };

  var _dfs = new Map<String, Map<String, DateFormat>>();

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
  dynamic call(Object date, [String format = 'mediumDate']) {
    if (date == '' || date == null) return date;
    if (date is String) date = DateTime.parse(date);
    if (date is num) date = new DateTime.fromMillisecondsSinceEpoch(date);
    if (date is! DateTime) return date;
    if (_MAP.containsKey(format)) format = _MAP[format];
    var verifiedLocale = Intl.verifiedLocale(Intl.getCurrentLocale(), DateFormat.localeExists);
    _dfs.putIfAbsent(verifiedLocale, () => new Map<String, DateFormat>());
    var df = _dfs[verifiedLocale][format];
    if (df == null) {
      df = new DateFormat(format);
      _dfs[verifiedLocale][format] = df;
    }
    return df.format(date);
  }
}
