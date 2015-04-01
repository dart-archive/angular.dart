part of animation;

@Component(selector: 'stress-demo', useShadowDom: false, template: '''
      <div class="stress-demo">
        <button ng-click="visible = !visible">
          Toggle Visibility</button>
        <div>
          <div class="stress-box" ng-repeat="number in numbers"></div>
        </div>
      </div>
    ''')
class StressDemo {
  bool _visible = true;
  final numbers = <int>[1, 2];

  // When visibility changes add or remove a large chunk of elements.
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
}
