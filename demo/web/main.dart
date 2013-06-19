import 'package:angular/angular.dart';
import 'package:di/di.dart';
import 'dart:html' as dom;
import 'dart:math' as math;

class AngularBootstrap {
  Compiler $compile;
  Scope $rootScope;

  AngularBootstrap(Compiler this.$compile, Scope this.$rootScope);

  call() {
    List<dom.Node> topElt = dom.query('[ng-app]').nodes.toList();
    assert(topElt.length > 0);

    $rootScope['greeting'] = 'Hello world!';
    var lastRandom;
    $rootScope['random'] = () {
      if (lastRandom == null) lastRandom =
          'Random: ${new math.Random().nextInt(100)}';
      return lastRandom;
    };
    $rootScope['people'] = ['James', 'Misko'];
    $rootScope['objs'] = [{'v': 'v1'}, {'v': 'v2'}];

    var template = $compile.call(topElt);
    template.call(topElt).attach($rootScope);

    // Digest the scope.
    $rootScope.$digest();
  }
}

class BookController implements Controller {
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

main() {
  // Set up the Angular directives.
  var module = new AngularModule();
  module.value(Expando, new Expando());
  angularModule(module);
  Injector injector = new Injector([module]);
  injector.get(DirectiveRegistry)
      ..register(NgBindAttrDirective)
      ..register(NgRepeatAttrDirective)
      ..register(BookComponent)
      ..register(ChapterDirective);

  injector.get(AngularBootstrap)();


}
