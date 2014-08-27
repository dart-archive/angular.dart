library animation;

import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';
import 'package:angular/animate/module.dart';
import 'package:quiver/collection.dart';

part 'animation/repeat_demo.dart';
part 'animation/visibility_demo.dart';
part 'animation/stress_demo.dart';
part 'animation/css_demo.dart';

@Injectable()
class AnimationDemo {
  final pages = ["About", "ng-repeat", "Visibility", "Css", "Stress Test"];
  var currentPage = "About";
}

// Temporary workaround, because context needs to extend Map.
@Injectable()
class AnimationDemoHashMap extends DelegatingMap {
  final Map _delegate;
  AnimationDemoHashMap(AnimationDemo demo) : _delegate = new Map() {
    _delegate['demo'] = demo;
  }
  Map get delegate => _delegate;
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
      .rootContextType(AnimationDemoHashMap)
      .run();
}
