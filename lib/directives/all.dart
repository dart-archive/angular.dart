library angular.directives.all;

import '../bootstrap.dart';

import "ng_mustache.dart";
import 'ng_bind.dart';
import 'ng_class.dart';
import 'ng_events.dart';
import 'ng_cloak.dart';
import 'ng_controller.dart';
import 'ng_disabled.dart';
import 'ng_hide.dart';
import 'ng_if.dart';
import 'ng_include.dart';
import 'ng_model.dart';
import 'ng_repeat.dart';
import 'ng_show.dart';
import 'ng_style.dart';

export "ng_mustache.dart";
export 'ng_bind.dart';
export 'ng_class.dart';
export 'ng_events.dart';
export 'ng_cloak.dart';
export 'ng_controller.dart';
export 'ng_disabled.dart';
export 'ng_hide.dart';
export 'ng_if.dart';
export 'ng_include.dart';
export 'ng_model.dart';
export 'ng_repeat.dart';
export 'ng_show.dart';
export 'ng_style.dart';


void registerDirectives(AngularModule module) {
  module.directive(NgTextMustacheDirective);
  module.directive(NgAttrMustacheDirective);
  module.directive(NgBindAttrDirective);
  module.directive(NgClassAttrDirective);
  module.directive(NgCloakAttrDirective);
  module.directive(NgControllerAttrDirective);
  module.directive(NgDisabledAttrDirective);
  module.directive(NgHideAttrDirective);
  module.directive(NgIfAttrDirective);
  module.directive(NgIncludeAttrDirective);
  module.directive(NgRepeatAttrDirective);
  module.directive(NgShowAttrDirective);
  module.directive(InputTextDirective);
  module.directive(InputCheckboxDirective);
  module.directive(NgModel);

  module.directive(NgBlurAttrDirective);
  module.directive(NgChangeAttrDirective);
  module.directive(NgClickAttrDirective);
  module.directive(NgContextMenuAttrDirective);
  module.directive(NgDragAttrDirective);
  module.directive(NgDragEndAttrDirective);
  module.directive(NgDragEnterAttrDirective);
  module.directive(NgDragLeaveAttrDirective);
  module.directive(NgDragOverAttrDirective);
  module.directive(NgDragStartAttrDirective);
  module.directive(NgDropAttrDirective);
  module.directive(NgFocusAttrDirective);
  module.directive(NgKeyDownAttrDirective);
  module.directive(NgKeyPressAttrDirective);
  module.directive(NgKeyUpAttrDirective);
  module.directive(NgMouseDownAttrDirective);
  module.directive(NgMouseEnterAttrDirective);
  module.directive(NgMouseLeaveAttrDirective);
  module.directive(NgMouseMoveAttrDirective);
  module.directive(NgMouseOutAttrDirective);
  module.directive(NgMouseOverAttrDirective);
  module.directive(NgMouseUpAttrDirective);
  module.directive(NgMouseWheelAttrDirective);
  module.directive(NgScrollAttrDirective);
  module.directive(NgTouchCancelAttrDirective);
  module.directive(NgTouchEndAttrDirective);
  module.directive(NgTouchMoveAttrDirective);
  module.directive(NgTouchStartAttrDirective);
  module.directive(NgStyleAttrDirective);
}
