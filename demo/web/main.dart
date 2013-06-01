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
main() {
  // Set up the Angular directives.
  var module = new Module();
  angularModule(module);
  Injector injector = new Injector([module]);
  Directives directives = injector.get(Directives);
  directives.register(NgBindAttrDirective);
  directives.register(NgRepeatAttrDirective);

  injector.get(AngularBootstrap)();


}
