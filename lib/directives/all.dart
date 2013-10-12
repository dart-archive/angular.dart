library angular.directive;

import 'package:di/di.dart';
import 'dart:html' as dom;
import 'dart:async' as async;
import 'dart:collection' show LinkedHashSet;
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
part 'select.dart';

void registerDirectives(Module module) {
  module.type(NgADirective);
  module.type(NgBindDirective);
  module.type(NgBindHtmlDirective);
  module.type(NgClassDirective);
  module.type(NgClassOddDirective);
  module.type(NgClassEvenDirective);
  module.type(NgCloakDirective);
  module.type(NgHideDirective);
  module.type(NgIfDirective);
  module.type(NgUnlessDirective);
  module.type(NgIncludeDirective);
  module.type(NgRepeatDirective);
  module.type(NgShowDirective);
  module.type(InputTextDirective);
  module.type(InputCheckboxDirective);
  module.type(NgModel);
  module.type(NgSwitchDirective);
  module.type(NgSwitchWhenDirective);
  module.type(NgSwitchDefaultDirective);
  module.type(SelectDirective);
  module.type(NgOptionsDirective);

  module.type(NgBooleanAttributeDirective);
  module.type(NgSourceDirective);

  module.type(NgEventDirective);
  module.type(NgStyleDirective);
  module.type(NgNonBindableDirective);
  module.type(NgTemplateDirective);
}
