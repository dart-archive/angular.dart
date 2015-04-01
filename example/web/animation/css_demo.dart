part of animation;

@Component(selector: 'css-demo', useShadowDom: false, template: '''
      <div class="css-demo">
        <button ng-click="stateA = !stateA"
            ng-class="{'active': stateA}">
            Toggle A</button>
        <button ng-click="stateB = !stateB"
            ng-class="{'active': stateB}">
            Toggle B</button>
        <button ng-click="stateC = !stateC"
            ng-class="{'active': stateC}">
            Toggle C</button>
        <div class="box-container">
          <div class="css-box" ng-class="{
            'a': stateA,
            'b': stateB,
            'c': stateC}">BOX</div>
          </div>
        </div>
      </div>
    ''')
class CssDemo {
  bool stateA = false;
  bool stateB = false;
  bool stateC = false;
}
