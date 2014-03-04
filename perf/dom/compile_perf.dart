import '_perf.dart';

void main() {
  describe('compiler', () {
    describe('view instantiation', () {
      it('time ', inject((TestBed tb) {
        tb.compile(UL_REPEATER);
        var items = [];
        for(var i = 0; i < 100; i++) {
          items.add({"text":'text_$i', "done": i & 1 == 1});
        }
        var empty = [];
        tb.rootScope.context['classFor'] = (item) => 'ng-${item["done"]}';

        time('create 100 views',
            () => tb.rootScope.apply(() => tb.rootScope.context['items'] = items),
            cleanUp: () => tb.rootScope.apply(() => tb.rootScope.context['items'] = empty),
            verify: () => expect(tb.rootElement.querySelectorAll('li').length).toEqual(100));
      }));
    });
  });
}

var UL_REPEATER =
"""
<ul class="well unstyled">
    <li ng-repeat="item in items" ng-class="classFor(item)">
        <label class="checkbox">
            <input type="checkbox" ng-model="item.done"> {{item.text}}
        </label>
    </li>
</ul>
""";
