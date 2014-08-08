library micro_map_spec;

import '../_specs.dart';
import 'package:angular/collection/micro_map.dart';

void main() {
  insert(Map map, int start, int end) {
    List alphabet = ['0', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's',
        't', 'u', 'v', 'w', 'x', 'y', 'z'];
    for(var i=start; i<=end; i++)  map[i] = alphabet[i];
  }
  describe('MicroMap', () {
    it('should behave as a map', () {
      MicroMap map = new MicroMap<num, String>();
      map[1] = 'a';
      expect(map.length).toBe(1);
      expect(map.toString()).toEqual('{1: a}');
      expect(map.mode).toEqual(MODE_ARRAY);

      map[2] = 'b';
      expect(map.length).toBe(2);
      expect(map.toString()).toEqual('{1: a, 2: b}');
      expect(map.mode).toEqual(MODE_ARRAY);

      map[3] = 'c';
      expect(map.length).toBe(3);
      expect(map.toString()).toEqual('{1: a, 2: b, 3: c}');
      expect(map.mode).toEqual(MODE_ARRAY);

      insert(map, 4, 21);
      expect(map.length).toBe(21);
      expect(map).toEqual({1: 'a', 2: 'b', 3: 'c', 4: 'd', 5: 'e', 6: 'f', 7: 'g', 8: 'h', 9: 'i', 10: 'j', 11: 'k',
           12: 'l', 13: 'm', 14: 'n', 15: 'o', 16: 'p', 17: 'q', 18: 'r', 19: 's', 20: 't', 21: 'u'});
      expect(map.mode).toEqual(MODE_MAP);

      map.remove(21);
      expect(map.length).toBe(20);
      expect(map.toString()).toEqual('{1: a, 2: b, 3: c, 4: d, 5: e, 6: f, 7: g, 8: h, 9: i, 10: j, 11: k,'
      ' 12: l, 13: m, 14: n, 15: o, 16: p, 17: q, 18: r, 19: s, 20: t}');
      // once map mode has been hit it stays.
      expect(map.mode).toEqual(MODE_MAP);

      map.remove(20);
      map.remove(19);
      map.remove(18);
      map.remove(17);
      map.remove(16);
      expect(map.length).toBe(15);
      expect(map.toString()).toEqual('{1: a, 2: b, 3: c, 4: d, 5: e, 6: f, 7: g, 8: h, 9: i, 10: j, 11: k,'
      ' 12: l, 13: m, 14: n, 15: o}');
      // once map mode has been hit it stays.
      expect(map.mode).toEqual(MODE_MAP);
    });

    describe('mode', () {
      MicroMap map = new MicroMap();

      beforeEach(() {
        insert(map, 1, 20);
      });

      it('should switch to map mode', () {
        map[21] = '21';
        expect(map.mode).toBe(MODE_MAP);
      });
    });

    describe('add elements', () {
      MicroMap map;

      beforeEach(() {
        map = new MicroMap();
        map[1] = '1';
      });

      afterEach(() {
        map = null;
      });

      it('should add element using bracket notation', () {
        map[2] = 'nd';
        expect(map.length).toBe(2);
        expect(map[2]).toEqual('nd');
      });

      it('should add element which does not exist when using putIfAbsent', () {
        map.putIfAbsent(2, () => 'second');
        expect(map.length).toBe(2);
        expect(map[2]).toEqual('second');
        expect(map.mode).toBe(MODE_ARRAY);
      });

      it('should not add element which already exists when using putIfAbsent', () {
        map.putIfAbsent(1, () => 'foo');
        expect(map[1]).toEqual('1');
        map[2] = '2';
        map[3] = '3';
        map.putIfAbsent(3, () => 'foo');
        expect(map[3]).toBe('3');
      });

      it('should overwrite existing value', () {
        map[1] = 'foo';
        expect(map.length).toBe(1);
        expect(map.mode).toBe(MODE_ARRAY);
      });

      it('null key is valid', () {
        map[null] = 'bar';
        expect(map.length).toBe(2);
      });
    });

    describe('add all elements', () {
      MicroMap map;

      beforeEach(() {
        map = new MicroMap();
      });

      it('should add all elements', () {
        Map<int, String> other = <int, String>{1 : 'first', 2: 'second', 3: 'third'};
        map.addAll(other);
        expect(map.length).toBe(3);
        expect(map[1]).toBe('first');
        expect(map[2]).toBe('second');
        expect(map[3]).toBe('third');
        expect(map.mode).toBe(MODE_ARRAY);
      });

      it('should add all elements', () {
        Map<int, String> other = <int, String>{1 : 'first', 2: 'second', 3: 'third', 4:'fourth', 5:'fifth'};
        map.addAll(other);
        expect(map.length).toBe(5);
        expect(map[1]).toBe('first');
        expect(map[2]).toBe('second');
        expect(map[3]).toBe('third');
        expect(map[4]).toBe('fourth');
        expect(map[5]).toBe('fifth');
        expect(map.mode).toBe(MODE_ARRAY);
      });

      it('should add to existing elements', () {
        insert(map, 1, 18);
        Map<int, String> other = <int, String>{19: '19', 20: '20'};
        map.addAll(other);
        expect(map.length).toBe(20);
        expect(map.mode).toBe(MODE_ARRAY);
      });

      it('should add to existing elements', () {
        insert(map, 1, 18);
        Map<int, String> other = <int, String>{19: '19', 20: '20', 21: '21'};
        map.addAll(other);
        expect(map.length).toBe(21);
        expect(map.mode).toBe(MODE_MAP);
      });

      it('should overwrite elements with same key', () {
        map[1] = 'first';
        map[2] = 'second';
        Map<int, String> other = <int, String>{1: 'foo', 3:'bar', 4:'baz'};
        map.addAll(other);
        expect(map.length).toBe(4);
        expect(map[1]).toBe('foo');
        expect(map[2]).toBe('second');
        expect(map[3]).toBe('bar');
        expect(map[4]).toBe('baz');
        expect(map.mode).toBe(MODE_ARRAY);
      });
    });

    describe('clear', () {
      it('should length 0 after clearing', () {
        MicroMap map = new MicroMap();
        insert(map, 0, 15);
        map.clear();
        expect(map.length).toBe(0);
      });
    });

    describe('remove', () {
      it('should return null when removing element which does not exist', () {
        MicroMap map = new MicroMap();
        expect(map.remove(1)).toBeNull();
      });

      it('should not get confused by a null key or value', () {
        MicroMap map = new MicroMap();
        map[null] = null;
        map[1] = 'foo';

        expect(map.remove(null)).toBe(null);
        expect(map.length).toBe(1);
        expect(map[1]).toBe('foo');

        expect(map.remove(null)).toBe(null);
        expect(map.length).toBe(1);
      });
    });

    describe('iterables', () {
     it('should return iterables of the right size', () {
       MicroMap map = new MicroMap();
       map[2] = 3;
       expect(map.keys).toEqual([2]);
     });

     it('should change mode when iterable is requested', () {
       MicroMap map = new MicroMap();
       var iter = map.keys;
       expect(map.mode).toEqual(MODE_MAP);
     });
    });
  });
}
