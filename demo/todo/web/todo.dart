library todo;

import 'package:angular/angular.dart';


class Item {
  String text;
  bool done;

  Item([this.text = '', this.done = false]);

  bool get isEmpty => text.isEmpty;

  Item clone() => new Item(text, done);

  void clear() {
    text = '';
    done = false;
  }
}


// ServerController interface. Logic in main.dart determines which
// implementation we should use.
abstract class ServerController {
  init(TodoController todo);
}


// An implementation of ServerController that does nothing.
class NoServerController implements ServerController {
  init(TodoController todo) { }
}


// An implementation of ServerController that fetches items from
// the server over HTTP.
class HttpServerController implements ServerController {
  final Http _http;
  HttpServerController(this._http);

  init(TodoController todo) {
    _http(method: 'GET', url: '/todos').then((HttpResponse data) {
      data.data.forEach((d) {
        todo.items.add(new Item(d["text"], d["done"]));
      });
    });
  }
}


@NgController(
    selector: '[todo-controller]',
    publishAs: 'todo')
class TodoController {
  var items = <Item>[];
  Item newItem;

  TodoController(ServerController serverController) {
    newItem = new Item();
    items = [
      new Item('Write Angular in Dart', true),
      new Item('Write Dart in Angular'),
      new Item('Do something useful')
    ];

    serverController.init(this);
  }

  // workaround for https://github.com/angular/angular.dart/issues/37
  dynamic operator [](String key) => key == 'newItem' ? newItem : null;

  void add() {
    if (newItem.isEmpty) return;

    items.add(newItem.clone());
    newItem.clear();
  }

  void markAllDone() {
    items.forEach((item) => item.done = true);
  }

  void archiveDone() {
    items.removeWhere((item) => item.done);
  }

  String classFor(Item item) => item.done ? 'done' : '';

  int remaining() => items.fold(0, (count, item) => count += item.done ? 0 : 1);
}
