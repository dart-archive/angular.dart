import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';

main() {
  var app = applicationFactory();
  app.modules.add(new Module()
    ..bind(MyComponent)
    ..bind(BracketButton));
  app.selector("body");
  app.run();
}

@Component(selector: "my-component", template: """
      <div class="custom-component" ng-class="color">
        <span>Shadow [</span><content></content><span>]</span>
        <a ng-click="on=!on">
        <my-button>Toggle</my-button></a>
        <span ng-if="on">off</span>
        <span ng-if="!on">on</span>
      </div>
    """, cssUrl: "css/shadow_dom_components.css")
class MyComponent {
  @NgAttr('color')
  String color;

  bool on = false;
}

@Component(
    selector: "my-button",
    template: """<span class="custom-bracket">[[[<content>
      </content>]]]</span>""", cssUrl: "css/shadow_dom_bracket.css")
class BracketButton {}
