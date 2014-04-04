/**
*
* Directives available in the main [angular.dart](#angular/angular) library.
*
* This package is imported for you as part of [angular.dart](#angular/angular),
* and lists all of the basic directives that are part of Angular.
*
*/
library angular.directive;

import 'package:di/di.dart';
import 'dart:html' as dom;
import 'package:intl/intl.dart';
import 'package:angular/core/annotation.dart';
import 'package:angular/core/module_internal.dart';
import 'package:angular/core/parser/parser.dart';
import 'package:angular/core_dom/module_internal.dart';
import 'package:angular/utils.dart';
import 'package:angular/change_detection/watch_group.dart';
import 'package:angular/change_detection/change_detection.dart';

part 'ng_a.dart';
part 'ng_bind.dart';
part 'ng_bind_html.dart';
part 'ng_bind_template.dart';
part 'ng_class.dart';
part 'ng_events.dart';
part 'ng_cloak.dart';
part 'ng_if.dart';
part 'ng_include.dart';
part 'ng_control.dart';
part 'ng_model.dart';
part 'ng_pluralize.dart';
part 'ng_repeat.dart';
part 'ng_template.dart';
part 'ng_show_hide.dart';
part 'ng_src_boolean.dart';
part 'ng_style.dart';
part 'ng_switch.dart';
part 'ng_non_bindable.dart';
part 'input_select.dart';
part 'ng_form.dart';
part 'ng_model_validators.dart';

class NgDirectiveModule extends Module {
  NgDirectiveModule() {
    value(NgA, null);
    value(NgBind, null);
    value(NgBindTemplate, null);
    value(NgBindHtml, null);
    factory(dom.NodeValidator, (_) =>
        new dom.NodeValidatorBuilder.common());
    value(NgClass, null);
    value(NgClassOdd, null);
    value(NgClassEven, null);
    value(NgCloak, null);
    value(NgHide, null);
    value(NgIf, null);
    value(NgUnless, null);
    value(NgInclude, null);
    value(NgPluralize, null);
    value(NgRepeat, null);
    value(NgShow, null);
    value(InputTextLike, null);
    value(InputDateLike, null);
    value(InputNumberLike, null);
    value(InputRadio, null);
    value(InputCheckbox, null);
    value(InputSelect, null);
    value(OptionValue, null);
    value(ContentEditable, null);
    value(NgBindTypeForDateLike, null);
    value(NgModel, null);
    value(NgValue, null);
    value(NgTrueValue, new NgTrueValue());
    value(NgFalseValue, new NgFalseValue());
    value(NgSwitch, null);
    value(NgSwitchWhen, null);
    value(NgSwitchDefault, null);

    value(NgBooleanAttribute, null);
    value(NgSource, null);
    value(NgAttribute, null);

    value(NgEvent, null);
    value(NgStyle, null);
    value(NgNonBindable, null);
    value(NgTemplate, null);
    value(NgControl, new NgNullControl());
    value(NgForm, new NgNullForm());

    value(NgModelRequiredValidator, null);
    value(NgModelUrlValidator, null);
    value(NgModelEmailValidator, null);
    value(NgModelNumberValidator, null);
    value(NgModelMaxNumberValidator, null);
    value(NgModelMinNumberValidator, null);
    value(NgModelPatternValidator, null);
    value(NgModelMinLengthValidator, null);
    value(NgModelMaxLengthValidator, null);
  }
}
