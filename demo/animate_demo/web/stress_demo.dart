part of animate_demo;

@NgComponent(selector: 'stress-demo', template:
    '''
      <div class="stress-demo">
        <button ng-click="ctrl.visible = !ctrl.visible">
          Toggle Visibility</button>
        <div>
          <div class="stress-box"
            ng-repeat="number in ctrl.numbers">
        </div>
        </div>
      </div>
    ''',
    publishAs: 'ctrl', applyAuthorStyles: true)
class StressDemoComponent {
  bool _visible = true;

  // When visibility changes add or remove a large
  // chunk of elements.
  void set visible(bool value) {
    if (value) {
      for (int i = 0; i < 200; i++) {
        numbers.add(i);
      }
    } else {
      numbers.clear();
    }
    _visible = value;
  }

  bool get visible => _visible;

  List<int> numbers = [1, 2];
}
