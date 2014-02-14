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
  final dom.Element rootElement;
  final Animate animate;
  bool areThingsVisible = false;
  bool boxToggle = false;
  bool ifToggle = false;
  int thingNumber = 1;
  String currentThing;

  dom.Element _boxElement;
  dom.Element _hostElement;
  List<dom.Element> _animatedBoxes = [];
  List<String> listOfThings = [];
  
  AnimationDemoController(this.animate, this.rootElement) {
    _boxElement = rootElement.querySelector(".animated-box");
    _hostElement = rootElement.querySelector(".animated-host");
  }
  
  animateABox() {
    if(_boxElement != null) {
      if(boxToggle) {
        animate.removeClass([_boxElement], "magic");
      } else {
        animate.addClass([_boxElement], "magic");
      }
      boxToggle = !boxToggle;
    }
  }

  toggleABunchOfThings() {
    if(_hostElement != null) {
      if(!areThingsVisible && _animatedBoxes.length == 0) {

        for(int i = 0; i < 1000; i++) {
          var element = new dom.Element.div();
          element.classes.add("magic-box");
          _animatedBoxes.add(element);
        }
        animate.insert(_animatedBoxes, _hostElement);
      } else if (!areThingsVisible) {
        // I'm not sure what to do about this
        animate.insert(_animatedBoxes, _hostElement);
      } else if (_animatedBoxes.length > 0) {
        animate.remove(_animatedBoxes).onCompleted.then((result) {
//          if(result.isCompleted) {
//            _animatedBoxes.clear();
//          }
        });
      }

      areThingsVisible = !areThingsVisible;
    }
  }
  
  addThing() {
    listOfThings.add("Thing-$thingNumber");
    thingNumber++;
  }
  
  removeThing() {
    if(listOfThings.length > 0) {
      listOfThings.removeLast();
    }
  }
}

main() {
  ngBootstrap(module: new Module()
    ..install(new NgAnimateModule())
    ..type(AnimationDemoController));
}
