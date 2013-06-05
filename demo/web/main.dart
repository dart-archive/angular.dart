import 'package:angular/angular.dart';
import 'package:di/di.dart';
import 'dart:html' as dom;
import 'dart:math' as math;

class AngularBootstrap {
  Compiler $compile;
  Scope $rootScope;
  Directives directives;

  AngularBootstrap(Compiler this.$compile, Scope this.$rootScope, Directives this.directives);

  call() {
    List<dom.Node> topElt = dom.query('[ng-app]').nodes.toList();
    assert(topElt.length > 0);

    $rootScope['greeting'] = "Hello world!";
    var lastRandom;
    $rootScope['random'] = () {
      if (lastRandom == null) lastRandom = "Random: ${new math.Random().nextInt(100)}";
      return lastRandom;
    };
    $rootScope['people'] = ["James", "Misko"];
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

  BookController(Scope this.$scope) {
    $scope.greeting = "TabController";
    chapters = [];
    $scope.chapters = chapters;

    $scope.selected = (chapterScope) {
      chapters.forEach((p) {
        p["selected"] = false;
      });
      chapterScope["selected"] = true;
    };
  }

  addChapter(var chapterScope) {
    if (chapters.length == 0) { ($scope.selected)(chapterScope); }
    chapters.add(chapterScope);
  }
}

class BookAttrDirective {
  static var $controller = BookController;
  static String $template =
    '<div>Shadow backed template. Greeting from the controller: <span ng-bind="greeting"></span>' +
    '<h2>Table of Contents</h2><ul class="nav nav-tabs">' +
    '  <li ng-repeat="chapter in chapters" ng-bind="chapter.title"></li>' +
    '</ul>' +
    '<content></content>' +
    '</div>';

  attach(Scope scope) {}
}

class ChapterAttrDirective {
  static var $require = "^[book]";
  BookController controller;
  dom.Element element;
  ChapterAttrDirective(dom.Element this.element, Controller this.controller);

  attach(Scope scope) {
    // automatic scope management isn't implemented yet.
    var child = scope.$new();
    child.title = element.attributes['title'];
    controller.addChapter(child);
  }
}

main() {
  // Set up the Angular directives.
  var module = new Module();
  module.value(Expando, new Expando());
  angularModule(module);
  Injector injector = new Injector([module]);
  Directives directives = injector.get(Directives);
  directives.register(NgBindAttrDirective);
  directives.register(NgRepeatAttrDirective);
  directives.register(NgShadowDomAttrDirective);
  directives.register(BookAttrDirective);
  directives.register(ChapterAttrDirective);

  injector.get(AngularBootstrap)();


}
