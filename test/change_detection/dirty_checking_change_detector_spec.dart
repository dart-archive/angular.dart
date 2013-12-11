library dirty_chekcing_change_detector_spec;

import '../_specs.dart';
import 'package:angular/change_detection/change_detection.dart';
import 'package:angular/change_detection/dirty_checking_change_detector.dart';

main() => ddescribe('DirtyCheckingChangeDetector', () {
  DirtyCheckingChangeDetector<String, String> detector;

  beforeEach(() {
    detector = new DirtyCheckingChangeDetector<String, String>();
  });

  describe('object field', () {
    it('should detect nothing', () {
      var changes = detector.collectChanges();
      expect(changes).toEqual(null);
    });

    it('should detect field changes', () {
      var user = new _User('', '');
      var changes;

      detector.watch(user, 'first', '1', 'first');
      detector.watch(user, 'last', '2', 'last');

      changes = detector.collectChanges();
      expect(changes).toEqual(null);
      user.first = 'misko';
      user.last = 'hevery';

      changes = detector.collectChanges();
      expect(changes.currentValue).toEqual('misko');
      expect(changes.previousValue).toEqual('');
      expect(changes.next.currentValue).toEqual('hevery');
      expect(changes.next.previousValue).toEqual('');
      expect(changes.next.next).toEqual(null);

      user.first = 'mis';
      user.first += 'ko'; // force differente instance;

      changes = detector.collectChanges();
      expect(changes).toEqual(null);

      user.last = 'Hevery';
      changes = detector.collectChanges();
      expect(changes.currentValue).toEqual('Hevery');
      expect(changes.previousValue).toEqual('hevery');
      expect(changes.next).toEqual(null);
    });

    it('should ignore NaN != NaN', () {
      var user = new _User();
      user.age = double.NAN;
      detector.watch(user, 'age', '1', 'age');
      var changes = detector.collectChanges();
      expect(changes).toEqual(null);

      user.age = 123;
      changes = detector.collectChanges();
      expect(changes.currentValue).toEqual(123);
      expect(changes.previousValue.isNaN).toEqual(true);
      expect(changes.next).toEqual(null);
    });

    it('should treat map field dereference as []', () {
      var obj = {'name':'misko'};
      detector.watch(obj, 'name', '1', 'name');

      obj['name'] = 'Misko';
      var changes = detector.collectChanges();
      expect(changes.currentValue).toEqual('Misko');
      expect(changes.previousValue).toEqual('misko');
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
