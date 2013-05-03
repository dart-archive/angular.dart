import 'package:angular/angular.dart';
import 'package:di/di.dart';
import 'dart:html' as dom;

class AngularBootstrap {
  Compiler $compile;
  Scope $rootScope;
  Directives directives;

  AngularBootstrap(Compiler this.$compile, Scope this.$rootScope, Directives this.directives);
  
  call() {
    List<dom.Element> topElt = [dom.query('[ng-app]')];

    $rootScope['greeting'] = "Hello world!";
    
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
