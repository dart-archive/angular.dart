library angular.directive;

import 'package:di/di.dart';
import 'dart:html' as dom;
import 'dart:async' as async;
import 'package:intl/intl.dart';
import 'package:angular/core/module.dart';
import 'package:angular/core/parser/parser.dart';
import 'package:angular/core_dom/module.dart';
import 'package:angular/utils.dart';

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
    value(NgADirective, null);
    value(NgBindDirective, null);
    value(NgBindTemplateDirective, null);
    value(NgBindHtmlDirective, null);
    value(NgClassDirective, null);
    value(NgClassOddDirective, null);
    value(NgClassEvenDirective, null);
    value(NgCloakDirective, null);
    value(NgHideDirective, null);
    value(NgIfDirective, null);
    value(NgUnlessDirective, null);
    value(NgIncludeDirective, null);
    value(NgPluralizeDirective, null);
    value(NgRepeatDirective, null);
    value(NgShalowRepeatDirective, null);
    value(NgShowDirective, null);
    value(InputTextLikeDirective, null);
    value(InputRadioDirective, null);
    value(InputCheckboxDirective, null);
    value(InputSelectDirective, null);
    value(OptionValueDirective, null);
    value(ContentEditableDirective, null);
    value(NgModel, null);
    value(NgSwitchDirective, null);
    value(NgSwitchWhenDirective, null);
    value(NgSwitchDefaultDirective, null);

    value(NgBooleanAttributeDirective, null);
    value(NgSourceDirective, null);
    value(NgAttributeDirective, null);

    value(NgEventDirective, null);
    value(NgStyleDirective, null);
    value(NgNonBindableDirective, null);
    value(NgTemplateDirective, null);
    value(NgForm, new NgNullForm());

    value(NgModelRequiredValidator, null);
    value(NgModelUrlValidator, null);
    value(NgModelEmailValidator, null);
    value(NgModelNumberValidator, null);
    value(NgModelPatternValidator, null);
    value(NgModelMinLengthValidator, null);
    value(NgModelMaxLengthValidator, null);
  }
}
