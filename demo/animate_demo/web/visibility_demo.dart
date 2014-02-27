part of animate_demo;

@NgComponent(
    selector: 'visibility-demo',
    template: '''
      <div class="visibility-demo">
      <button ng-click="ctrl.visible = !ctrl.visible">
        Toggle Visibility</button>
      <div class="visible-if" ng-if="ctrl.visible">
        <p>Hello World. ng-if will create and destroy
          dom elements each time you toggle me.</p>
      </div>
      <div class="visible-hide" ng-hide="ctrl.visible">
        <p>Hello World. ng-hide will add and remove
          the .ng-hide class from me to show and
          hide this block of text.</p>
      </div>
      </div>
    ''',
    publishAs: 'ctrl',
    applyAuthorStyles: true
)
class VisibilityDemoComponent {
  // TODO(codelogic): split and add ng-switch.
  bool visible = false;
}