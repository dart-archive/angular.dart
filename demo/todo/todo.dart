library todo;

import 'package:angular/angular.dart';


class Item {
  String text;
  bool done;

  Item([String this.text = '', bool this.done = false]);

  bool get isEmpty => text.isEmpty;

  clone() => new Item(text, done);

  clear() {
    text = '';
    done = false;
  }
}

class TodoController {
  List<Item> items;
  Item newItem;

  TodoController() {
    newItem = new Item();
    items = [
      new Item('Write Angular in Dart', true),
      new Item('Write Dart in Angular'),
      new Item('Do something useful')
    ];
  }

  // workaround for https://github.com/angular/angular.dart/issues/37
  dynamic operator [](String key) {
    if (key == 'newItem') {
      return newItem;
    }
  }

  add() {
    if (newItem.isEmpty) return;

    items.add(newItem.clone());
    newItem.clear();
  }

  markAllDone() {
    items.forEach((item) => item.done = true);
  }

  archiveDone() {
    items.removeWhere((item) => item.done);
  }

  String classFor(Item item) {
    item.done ? 'done' : '';
  }

  int remaining() {
    return items.where((item) => !item.done).length;
  }
}
