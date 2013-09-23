library angular.directive;

import 'package:di/di.dart';
import 'dart:html' as dom;
import 'dart:async' as async;
import '../dom/directive.dart';
import '../dom/block.dart';
import '../dom/block_factory.dart';
import '../dom/http.dart';
import '../parser/parser_library.dart';
import '../dom/template_cache.dart';
import '../scope.dart';
import '../utils.dart';

part 'ng_a.dart';
part 'ng_bind.dart';
part 'ng_bind_html.dart';
part 'ng_class.dart';
part 'ng_events.dart';
part 'ng_cloak.dart';
part 'ng_if.dart';
part 'ng_include.dart';
part 'ng_model.dart';
part 'ng_repeat.dart';
part 'ng_template.dart';
part 'ng_show_hide.dart';
part 'ng_src_boolean.dart';
part 'ng_style.dart';
part 'ng_switch.dart';
part 'ng_non_bindable.dart';
part 'input_select.dart';

void registerDirectives(Module module) {
  module.value(NgADirective, null);
  module.value(NgBindDirective, null);
  module.value(NgBindHtmlDirective, null);
  module.value(NgClassDirective, null);
  module.value(NgClassOddDirective, null);
  module.value(NgClassEvenDirective, null);
  module.value(NgCloakDirective, null);
  module.value(NgHideDirective, null);
  module.value(NgIfDirective, null);
  module.value(NgUnlessDirective, null);
  module.value(NgIncludeDirective, null);
  module.value(NgRepeatDirective, null);
  module.value(NgShowDirective, null);
  module.value(InputTextDirective, null);
  module.value(InputCheckboxDirective, null);
  module.value(InputSelectDirective, null);
  module.value(OptionValueDirective, null);
  module.value(NgModel, null);
  module.value(NgSwitchDirective, null);
  module.value(NgSwitchWhenDirective, null);
  module.value(NgSwitchDefaultDirective, null);

  module.value(NgBooleanAttributeDirective, null);
  module.value(NgSourceDirective, null);

  module.value(NgEventDirective, null);
  module.value(NgStyleDirective, null);
  module.value(NgNonBindableDirective, null);
  module.value(NgTemplateDirective, null);
}
