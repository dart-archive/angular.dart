part of angular.filter;

/**
 * Formats a number as text.
 *
 * If the input is not a number an empty string is returned.
 *
 *
 * Usage:
 *
 *     {{ number_expression | number[:fractionSize] }}
 *
 */
@NgFilter(name:'number')
class NumberFilter {

  Map<num, NumberFormat> nfs = new Map<num, NumberFormat>();

  /**
   *  [value]: the value to format
   *
   *  [fractionSize]: Number of decimal places to round the number to. If this
   *    is not provided then the fraction size is computed from the current
   *    locale's number formatting pattern. In the case of the default locale,
   *    it will be 3.
   */
  call(value, [fractionSize = null]) {
    if (value is String) value = double.parse(value);
    if (!(value is num)) return value;
    if (value.isNaN) return '';
    var nf = nfs[fractionSize];
    if (nf == null) {
      nf = new NumberFormat()..maximumIntegerDigits = 9;
      if (fractionSize != null) {
        nf.minimumFractionDigits = fractionSize;
        nf.maximumFractionDigits = fractionSize;
      }
      nfs[fractionSize] = nf;
    }
    return nf.format(value);
  }
}
