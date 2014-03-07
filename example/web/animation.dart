library animation;

import 'package:angular/angular.dart';
import 'package:angular/angular_dynamic.dart';
import 'package:angular/animate/module.dart';

part 'animation/repeat_demo.dart';
part 'animation/visibility_demo.dart';
part 'animation/stress_demo.dart';
part 'animation/css_demo.dart';

@NgController(
    selector: '[animation-demo]',
    publishAs: 'demo')
class AnimationDemoController {
  final pages = ["About", "ng-repeat", "Visibility", "Css", "Stress Test"];
  var currentPage = "About";
}

main() {
  ngDynamicApp()
    .addModule(new Module()
      ..type(RepeatDemoComponent)
      ..type(VisibilityDemoComponent)
      ..type(StressDemoComponent)
      ..type(CssDemoComponent)
      ..type(AnimationDemoController))
    .addModule(new NgAnimateModule())
    .run();
}
