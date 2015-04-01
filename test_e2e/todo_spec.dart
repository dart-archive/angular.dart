import 'package:protractor/protractor_api.dart';

class AppState {
  var items = element.all(by.repeater('item in items'));
  var remaining = element(by.binding('remaining'));
  var total = element(by.binding('items.length'));

  var markAllDoneBtn = element(by.buttonText("mark all done"));
  var archiveDoneBtn = element(by.buttonText("archive done"));
  var addBtn = element(by.buttonText("add"));
  var clearBtn = element(by.buttonText("clear"));

  var newItemInput = element(by.model("newItem.text"));
  get newItemText => newItemInput.getAttribute('value');

  todo(i) => items.get(i).getText();
  input(i) => items.get(i).findElement(by.tagName("input"));

  // Initial state.
  var todos = [
    'Write Angular in Dart',
    'Write Dart in Angular',
    'Do something useful'
  ];
  var checks = [true, false, false];

  get numTodos => todos.length;
  get numChecked => checks.where((i) => i).length;

  assertTodos() {
    expect(remaining.getText()).toEqual('${numTodos - numChecked}');
    expect(total.getText()).toEqual('${numTodos}');
    expect(items.count()).toBe(numTodos);
    for (int i = 0; i < todos.length; i++) {
      expect(todo(i)).toEqual(todos[i]);
      expect(input(i).isSelected()).toEqual(checks[i]);
    }
  }

  assertNewItem([String text]) {
    text = (text == null) ? '' : text;
    expect(addBtn.isEnabled()).toEqual(text.length > 0);
    expect(clearBtn.isEnabled()).toEqual(text.length > 0);
    // input field and model value should contain the typed text.
    expect(newItemText).toEqual(text);
    expect(newItemInput.evaluate('newItem.text')).toEqual(text);
  }
}

main() {
  describe('todo example', () {
    var S;

    beforeEach(() {
      protractor.getInstance().get('todo.html');
      S = new AppState();
    });

    it('should set initial values for elements', () {
      S.assertTodos();
    });

    it('should update model when checkbox is toggled', () {
      S.input(0).click();
      S.checks[0] = false;
      S.assertTodos();

      S.input(1).click();
      S.checks[1] = true;
      S.assertTodos();
    });

    it('should mark all done with a button', () {
      S.markAllDoneBtn.click();
      S.checks = new List.filled(S.todos.length, true);
      S.assertTodos();
    });

    it('should archive done items', () {
      S.archiveDoneBtn.click();
      // the first todo should disappear.
      S.todos.removeAt(0);
      S.checks = new List.filled(S.todos.length, false);
      S.assertTodos();
    });

    it('should enable/disable add and clear buttons when input is empty/has text',
        () {
      S.assertNewItem('');

      // type a character
      S.newItemInput.sendKeys('a');
      S.assertNewItem('a');

      // backspace
      S.newItemInput.sendKeys('\x08'); // backspace
      S.assertNewItem('');

      // type a character again
      S.newItemInput.sendKeys('a');
      S.assertNewItem('a');
    });

    // TODO: Re-enable when issue 1316 is resolved correctly.
    xit('should reflect new item text changes in model', () {
      expect(S.newItemText).toEqual('');
      var text = 'Typing something ...';
      S.newItemInput.sendKeys(text);
      // input field and model value should contain the typed text.
      expect(S.newItemText).toEqual(text);
      expect(S.newItemInput.evaluate('newItem.text')).toEqual(text);
      S.assertTodos();
    });

    // TODO: Re-enable when issue 1316 is resolved correctly.
    xit('should clear input with clear button', () {
      S.newItemInput.sendKeys('Typing something ...');
      S.clearBtn.click();
      // input field should be clear.
      expect(S.newItemText).toEqual('');
      S.assertTodos();
    });

    // TODO: Re-enable when issue 1316 is resolved correctly.
    xit('should add a new item and clear the input field', () {
      var text = 'Test using Protractor';
      S.newItemInput.sendKeys(text);
      S.addBtn.click();
      S.assertNewItem('');
      S.todos.add(text);
      S.checks.add(false);
      S.assertTodos();

      // This time, use the <Enter> key instead of clicking the add
      // button.
      text = 'Pressed enter in the input field';
      S.newItemInput.sendKeys(text + '\n');
      S.addBtn.click();
      S.assertNewItem('');
      S.todos.add(text);
      S.checks.add(false);
      S.assertTodos();
    });

    it('should have empty list when all items are done', () {
      S.markAllDoneBtn.click();
      S.archiveDoneBtn.click();
      S.todos = S.checks = [];
      S.assertTodos();
    });
  });
}
