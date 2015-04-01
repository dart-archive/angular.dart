part of animation;

@Component(selector: 'repeat-demo', useShadowDom: false, template: '''
      <div class="repeat-demo">
      <button ng-click="addItem()">Add Thing</button>
      <button ng-click="removeItem()">Remove Thing</button>
      <ul>
        <li ng-repeat="outer in items">
          <ul>
            <li ng-repeat="inner in items">{{inner}}</li>
          </ul>
        </li>
      </ul>
      </div>
    ''')
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
