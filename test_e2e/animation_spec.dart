library angular.example.animation_spec;

import 'dart:html';
import 'package:protractor/protractor_api.dart';

part 'animation_ng_repeat_spec.dart';
part 'animation_visibility_spec.dart';

class AppState {
  var ngRepeatBtn = element(by.buttonText("ng-repeat"));
  var visibilityBtn = element(by.buttonText("Visibility"));

  var heading = element(by.css(".demo h2"));
}


main() {
  describe('animation example', () {
    beforeEach(() {
      protractor.getInstance().get('animation.html');
      element(by.tagName("body")).allowAnimations(false);
    });

    it('should start in about page', () {
      var S = new AppState();
      expect(S.heading.getText()).toEqual("About");
    });

    animation_ng_repeat_spec();
    animation_visibility_spec();
  });
}
