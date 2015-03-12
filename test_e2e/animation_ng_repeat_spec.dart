part of angular.example.animation_spec;

class NgRepeatAppState extends AppState {
  var addBtn = element(by.buttonText("Add Thing"));
  var removeBtn = element(by.buttonText("Remove Thing"));
  var rows = element.all(by.repeater("outer in items"));
  var thingId = 0;  // monotonically increasing.
  var things = [];

  addThing() {
    things.add(thingId++);
    addBtn.click();
  }

  removeThing() {
    if (things.length > 0) {
      things.removeLast();
    }
    removeBtn.click();
  }

  cell(x, y) => rows.get(x).findElements(by.tagName("li"))
      .then((e) => toDartArray(e)[y].getText());

  assertState() {
    expect(rows.count()).toBe(things.length);
    for (int y = 0; y < things.length; y++) {
      for (int x = 0; x < things.length; x++) {
        expect(cell(x, y)).toEqual("Thing ${things[y]}");
      }
    }
  }
}

animation_ng_repeat_spec() {
  describe('ng-repeat', () {
    var S;

    beforeEach(() {
      S = new NgRepeatAppState();
      S.ngRepeatBtn.click();
    });

    it('should switch to the ng-repeat example', () {
      expect(S.heading.getText()).toEqual("ng-repeat Demo");
      S.assertState();
    });

    it('should add row', () {
      S.addThing();
      S.assertState();
      S.addThing();
      S.assertState();
      S.removeThing();
      S.addThing();
      S.assertState();
    });

    it('should remove rows', () {
      S.addThing();
      S.addThing();
      S.assertState();

      S.removeThing();
      S.assertState();

      S.removeThing();
      S.assertState();
    });

    it('should not remove rows that do not exist', () {
      S.removeThing();
      S.assertState();

      S.addThing();
      S.removeThing();
      S.removeThing();
      S.assertState();
    });

    // TODO(chirayu): Disabled because this times out on Travis + SauceLabs.
    xit('should add things with monotonically increasing numbers', () {
      S.addThing();
      S.addThing(); S.removeThing(); S.addThing();
      S.addThing(); S.removeThing(); S.addThing();
      S.addThing();
      expect(S.things).toEqual([0, 2, 4, 5]);
      S.assertState();
    });
  });
}
