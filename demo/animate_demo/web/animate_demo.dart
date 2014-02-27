library animate_demo;

import 'package:angular/angular.dart';
import 'package:angular/animate/module.dart';

// This annotation allows Dart to shake away any classes
// not used from Dart code nor listed in another @MirrorsUsed.
//
// If you create classes that are referenced from the Angular
// expressions, you must include a library target in @MirrorsUsed.
@MirrorsUsed(override: '*')
import 'dart:mirrors';

part 'repeat_demo.dart';
part 'visibility_demo.dart';
part 'stress_demo.dart';
part 'css_demo.dart';

@NgController(
    selector: '[animation-demo]',
    publishAs: 'demo'
)
class AnimationDemoController {
  var pages = ["About", "ng-repeat", "Visibility", "Css", "Stress Test"];
  var currentPage = "About";
}

main() {
  ngBootstrap(module: new Module()
    ..install(new NgAnimateModule())
    ..type(RepeatDemoComponent)
    ..type(VisibilityDemoComponent)
    ..type(StressDemoComponent)
    ..type(CssDemoComponent)
    ..type(AnimationDemoController));
}
