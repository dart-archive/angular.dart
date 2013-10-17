import 'dart:html' as dom;
import 'dart:math' as math;

import 'package:angular/angular.dart';

class BookController {
  Scope $scope;
  List chapters;

  attach(Scope scope) {
    $scope = scope;

    $scope.greeting = 'TabController';
    chapters = [];
    $scope.chapters = chapters;

    $scope.selected = (chapterScope) {
      chapters.forEach((p) {
        p['selected'] = false;
      });
      chapterScope['selected'] = true;
    };
  }

  addChapter(var chapterScope) {
    if (chapters.length == 0) { ($scope.selected)(chapterScope); }
    chapters.add(chapterScope);
  }
}

class BookComponent {
  BookController controller;
  BookComponent(BookController this.controller);

  static String $templateUrl = 'book.html';
  static String $cssUrl = 'book.css';

  attach(Scope scope) {
    controller.attach(scope);
  }
}

class ChapterDirective {
  BookController controller;
  dom.Element element;
  ChapterDirective(dom.Element this.element, BookController this.controller);

  attach(Scope scope) {
    // automatic scope management isn't implemented yet.
    var child = scope.$new();
    child.title = element.attributes['title'];
    controller.addChapter(child);
  }
}

@NgDirective(
  selector: '[main-controller]'
)
class MainController {

  String _random = 'Random: ${new math.Random().nextInt(100)}';

  MainController(Scope scope) {
    scope['greeting'] = 'Hello world!';
    scope['people'] = ['James', 'Misko'];
    scope['objs'] = [{'v': 'v1'}, {'v': 'v2'}];
    scope['random'] = () {
      return _random;
    };
  }
}

main() {
  // Set up the Angular directives.
  var module = new AngularModule()
    ..type(BookComponent)
    ..type(ChapterDirective)
    ..type(MainController);

  ngBootstrap([module]);
}
