part of animate_demo;

@NgComponent(
    selector: 'repeat-demo',
    template: '''
      <div class="repeat-demo">
      <button ng-click="ctrl.addItem()">Add Thing</button>
      <button ng-click="ctrl.removeItem()">Remove Thing
      </button>
      <ul><li ng-repeat="outer in ctrl.items">
        <ul><li ng-repeat="inner in ctrl.items">
          {{inner}}</li></ul>
      </li></ul>
      </div>
    ''',
    publishAs: 'ctrl',
    applyAuthorStyles: true)
class RepeatDemoComponent {
  var thing = 0;
  var items = [];

  addItem() {
    items.add("Thing ${thing++}");
  }

  removeItem() {
    if (items.isNotEmpty) items.removeLast();
  }
}
