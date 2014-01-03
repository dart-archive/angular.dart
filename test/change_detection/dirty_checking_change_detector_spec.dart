library dirty_chekcing_change_detector_spec;

import '../_specs.dart';
import 'package:angular/change_detection/dirty_checking_change_detector.dart';

main() => ddescribe('DirtyCheckingChangeDetector', () {
  DirtyCheckingChangeDetector<String> detector;

  beforeEach(() {
    detector = new DirtyCheckingChangeDetector<String>();
  });

  describe('object field', () {
    it('should detect nothing', () {
      var changes = detector.collectChanges();
      expect(changes).toEqual(null);
    });

    it('should detect field changes', () {
      var user = new _User('', '');
      var change;

      detector.watch(user, 'first', null);
      detector.watch(user, 'last', null);
      detector.collectChanges(); // throw away first set

      change = detector.collectChanges();
      expect(change).toEqual(null);
      user.first = 'misko';
      user.last = 'hevery';

      change = detector.collectChanges();
      expect(change.currentValue).toEqual('misko');
      expect(change.previousValue).toEqual('');
      expect(change.nextChange.currentValue).toEqual('hevery');
      expect(change.nextChange.previousValue).toEqual('');
      expect(change.nextChange.nextChange).toEqual(null);

      user.first = 'mis';
      user.first += 'ko'; // force different instance;

      change = detector.collectChanges();
      expect(change).toEqual(null);

      user.last = 'Hevery';
      change = detector.collectChanges();
      expect(change.currentValue).toEqual('Hevery');
      expect(change.previousValue).toEqual('hevery');
      expect(change.nextChange).toEqual(null);
    });

    it('should ignore NaN != NaN', () {
      var user = new _User();
      user.age = double.NAN;
      detector.watch(user, 'age', null);
      detector.collectChanges(); // throw away first set

      var changes = detector.collectChanges();
      expect(changes).toEqual(null);

      user.age = 123;
      changes = detector.collectChanges();
      expect(changes.currentValue).toEqual(123);
      expect(changes.previousValue.isNaN).toEqual(true);
      expect(changes.nextChange).toEqual(null);
    });

    it('should treat map field dereference as []', () {
      var obj = {'name':'misko'};
      detector.watch(obj, 'name', null);
      detector.collectChanges(); // throw away first set

      obj['name'] = 'Misko';
      var changes = detector.collectChanges();
      expect(changes.currentValue).toEqual('Misko');
      expect(changes.previousValue).toEqual('misko');
    });
  });

  describe('insertions / removals', () {
    it('should insert at the end of list', () {
      var obj = {};
      var a = detector.watch(obj, 'a', 'a');
      var b = detector.watch(obj, 'b', 'b');

      obj['a'] = obj['b'] = 1;
      var changes = detector.collectChanges();
      expect(changes.handler).toEqual('a');
      expect(changes.nextChange.handler).toEqual('b');
      expect(changes.nextChange.nextChange).toEqual(null);

      obj['a'] = obj['b'] = 2;
      a.remove();
      changes = detector.collectChanges();
      expect(changes.handler).toEqual('b');
      expect(changes.nextChange).toEqual(null);

      obj['a'] = obj['b'] = 3;
      b.remove();
      changes = detector.collectChanges();
      expect(changes).toEqual(null);
    });

    it('should remove all watches in group and group\'s children', () {
      var obj = {};
      detector.watch(obj, 'a', '0a');
      var child1a = detector.newGroup();
      var child1b = detector.newGroup();
      var child2 = child1a.newGroup();
      child1a.watch(obj,'a', '1a');
      child1b.watch(obj,'a', '1b');
      detector.watch(obj, 'a', '0A');
      child1a.watch(obj,'a', '1A');
      child2.watch(obj,'a', '2A');

      obj['a'] = 1;
      expect(detector.collectChanges(), toEqualsChanges(['0a', '0A', '1a', '1A', '2A', '1b']));

      obj['a'] = 2;
      child1a.remove(); // should also remove child2
      expect(detector.collectChanges(), toEqualsChanges(['0a', '0A', '1b']));
    });

    it('should add watches within its own group', () {
      var obj = {};
      var ra = detector.watch(obj, 'a', 'a');
      var child = detector.newGroup();
      var cb = child.watch(obj,'b', 'b');

      obj['a'] = obj['b'] = 1;
      expect(detector.collectChanges(), toEqualsChanges(['a', 'b']));

      obj['a'] = obj['b'] = 2;
      ra.remove();
      expect(detector.collectChanges(), toEqualsChanges(['b']));

      obj['a'] = obj['b'] = 3;
      cb.remove();
      expect(detector.collectChanges(), toEqualsChanges([]));

      // TODO: add them back in wrong order, assert events in right order
      cb = child.watch(obj,'b', 'b');
      ra = detector.watch(obj, 'a', 'a');
      obj['a'] = obj['b'] = 4;
      expect(detector.collectChanges(), toEqualsChanges(['a', 'b']));
    });
  });

  describe('list watching', () {

  });

  describe('map watching', () {

  });
});

class _User {
  String first;
  String last;
  num age;

  _User([this.first, this.last, this.age]);
}

Matcher toEqualsChanges(List changes) => new ChangeMatcher(changes);

class ChangeMatcher extends Matcher {
  List expected;

  ChangeMatcher(this.expected);

  Description describe(Description description) => description..add(expected.toString());

  Description describeMismatch(changes, Description mismatchDescription, Map matchState, bool verbose) {
    List list = [];
    while(changes != null) {
      list.add(changes.handler);
      changes = changes.nextChange;
    }
    return mismatchDescription..add(list.toString());
  }

  bool matches(changes, Map matchState) {
    int count = 0;
    while(changes != null) {
      if (changes.handler != expected[count++]) return false;
      changes = changes.nextChange;
    }
    return count == expected.length;
  }
}
