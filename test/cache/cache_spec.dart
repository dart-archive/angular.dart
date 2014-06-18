library cache_spec;

import '../_specs.dart';

void main() {
  describe('CacheFactory', () {

    describe('cache', () {
      Cache<String, Object> cache;

      beforeEach(() {
        cache = new LruCache<String, Object>();
      });


      describe('put, get & remove', () {
        it('should add cache entries via add and retrieve them via get', () {
          var obj = {'bar':'baz'};
          cache.put('key1', 'bar');
          cache.put('key2', obj);

          expect(cache.get('key2')).toBe(obj);
          expect(cache.get('key1')).toBe('bar');
        });


        it('should remove entries via remove', () {
          cache.put('k1', 'foo');
          cache.put('k2', 'bar');

          cache.remove('k2');

          expect(cache.get('k1')).toBe('foo');
          expect(cache.get('k2')).toBeNull();

          cache.remove('k1');

          expect(cache.get('k1')).toBeNull();
          expect(cache.get('k2')).toBeNull();
        });


        it('should return null when entry does not exist', () {
          expect(cache.remove('non-existent')).toBeNull();
        });


        // TODO(chirayu): to implement
        // it('should stringify keys', () {
        //   cache.put('123', 'foo');
        //   cache.put(123, 'bar');

        //   expect(cache.get('123')).toBe('bar');
        //   expect(cache.info().size).toBe(1);

        //   cache.remove(123);
        //   expect(cache.info().size).toBe(0);
        // });


        it("should return value from put", () {
          var obj = {};
          expect(cache.put('k1', obj)).toBe(obj);
        });
      });


      describe('put, get & remove', () {

        it('should add cache entries via add and retrieve them via get', inject(() {
          var obj = {'bar':'baz'};
          cache.put('key1', 'bar');
          cache.put('key2', obj);

          expect(cache.get('key2')).toBe(obj);
          expect(cache.get('key1')).toBe('bar');
        }));


        it('should remove entries via remove', inject(() {
          cache.put('k1', 'foo');
          cache.put('k2', 'bar');

          cache.remove('k2');

          expect(cache.get('k1')).toBe('foo');
          expect(cache.get('k2')).toBeNull();

          cache.remove('k1');

          expect(cache.get('k1')).toBeNull();
          expect(cache.get('k2')).toBeNull();
        }));


        it('should return null when entry does not exist', inject(() {
          expect(cache.remove('non-existent')).toBeNull();
        }));

        it("should return value from put", inject(() {
          var obj = {};
          expect(cache.put('k1', obj)).toBe(obj);
        }));
      });


      describe('removeAll', () {
        it('should blow away all data', inject(() {
          cache.put('id1', 1);
          cache.put('id2', 2);
          cache.put('id3', 3);

          cache.removeAll();

          expect(cache.get('id1')).toBeNull();
          expect(cache.get('id2')).toBeNull();
          expect(cache.get('id3')).toBeNull();
        }));
      });
    });

    // TODO(chirayu): Add a lot more tests and tests and don't rely on toString()
    describe('LRU cache', () {
      it('should have LRU behavior with ordering keys and eviction', inject(() {
        var cache = new LruCache<int, int>(capacity: 4);
        cache.put(1, 10);
        cache.put(2, 20);
        cache.put(3, 30);
        cache.put(4, 40);
        expect(cache.get(2)).toEqual(20);
        cache.put(5, 50);
        cache.put(6, 60);
        expect(cache.get(5)).toEqual(50);
        cache.put(7, 70);
        cache.put(8, 80);
        // 1 has been evicted.
        expect(cache.get(1)).toBeNull();
        // The order of items is LRU to MRU.
        expect("$cache").toEqual(
            r"[LruCache<int, int>: capacity=4, size=4, items={6: 60, 5: 50, 7: 70, 8: 80}]");
        cache.removeAll();
        expect("$cache").toEqual(r"[LruCache<int, int>: capacity=4, size=0, items={}]");

        var stats = cache.stats();
        expect(stats.capacity).toEqual(4);
        expect(stats.size).toEqual(0);
        expect(stats.hits).toEqual(2);
        expect(stats.misses).toEqual(1);
      }));

      it('should hold nothing if capacity is zero', () {
        var cache = new LruCache<int, int>(capacity: 0);
        cache.put(1, 10);
        expect(cache.get(1)).toBeNull();
      });
    });
  });
}
