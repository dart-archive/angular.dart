part of angular.formatter_internal;

/**
 * Formats a number as a currency (ie $1,234.56). When no currency symbol is
 * provided, '$' used.
 *
 *
 * Usage:
 *
 *     {{ numeric_expression | currency[:symbol[:leading]] }}
 *
 */
@Formatter(name:'currency')
class Currency implements Function {

  var _nfs = new Map<String, NumberFormat>();

  /**
   *  [value]: the value to format
   *
   *  [symbol]: Symbol to use.
   *
   *  [leading]: Symbol should be placed in front of the number
   */
  call(value, [symbol = r'$', leading = true]) {
    if (value is String) value = double.parse(value);
    if (value is! num) return value;
    if (value.isNaN) return '';
    var verifiedLocale = Intl.verifiedLocale(Intl.getCurrentLocale(), NumberFormat.localeExists);
    var nf = _nfs[verifiedLocale];
    if (nf == null) {
      nf = new NumberFormat();
      nf.minimumFractionDigits = 2;
      nf.maximumFractionDigits = 2;
      _nfs[verifiedLocale] = nf;
    }
    var neg = value < 0;
    if (neg) value = -value;
    var before = neg ? '(' : '';
    var after = neg ? ')' : '';
    return leading ?
        '$before$symbol${nf.format(value)}$after' :
        '$before${nf.format(value)}$symbol$after';
  }
}
