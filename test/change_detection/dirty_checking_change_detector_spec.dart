library dirty_chekcing_change_detector_spec;

import '../_specs.dart';
import 'package:angular/change_detection/change_detection.dart';
import 'package:angular/change_detection/dirty_checking_change_detector.dart';
import 'dart:collection';

main() => describe('DirtyCheckingChangeDetector', () {
  DirtyCheckingChangeDetector<String> detector;

  beforeEach(() {
    GetterCache getterCache = new GetterCache({
      "first": (o) => o.first,
      "age": (o) => o.age
    });
    detector = new DirtyCheckingChangeDetector<String>(getterCache);
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

      // force different instance
      user.first = 'mis';
      user.first += 'ko';

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
      expect(detector.collectChanges(), toEqualChanges(['0a', '0A', '1a', '1A', '2A', '1b']));

      obj['a'] = 2;
      child1a.remove(); // should also remove child2
      expect(detector.collectChanges(), toEqualChanges(['0a', '0A', '1b']));
    });

    it('should add watches within its own group', () {
      var obj = {};
      var ra = detector.watch(obj, 'a', 'a');
      var child = detector.newGroup();
      var cb = child.watch(obj,'b', 'b');

      obj['a'] = obj['b'] = 1;
      expect(detector.collectChanges(), toEqualChanges(['a', 'b']));

      obj['a'] = obj['b'] = 2;
      ra.remove();
      expect(detector.collectChanges(), toEqualChanges(['b']));

      obj['a'] = obj['b'] = 3;
      cb.remove();
      expect(detector.collectChanges(), toEqualChanges([]));

      // TODO: add them back in wrong order, assert events in right order
      cb = child.watch(obj,'b', 'b');
      ra = detector.watch(obj, 'a', 'a');
      obj['a'] = obj['b'] = 4;
      expect(detector.collectChanges(), toEqualChanges(['a', 'b']));
    });
  });

  describe('list watching', () {
    it('should detect changes in list', () {
      var list = [];
      var record = detector.watch(list, null, 'handler');
      expect(detector.collectChanges()).toEqual(null);

      list.add('a');
      expect(detector.collectChanges().currentValue, toEqualCollectionRecord(
          collection: ['a[null -> 0]'],
          additions: ['a[null -> 0]'],
          moves: [],
          removals: []));

      list.add('b');
      expect(detector.collectChanges().currentValue, toEqualCollectionRecord(
          collection: ['a', 'b[null -> 1]'],
          additions: ['b[null -> 1]'],
          moves: [],
          removals: []));

      list.add('c');
      list.add('d');
      expect(detector.collectChanges().currentValue, toEqualCollectionRecord(
          collection: ['a', 'b', 'c[null -> 2]', 'd[null -> 3]'],
          additions: ['c[null -> 2]', 'd[null -> 3]'],
          moves: [],
          removals: []));

      list.remove('c');
      expect(list).toEqual(['a', 'b', 'd']);
      expect(detector.collectChanges().currentValue, toEqualCollectionRecord(
          collection: ['a', 'b', 'd[3 -> 2]'],
          additions: [],
          moves: ['d[3 -> 2]'],
          removals: ['c[2 -> null]']));

      list.clear();
      list.addAll(['d', 'c', 'b', 'a']);
      expect(detector.collectChanges().currentValue, toEqualCollectionRecord(
          collection: ['d[2 -> 0]', 'c[null -> 1]', 'b[1 -> 2]', 'a[0 -> 3]'],
          additions: ['c[null -> 1]'],
          moves: ['d[2 -> 0]', 'b[1 -> 2]', 'a[0 -> 3]'],
          removals: []));
    });

    it('should detect changes in list', () {
      var list = [];
      var record = detector.watch(list.map((i) => i), null, 'handler');
      expect(detector.collectChanges()).toEqual(null);

      list.add('a');
      expect(detector.collectChanges().currentValue, toEqualCollectionRecord(
          collection: ['a[null -> 0]'],
          additions: ['a[null -> 0]'],
          moves: [],
          removals: []));

      list.add('b');
      expect(detector.collectChanges().currentValue, toEqualCollectionRecord(
          collection: ['a', 'b[null -> 1]'],
          additions: ['b[null -> 1]'],
          moves: [],
          removals: []));

      list.add('c');
      list.add('d');
      expect(detector.collectChanges().currentValue, toEqualCollectionRecord(
          collection: ['a', 'b', 'c[null -> 2]', 'd[null -> 3]'],
          additions: ['c[null -> 2]', 'd[null -> 3]'],
          moves: [],
          removals: []));

      list.remove('c');
      expect(list).toEqual(['a', 'b', 'd']);
      expect(detector.collectChanges().currentValue, toEqualCollectionRecord(
          collection: ['a', 'b', 'd[3 -> 2]'],
          additions: [],
          moves: ['d[3 -> 2]'],
          removals: ['c[2 -> null]']));

      list.clear();
      list.addAll(['d', 'c', 'b', 'a']);
      expect(detector.collectChanges().currentValue, toEqualCollectionRecord(
          collection: ['d[2 -> 0]', 'c[null -> 1]', 'b[1 -> 2]', 'a[0 -> 3]'],
          additions: ['c[null -> 1]'],
          moves: ['d[2 -> 0]', 'b[1 -> 2]', 'a[0 -> 3]'],
          removals: []));
    });

    it('should remove and add same item', () {
      var list = ['a', 'b', 'c'];
      var record = detector.watch(list, null, 'handler');
      detector.collectChanges();

      list.remove('b');
      expect(detector.collectChanges().currentValue, toEqualCollectionRecord(
          collection: ['a', 'c[2 -> 1]'],
          additions: [],
          moves: ['c[2 -> 1]'],
          removals: ['b[1 -> null]']));

      list.insert(1, 'b');
      expect(list).toEqual(['a', 'b', 'c']);
      expect(detector.collectChanges().currentValue, toEqualCollectionRecord(
          collection: ['a', 'b[null -> 1]', 'c[1 -> 2]'],
          additions: ['b[null -> 1]'],
          moves: ['c[1 -> 2]'],
          removals: []));
    });

    it('should support duplicates', () {
      var list = ['a', 'a', 'a', 'b', 'b'];
      var record = detector.watch(list, null, 'handler');
      detector.collectChanges();

      list.removeAt(0);
      expect(detector.collectChanges().currentValue, toEqualCollectionRecord(
          collection: ['a', 'a', 'b[3 -> 2]', 'b[4 -> 3]'],
          additions: [],
          moves: ['b[3 -> 2]', 'b[4 -> 3]'],
          removals: ['a[2 -> null]']));
    });


    it('should support insertions/moves', () {
      var list = ['a', 'a', 'b', 'b'];
      var record = detector.watch(list, null, 'handler');
      detector.collectChanges();
      list.insert(0, 'b');
      expect(list).toEqual(['b', 'a', 'a', 'b', 'b']);
      // todo(vbe) There is something wrong when running this test w/ karma
//      expect(detector.collectChanges().currentValue, toEqualCollectionRecord(
//          collection: ['b[2 -> 0]', 'a[0 -> 1]', 'a[1 -> 2]', 'b', 'b[null -> 4]'],
//          additions: ['b[null -> 4]'],
//          moves: ['b[2 -> 0]', 'a[0 -> 1]', 'a[1 -> 2]'],
//          removals: []));
    });

    it('should support UnmodifiableListView', () {
      var hiddenList = [1];
      var list = new UnmodifiableListView(hiddenList);
      var record = detector.watch(list, null, 'handler');
      expect(detector.collectChanges().currentValue, toEqualCollectionRecord(
          collection: ['1[null -> 0]'],
          additions: ['1[null -> 0]'],
          moves: [],
          removals: []));

      // assert no changes detected
      expect(detector.collectChanges()).toEqual(null);

      // change the hiddenList normally this should trigger change detection
      // but because we are wrapped in UnmodifiableListView we see nothing.
      hiddenList[0] = 2;
      expect(detector.collectChanges()).toEqual(null);
    });
  });

  describe('map watching', () {
    xit('should do basic map watching', () {
      var map = {};
      var record = detector.watch(map, null, 'handler');
      expect(detector.collectChanges()).toEqual(null);

      map['a'] = 'A';
      expect(detector.collectChanges().currentValue, toEqualCollectionRecord(
          collection: ['a[null -> 0]'],
          additions: ['a[null -> 0]'],
          moves: [],
          removals: []));

      map['b'] = 'B';
      expect(detector.collectChanges().currentValue, toEqualCollectionRecord(
          collection: ['a', 'b[null -> 1]'],
          additions: ['b[null -> 1]'],
          moves: [],
          removals: []));

      map['c'] = 'C';
      map['d'] = 'D';
      expect(detector.collectChanges().currentValue, toEqualCollectionRecord(
          collection: ['a', 'b', 'c[null -> 2]', 'd[null -> 3]'],
          additions: ['c[null -> 2]', 'd[null -> 3]'],
          moves: [],
          removals: []));

      map.remove('c');
      expect(map).toEqual(['a', 'b', 'd']);
      expect(detector.collectChanges().currentValue, toEqualCollectionRecord(
          collection: ['a', 'b', 'd[3 -> 2]'],
          additions: [],
          moves: ['d[3 -> 2]'],
          removals: ['c[2 -> null]']));

      map.clear();
      map.addAll(['d', 'c', 'b', 'a']);
      expect(detector.collectChanges().currentValue, toEqualCollectionRecord(
          collection: ['d[2 -> 0]', 'c[null -> 1]', 'b[1 -> 2]', 'a[0 -> 3]'],
          additions: ['c[null -> 1]'],
          moves: ['d[2 -> 0]', 'b[1 -> 2]', 'a[0 -> 3]'],
          removals: []));
    });
  });

  describe('DuplicateMap', () {
    DuplicateMap map;
    beforeEach(() => map = new DuplicateMap());

    it('should do basic operations', () {
      var k1 = 'a';
      var r1 = new ItemRecord(k1);
      r1.currentKey = 1;
      map.put(r1);
      expect(map.get(k1, 2)).toEqual(null);
      expect(map.get(k1, 1)).toEqual(null);
      expect(map.get(k1, 0)).toEqual(r1);
      expect(map.remove(r1)).toEqual(r1);
      expect(map.get(k1, -1)).toEqual(null);
    });

    it('should do basic operations on duplicate keys', () {
      var k1 = 'a';
      var r1 = new ItemRecord(k1);
      var r2 = new ItemRecord(k1);
      r1.currentKey = 1;
      r2.currentKey = 2;
      map.put(r1);
      map.put(r2);
      expect(map.get(k1, 0)).toEqual(r1);
      expect(map.get(k1, 1)).toEqual(r2);
      expect(map.get(k1, 2)).toEqual(null);
      expect(map.remove(r2)).toEqual(r2);
      expect(map.get(k1, 0)).toEqual(r1);
      expect(map.remove(r1)).toEqual(r1);
      expect(map.get(k1, 0)).toEqual(null);
    });
  });
});

class _User {
  String first;
  String last;
  num age;

  _User([this.first, this.last, this.age]);
}

Matcher toEqualCollectionRecord({collection, additions, moves, removals}) =>
    new CollectionRecordMatcher(collection:collection, additions:additions,
                                moves:moves, removals:removals);
Matcher toEqualChanges(List changes) => new ChangeMatcher(changes);

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

class CollectionRecordMatcher extends Matcher {
  List collection;
  List additions;
  List moves;
  List removals;

  CollectionRecordMatcher({this.collection, this.additions, this.moves, this.removals});

  Description describeMismatch(changes, Description mismatchDescription, Map matchState, bool verbose) {
    List diffs = matchState['diffs'];
    return mismatchDescription..add(diffs.join('\n'));
  }

  Description describe(Description description) {
    add(name, collection) {
      if (collection != null) {
        description.add('$name: ${collection.join(', ')}\n   ');
      }
    }

    add('collection', collection);
    add('additions', additions);
    add('moves', moves);
    add('removals', removals);
    return description;
  }

  bool matches(CollectionChangeRecord changeRecord, Map matchState) {
    List diffs = matchState['diffs'] = [];
    var equals = true;
    equals = equals && checkCollection(changeRecord, diffs);
    equals = equals && checkAdditions(changeRecord, diffs);
    equals = equals && checkMoves(changeRecord, diffs);
    equals = equals && checkRemovals(changeRecord, diffs);
    return equals;
  }

  checkCollection(CollectionChangeRecord changeRecord, List diffs) {
    var equals = true;
    if (collection != null) {
      CollectionItem collectionItem = changeRecord.collectionHead;
      for(var item in collection) {
        if (collectionItem == null) {
          equals = false;
          diffs.add('collection too short: $item');
        } else {
          if (collectionItem.toString() != item) {
            equals = false;
            diffs.add('collection mismatch: $collectionItem != $item');
          }
          collectionItem = collectionItem.nextCollectionItem;
        }
      }
      if (collectionItem != null) {
        diffs.add('collection too long: $collectionItem');
        equals = false;
      }
    }
    return equals;
  }

  checkAdditions(CollectionChangeRecord changeRecord, List diffs) {
    var equals = true;
    if (additions != null) {
      AddedItem addedItem = changeRecord.additionsHead;
      for(var item in additions) {
        if (addedItem == null) {
          equals = false;
          diffs.add('additions too short: $item');
        } else {
          if (addedItem.toString() != item) {
            equals = false;
            diffs.add('additions mismatch: $addedItem != $item');
          }
          addedItem = addedItem.nextAddedItem;
        }
      }
      if (addedItem != null) {
        equals = false;
        diffs.add('additions too long: $addedItem');
      }
    }
    return equals;
  }

  checkMoves(CollectionChangeRecord changeRecord, List diffs) {
    var equals = true;
    if (moves != null) {
      MovedItem movedItem = changeRecord.movesHead;
      for(var item in moves) {
        if (movedItem == null) {
          equals = false;
          diffs.add('moves too short: $item');
        } else {
          if (movedItem.toString() != item) {
            equals = false;
            diffs.add('moves too mismatch: $movedItem != $item');
          }
          movedItem = movedItem.nextMovedItem;
        }
      }
      if (movedItem != null) {
        equals = false;
        diffs.add('moves too long: $movedItem');
      }
    }
    return equals;
  }

  checkRemovals(CollectionChangeRecord changeRecord, List diffs) {
    var equals = true;
    if (removals != null) {
      RemovedItem removedItem = changeRecord.removalsHead;
      for(var item in removals) {
        if (removedItem == null) {
          equals = false;
          diffs.add('removes too short: $item');
        } else {
          if (removedItem.toString() != item) {
            equals = false;
            diffs.add('removes too mismatch: $removedItem != $item');
          }
          removedItem = removedItem.nextRemovedItem;
        }
      }
      if (removedItem != null) {
        equals = false;
        diffs.add('removes too long: $removedItem');
      }
    }
    return equals;
  }
}
