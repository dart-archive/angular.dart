part of animation;

@Component(selector: 'visibility-demo', template: '''
      <div class="visibility-demo">
      <button ng-click="visible = !visible">Toggle Visibility</button>
      <div class="visible-if" ng-if="visible">
        <p>Hello World. ng-if will create and destroy
          dom elements each time you toggle me.</p>
      </div>
      <div class="visible-hide" ng-hide="visible">
        <p>Hello World. ng-hide will add and remove
          the .ng-hide class from me to show and
          hide this view of text.</p>
      </div>
      </div>
    ''', useShadowDom: false)
class VisibilityDemo {
  bool visible = false;
}
