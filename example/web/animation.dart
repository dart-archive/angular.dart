library animation;

import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';
import 'package:angular/animate/module.dart';

part 'animation/repeat_demo.dart';
part 'animation/visibility_demo.dart';
part 'animation/stress_demo.dart';
part 'animation/css_demo.dart';

@Controller(
    selector: '[animation-demo]',
    publishAs: 'demo')
class AnimationDemo {
  final pages = ["About", "ng-repeat", "Visibility", "Css", "Stress Test"];
  var currentPage = "About";
}

class AnimationDemoModule extends Module {
  AnimationDemoModule() {
    install(new AnimationModule());
    bind(RepeatDemo);
    bind(VisibilityDemo);
    bind(StressDemo);
    bind(CssDemo);
    bind(AnimationDemo);
  }
}
main() {
  applicationFactory()
      .addModule(new AnimationDemoModule())
      .run();
}
