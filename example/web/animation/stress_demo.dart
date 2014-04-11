part of animation;

@Component(
    selector: 'stress-demo',
    template: '''
      <div class="stress-demo">
        <button ng-click="ctrl.visible = !ctrl.visible">
          Toggle Visibility</button>
        <div>
          <div class="stress-box" ng-repeat="number in ctrl.numbers"></div>
        </div>
      </div>
    ''',
    publishAs: 'ctrl',
    applyAuthorStyles: true)
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
