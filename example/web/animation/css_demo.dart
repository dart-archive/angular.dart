part of animation;

@Component(
    selector: 'css-demo',
    template: '''
      <div class="css-demo">
        <button ng-click="ctrl.stateA = !ctrl.stateA"
            ng-class="{'active': ctrl.stateA}">
            Toggle A</button>
        <button ng-click="ctrl.stateB = !ctrl.stateB"
            ng-class="{'active': ctrl.stateB}">
            Toggle B</button>
        <button ng-click="ctrl.stateC = !ctrl.stateC"
            ng-class="{'active': ctrl.stateC}">
            Toggle C</button>
        <div class="box-container">
          <div class="css-box" ng-class="{
            'a': ctrl.stateA,
            'b': ctrl.stateB,
            'c': ctrl.stateC}">BOX</div>
          </div>
        </div>
      </div>
    ''',
    publishAs: 'ctrl',
    applyAuthorStyles: true)
class CssDemo {
  bool stateA = false;
  bool stateB = false;
  bool stateC = false;
}
