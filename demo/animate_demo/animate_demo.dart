import 'dart:html' as dom;

import 'package:angular/angular.dart';
import 'package:angular/animate/module.dart';

// This annotation allows Dart to shake away any classes
// not used from Dart code nor listed in another @MirrorsUsed.
//
// If you create classes that are referenced from the Angular
// expressions, you must include a library target in @MirrorsUsed.
@MirrorsUsed(override: '*')
import 'dart:mirrors';

@NgController(
    selector: '[animation-demo]',
    publishAs: 'adc'
)
class AnimationDemoController {
  
  final Animate animate;
  bool areThingsVisible = false;
  bool boxToggle = false;
  bool ifToggle = false;

  dom.Element _boxElement;
  dom.Element _hostElement;
  List<dom.Element> _animatedBoxes = [];
  
  AnimationDemoController(this.animate);
  
  animateABox() {
    if(_boxElement != null) {
      if(boxToggle) {
        animate.removeClass(_boxElement, "magic");
      } else {
        animate.addClass(_boxElement, "magic");
      }
      boxToggle = !boxToggle;
    }
  }

  setBoxElement(element) {
    boxToggle = false;
    _boxElement = element;
  }
  
  setHostElement(element) {
    areThingsVisible = false;
    _hostElement = element;
  }
  
  toggleABunchOfThings() {
    if(_hostElement != null) {
      if(!areThingsVisible && _animatedBoxes.length == 0) {

        for(int i = 0; i < 1000; i++) {
          var element = new dom.Element.div();
          element.classes.add("magic-box");
          _animatedBoxes.add(element);
          _hostElement.children.add(element);
        }
        animate.addAll(_animatedBoxes);
      } else if (!areThingsVisible) {
        animate.addAll(_animatedBoxes);
      } else if (_animatedBoxes.length > 0) {
        animate.removeAll(_animatedBoxes).onCompleted.then((result) {
         if((result == AnimationResult.COMPLETED)
             || (result == AnimationResult.COMPLETED_IGNORED)) {
           _animatedBoxes.forEach((box) => box.remove());
           _animatedBoxes.clear();
          }
        });
      }

      areThingsVisible = !areThingsVisible;
    }
  }
}

/**
 * Hacky directive to get access to an element in the controller.
 */
@NgDirective(
    selector: "[element]",
    map: const {
      'element': '&onElement',
    })
class GetElementDirective {
  final dom.Element element;

  set onElement(BoundExpression value) {
    value({'x': element});
  }

  GetElementDirective(dom.Element this.element);
}

main() {
  ngBootstrap(module: new Module()
    ..type(AnimationDemoController)
    ..type(GetElementDirective));
}
