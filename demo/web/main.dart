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

    var template = $compile.call(topElt);
    template.call(topElt).attach($rootScope);

    // Digest the scope.
    $rootScope.$digest();
  }
}

class TabsController implements Controller {
  Scope $scope;
  List panes;
  var selectedPanes = new Expando<dom.Node>();

  MainController(Scope this.$scope) {
    panes = $scope.panes = [];

    $scope.selected = (pane) {
      panes.forEach((p) {
        selectedPanes[p]['selected'] = false;
      });
      selectedPanes[pane]['selected'] = true;
    };
  }

  addPane(dom.Node pane) {
    if (panes.length == 0) { $scope.selected(pane); }
    panes.add(pane);
  }
}

class TabsAttrDirective {
  static var $transclude = "true";
  static String $template = '<div class="tabbable">Shadow' +
    '<ul class="nav nav-tabs">' +
    '<li ng-repeat="pane in panes" ng-class="{active:pane.selected}">'+
    '<a href="" ng-click="select(pane)">{{pane.title}}</a>' +
    '</li>' +
    '</ul>' +
    '<content class="tab-content" ng-transclude>CONTENT</content>' +
    '</div>';
 // static String $template = '<div>Hello shaddow</div>';
  BlockList blockList;


  TabsAttrDirective(BlockList this.blockList,
                    dom.Element element) {
    dom.ShadowRoot shadow = element.createShadowRoot();


    print("tab attr: ${element.text}");
    print("shadow: ${shadow.text}");

  }

  attach(Scope scope) {
    print("tab attach");
  }
}

main() {
  // Set up the Angular directives.
  var module = new Module();
  angularModule(module);
  Injector injector = new Injector([module]);
  Directives directives = injector.get(Directives);
  directives.register(NgBindAttrDirective);
  directives.register(NgRepeatAttrDirective);
  directives.register(NgShadowDomAttrDirective);
  directives.register(TabsAttrDirective);

  injector.get(AngularBootstrap)();


}
