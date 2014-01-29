part of angular.filter;

/**
 * Formats a number as a currency (ie $1,234.56). When no currency symbol is
 * provided, '$' used.
 *
 *
 * Usage:
 *
 *     {{ number_expression | number[:fractionSize] }}
 *
 */
@NgFilter(name:'currency')
class CurrencyFilter {
  NumberFormat nf = new NumberFormat();

  CurrencyFilter() {
    nf.minimumFractionDigits = 2;
    nf.maximumFractionDigits = 2;
  }

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
    var neg = value < 0;
    if (neg) value = -value;
    var before = neg ? '(' : '';
    var after = neg ? ')' : '';
    return leading ?
        '$before$symbol${nf.format(value)}$after' :
        '$before${nf.format(value)}$symbol$after';
  }
}
