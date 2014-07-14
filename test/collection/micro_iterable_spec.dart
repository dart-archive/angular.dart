library micro_iterable_spec;

import '../_specs.dart';
import 'package:angular/collection/micro_iterable.dart';

void main() {
  describe('MicroIterable', () {
    MicroIterable iterable;

    beforeEach(() {
      iterable = new MicroIterable(1,2,3,4,5,6,7,8,null, null, null, null, null, null, null, null, null, null, null, null, 8);
    });

    it('should have length', () {
      expect(iterable.length).toBe(8);
    });

    it('should not be empty', () {
      expect(iterable.isNotEmpty).toBe(true);
    });

    it('should be able to get a list', () {
      var list = iterable.toList();
      expect(list).toEqual([1,2,3,4,5,6,7,8]);
      expect(() {
        list.add('foo');
      }).not.toThrow();
    });

    it('should be able to get a fixed size list', () {
      var list = iterable.toList(growable: false);
      expect(list).toEqual([1,2,3,4,5,6,7,8]);
      expect(() {
        list.add('foo');
      }).toThrow();
    });

    it('should take specified number of elements', () {
      expect(iterable.take(4)).toEqual([1,2,3,4]);
    });

    it('should join elements', () {
      expect(iterable.join(", ")).toEqual("1, 2, 3, 4, 5, 6, 7, 8");
    });

    it('should work with methods provided by IterableMixin', () {
      expect(iterable.takeWhile((value) => value < 6)).toEqual([1,2,3,4,5]);
    });

    it('should iterate correctly', () {
      Iterator iter = iterable.iterator;
      expect(iter.current).toBe(null);
      expect(iter.moveNext()).toBe(true);
      expect(iter.current).toBe(1);
      expect(iter.moveNext()).toBe(true);
      expect(iter.current).toBe(2);
      expect(iter.moveNext()).toBe(true);
      expect(iter.current).toBe(3);
      expect(iter.moveNext()).toBe(true);
      expect(iter.current).toBe(4);
      expect(iter.moveNext()).toBe(true);
      expect(iter.current).toBe(5);
      expect(iter.moveNext()).toBe(true);
      expect(iter.current).toBe(6);
      expect(iter.moveNext()).toBe(true);
      expect(iter.current).toBe(7);
      expect(iter.moveNext()).toBe(true);
      expect(iter.current).toBe(8);
      expect(iter.moveNext()).toBe(false);
      expect(iter.current).toBe(null);
    });
  });
}