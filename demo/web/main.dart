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
    List<dom.Element> topElt = [dom.query('[ng-app]')];
    assert(topElt.length > 0);

    $rootScope['greeting'] = "Hello world!";
    $rootScope['random'] = () { return "Random: ${new math.Random().nextInt(100)}"; };

    var template = $compile.call(topElt);
    template.call(topElt).attach($rootScope);

    // Digest the scope.
    $rootScope.$digest();
  }


}
main() {
  // Set up the Angular directives.
  Injector injector = new Injector();
  Directives directives = injector.get(Directives);
  directives.register(BindDirective);

  injector.get(AngularBootstrap)();


}
