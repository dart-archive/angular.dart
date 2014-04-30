library todo;

import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';
import 'package:angular/playback/playback_http.dart';

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
abstract class Server {
  init(Todo todo);
}


// An implementation of ServerController that does nothing.
@Injectable()
class NoOpServer implements Server {
  init(Todo todo) { }
}


// An implementation of ServerController that fetches items from
// the server over HTTP.
@Injectable()
class HttpServer implements Server {
  final Http _http;
  HttpServer(this._http);

  init(Todo todo) {
    _http(method: 'GET', url: '/todos').then((HttpResponse data) {
      data.data.forEach((d) {
        todo.items.add(new Item(d["text"], d["done"]));
      });
    });
  }
}


@Controller(
    selector: '[todo-controller]',
    publishAs: 'todo')
class Todo {
  var items = <Item>[];
  Item newItem;

  Todo(Server serverController) {
    newItem = new Item();
    items = [
        new Item('Write Angular in Dart', true),
        new Item('Write Dart in Angular'),
        new Item('Do something useful')
    ];

    serverController.init(this);
  }

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

main() {
  print(window.location.search);
  var module = new Module()
      ..bind(Todo)
      ..bind(PlaybackHttpBackendConfig);

  // If these is a query in the URL, use the server-backed
  // TodoController.  Otherwise, use the stored-data controller.
  var query = window.location.search;
  if (query.contains('?')) {
    module.bind(Server, toImplementation: HttpServer);
  } else {
    module.bind(Server, toImplementation: NoOpServer);
  }

  if (query == '?record') {
    print('Using recording HttpBackend');
    var wrapper = new HttpBackendWrapper(new HttpBackend());
    module.bind(HttpBackendWrapper, toValue: new HttpBackendWrapper(new HttpBackend()));
    module.bind(HttpBackend, toImplementation: RecordingHttpBackend);
  }

  if (query == '?playback') {
    print('Using playback HttpBackend');
    module.bind(HttpBackend, toImplementation: PlaybackHttpBackend);
  }

  applicationFactory().addModule(module).run();
}
