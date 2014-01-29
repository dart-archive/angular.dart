part of angular.directive;

/**
 * ## Overview
 * `ngPluralize` is a directive that displays messages according to locale rules.
 *
 * You configure ngPluralize directive by specifying the mappings between plural
 * categories and the strings to be displayed.
 *
 * ## Plural categories and explicit number rules
 * The available plural categories are:
 * * "zero",
 * * "one",
 * * "two",
 * * "few",
 * * "many",
 * * "other".
 *
 * While a plural category may match many numbers, an explicit number rule can
 * only match one number. For example, the explicit number rule for "3" matches
 * the number 3. There are examples of plural categories and explicit number
 * rules throughout the rest of this documentation.
 *
 * ## Configuring ngPluralize
 * You configure ngPluralize by providing 2 attributes: `count` and `when`.
 * You can also provide an optional attribute, `offset`.
 *
 * The value of the `count` attribute can be either a string or an expression;
 * these are evaluated on the current scope for its bound value.
 *
 * The `when` attribute specifies the mappings between plural categories and the
 * actual string to be displayed. The value of the attribute should be a JSON
 * object.
 *
 * The following example shows how to configure ngPluralize:
 *
 *    <ng-pluralize count="personCount"
 *                  when="{'0': 'Nobody is viewing.',
 *                         'one': '1 person is viewing.',
 *                         'other': '{} people are viewing.'}">
 *    </ng-pluralize>
 *
 * In the example, `"0: Nobody is viewing."` is an explicit number rule. If you
 * did not specify this rule, 0 would be matched to the "other" category and
 * "0 people are viewing" would be shown instead of "Nobody is viewing". You can
 * specify an explicit number rule for other numbers, for example 12, so that
 * instead of showing "12 people are viewing", you can show "a dozen people are
 * viewing".
 *
 * You can use a set of closed braces (`{}`) as a placeholder for the number
 * that you want substituted into pluralized strings. In the previous example,
 * Angular will replace `{}` with `{{personCount}}`. The closed braces `{}` is a
 * placeholder {{numberExpression}}.
 *
 * ## Configuring ngPluralize with offset
 * The `offset` attribute allows further customization of pluralized text, which
 * can result in a better user experience. For example, instead of the message
 * "4 people are viewing this document", you might display "John, Kate and 2
 * others are viewing this document". The offset attribute allows you to offset
 * a number by any desired value.
 *
 * Let's take a look at an example:
 *
 *    <ng-pluralize count="personCount" offset=2
 *                  when="{'0': 'Nobody is viewing.',
 *                         '1': '{{person1}} is viewing.',
 *                         '2': '{{person1}} and {{person2}} are viewing.',
 *                         'one': '{{person1}}, {{person2}} and one other person are viewing.',
 *                         'other': '{{person1}}, {{person2}} and {} other people are viewing.'}">
 *    </ng-pluralize>
 *
 * Notice that we are still using two plural categories(one, other), but we added
 * three explicit number rules 0, 1 and 2.
 * When one person, perhaps John, views the document, "John is viewing" will be
 * shown. When three people view the document, no explicit number rule is found,
 * so an offset of 2 is taken off 3, and Angular uses 1 to decide the plural
 * category. In this case, plural category 'one' is matched and "John, Marry and
 * one other person are viewing" is shown.
 *
 * Note that when you specify offsets, you must provide explicit number rules
 * for numbers from 0 up to and including the offset. If you use an offset of 3,
 * for example, you must provide explicit number rules for 0, 1, 2 and 3. You
 * must also provide plural strings for at least the "other" plural category.
 */
@NgDirective(
    selector: 'ng-pluralize',
    map: const { 'count': '=>count' })
@NgDirective(
    selector: '[ng-pluralize]',
    map: const { 'count': '=>count' })
class NgPluralizeDirective {
  final dom.Element element;
  final Scope scope;
  final Interpolate interpolate;
  int offset;
  Map<String, String> discreteRules = new Map();
  Map<Symbol, String> categoryRules = new Map();
  static final RegExp IS_WHEN = new RegExp(r'^when-(minus-)?.');

  NgPluralizeDirective(this.scope, this.element, this.interpolate,
                       NodeAttrs attributes) {
    Map<String, String> whens = attributes['when'] == null ?
        {} :
        scope.$eval(attributes['when']);
    offset = attributes['offset'] == null ? 0 : int.parse(attributes['offset']);

    element.attributes.keys.where((k) => IS_WHEN.hasMatch(k)).forEach((k) {
      var ruleName = k.replaceFirst('when-', '').replaceFirst('minus-', '-');
      whens[ruleName] = element.attributes[k];
    });

    if (whens['other'] == null) {
      throw "ngPluralize error! The 'other' plural category must always be "
          "specified";
    }

    whens.forEach((k, v) {
      if (['zero', 'one', 'two', 'few', 'many', 'other'].contains(k)) {
        this.categoryRules[new Symbol(k.toString())] = v;
      } else {
        this.discreteRules[k.toString()] = v;
      }
    });
  }

  set count(value) {
    if (value is! num) {
      try {
        value = int.parse(value);
      } catch(e) {
        try {
          value = double.parse(value);
        } catch(e) {
          element.text = '';
          return;
        }
      }
    }

    String stringValue = value.toString();
    int intValue = value.toInt();

    if (discreteRules[stringValue] != null) {
      _setAndWatch(discreteRules[stringValue]);
    } else {
      intValue -= offset;
      var exp = Function.apply(Intl.plural, [intValue], categoryRules);
      if (exp != null) {
        exp = exp.replaceAll(r'{}', (value - offset).toString());
        _setAndWatch(exp);
      }
    }
  }

  _setAndWatch(expression) {
    var interpolation = interpolate(expression);
    interpolation.setter = (text) => element.text = text;
    interpolation.setter(expression);
    scope.$watchSet(interpolation.watchExpressions, interpolation.call);
  }
}
