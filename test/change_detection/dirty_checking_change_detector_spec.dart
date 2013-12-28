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
      user.first += 'ko'; // force differente instance;

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
    });
  });

  describe('list watching', () {

  });

  describe('map watching', () {

  });

  describe('remove', () {

  });
});

class _User {
  String first;
  String last;
  num age;

  _User([this.first, this.last, this.age]);
}
