import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';

main() {
  applicationFactory()
      .addModule(new Module()..bind(AngularDartLogo))
      .run();
}

@Component(
    selector: "g[angular-dart-logo]",
    publishAs: "ctrl",
    templateUrl: "img/logo.svg",
    useShadowDom: false,
    wrapElement: "svg")
class AngularDartLogo {}
