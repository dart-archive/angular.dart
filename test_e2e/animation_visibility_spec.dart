part of angular.example.animation_spec;

class VisibilityAppState extends AppState {
  var toggleBtn = element(by.buttonText("Toggle Visibility"));
  var visibleIf = element(by.css(".visible-if"));
  var visibleHide = element(by.css(".visible-hide"));

  hasClass(var element, String expectedClass) {
    return element.getAttribute("class").then((_class) =>
      "$_class".split(" ").contains(expectedClass));
  }

  assertState({bool toggled: false}) {
      expect(hasClass(visibleHide, "ng-hide")).toEqual(toggled);
      expect(visibleIf.isPresent()).toEqual(toggled);
  }
}

animation_visibility_spec() {
  var S;

  describe('visibility', () {
    beforeEach(() {
      S = new VisibilityAppState();
      S.visibilityBtn.click();
    });

    it('should switch to the visibility example in initial state', () {
      expect(S.heading.getText()).toEqual("Visibility Demo");
      expect(S.visibleHide.getText()).toEqual(
          "Hello World. ng-hide will add and remove the .ng-hide class "
          "from me to show and hide this view of text.");
      S.assertState(toggled: false);
    });

    it('should toggle ng-hide and ng-if', () {
      S.toggleBtn.click();
      S.assertState(toggled: true);
      S.toggleBtn.click();
      S.assertState(toggled: false);
      S.toggleBtn.click();
      S.assertState(toggled: true);
    });

  });
}
