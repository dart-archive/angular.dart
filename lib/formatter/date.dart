part of angular.formatter_internal;

/**
 * Formats a date value to a string based on the requested format.
 *
 * Usage:
 *
 *     date_expression | date[:format]
 *
 * Here `format` may be specified explicitly, or by using one of the following predefined
 * localizable names:
 *
 *      FORMAT NAME     AS DEFINED FOR en_US             OUTPUT
 *     -------------   ----------------------   ---------------------------
 *      medium          MMM d, y h:mm:ss a       Sep 3, 2010 12:05:08 pm
 *      short           M/d/yy h:mm a            9/3/10 12:05 pm
 *      fullDate        EEEE, MMMM d, y          Friday, September 3, 2010
 *      longDate        MMMM d, y                September 3, 2010
 *      mediumDate      MMM d, y                 Sep 3, 2010
 *      shortDate       M/d/yy                   9/3/10
 *      mediumTime      h:mm:ss a                12:05:08 pm
 *      shortTime       h:mm a                   12:05 pm
 *
 *
 * For more on explicit formatting of dates and date syntax, see the documentation for the
 * [DartFormat class](https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/intl/intl.DateFormat).
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
   * Format a value as a date.
   *
   *  - `date`:   value to format as a date. If no timezone is specified in the string input,
   *     the time is considered to be in the local timezone.
   *  - `format`: Either a named format, or an explicit format specification.  If no format is
   *     specified, mediumDate is used.
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
