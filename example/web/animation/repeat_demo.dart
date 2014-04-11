part of animation;

@Component(
    selector: 'repeat-demo',
    template: '''
      <div class="repeat-demo">
      <button ng-click="ctrl.addItem()">Add Thing</button>
      <button ng-click="ctrl.removeItem()">Remove Thing
      </button>
      <ul>
        <li ng-repeat="outer in ctrl.items">
          <ul>
            <li ng-repeat="inner in ctrl.items">{{inner}}</li>
          </ul>
        </li>
      </ul>
      </div>
    ''',
    publishAs: 'ctrl',
    applyAuthorStyles: true)
class RepeatDemo {
  var thing = 0;
  final items = [];

  void addItem() {
    items.add("Thing ${thing++}");
  }

  void removeItem() {
    if (items.isNotEmpty) items.removeLast();
  }
}
