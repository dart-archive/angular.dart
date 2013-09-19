library cache_spec;

import '_specs.dart';

main() => describe('CacheFactory', () {

  describe('cache', () {
    var cache;

    beforeEach(inject(() {
      cache = new Cache();
    }));


    describe('put, get & remove', () {

      it('should add cache entries via add and retrieve them via get', inject(() {
        cache.put('key1', 'bar');
        cache.put('key2', {'bar':'baz'});

        expect(cache.get('key2')).toEqual({'bar':'baz'});
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


      it('should return undefined when entry does not exist', inject(() {
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
});
