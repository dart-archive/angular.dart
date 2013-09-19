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


  xdescribe('LRU cache', () {

    it('should create cache with defined capacity', inject(() {
      cache = $cacheFactory('cache1', {'capacity': 5});
      expect(cache.info().size).toBe(0);

      for (var i=0; i<5; i++) {
        cache.put('id' + i, i);
      }

      expect(cache.info().size).toBe(5);

      cache.put('id5', 5);
      expect(cache.info().size).toBe(5);
      cache.put('id6', 6);
      expect(cache.info().size).toBe(5);
    }));


    describe('eviction', () {

      beforeEach(inject(() {
        cache = $cacheFactory('cache1', {'capacity': 2});

        cache.put('id0', 0);
        cache.put('id1', 1);
      }));


      it('should kick out the first entry on put', inject(() {
        cache.put('id2', 2);
        expect(cache.get('id0')).toBeNull();
        expect(cache.get('id1')).toBe(1);
        expect(cache.get('id2')).toBe(2);
      }));


      it('should refresh an entry via get', inject(() {
        cache.get('id0');
        cache.put('id2', 2);
        expect(cache.get('id0')).toBe(0);
        expect(cache.get('id1')).toBeNull();
        expect(cache.get('id2')).toBe(2);
      }));


      it('should refresh an entry via put', inject(() {
        cache.put('id0', '00');
        cache.put('id2', 2);
        expect(cache.get('id0')).toBe('00');
        expect(cache.get('id1')).toBeNull();
        expect(cache.get('id2')).toBe(2);
      }));


      it('should not purge an entry if another one was removed', inject(() {
        cache.remove('id1');
        cache.put('id2', 2);
        expect(cache.get('id0')).toBe(0);
        expect(cache.get('id1')).toBeNull();
        expect(cache.get('id2')).toBe(2);
      }));


      it('should purge the next entry if the stalest one was removed', inject(() {
        cache.remove('id0');
        cache.put('id2', 2);
        cache.put('id3', 3);
        expect(cache.get('id0')).toBeNull();
        expect(cache.get('id1')).toBeNull();
        expect(cache.get('id2')).toBe(2);
        expect(cache.get('id3')).toBe(3);
      }));


      it('should correctly recreate the linked list if all cache entries were removed', inject(() {
        cache.remove('id0');
        cache.remove('id1');
        cache.put('id2', 2);
        cache.put('id3', 3);
        cache.put('id4', 4);
        expect(cache.get('id0')).toBeNull();
        expect(cache.get('id1')).toBeNull();
        expect(cache.get('id2')).toBeNull();
        expect(cache.get('id3')).toBe(3);
        expect(cache.get('id4')).toBe(4);
      }));


      it('should blow away the entire cache via removeAll and start evicting when full', inject(() {
        cache.put('id0', 0);
        cache.put('id1', 1);
        cache.removeAll();

        cache.put('id2', 2);
        cache.put('id3', 3);
        cache.put('id4', 4);

        expect(cache.info().size).toBe(2);
        expect(cache.get('id0')).toBeNull();
        expect(cache.get('id1')).toBeNull();
        expect(cache.get('id2')).toBeNull();
        expect(cache.get('id3')).toBe(3);
        expect(cache.get('id4')).toBe(4);
      }));


      it('should correctly refresh and evict items if operations are chained', inject(() {
        cache = $cacheFactory('cache2', {'capacity': 3});

        cache.put('id0', 0); //0
        cache.put('id1', 1); //1,0
        cache.put('id2', 2); //2,1,0
        cache.get('id0');    //0,2,1
        cache.put('id3', 3); //3,0,2
        cache.put('id0', 9); //0,3,2
        cache.put('id4', 4); //4,0,3

        expect(cache.get('id3')).toBe(3);
        expect(cache.get('id0')).toBe(9);
        expect(cache.get('id4')).toBe(4);

        cache.remove('id0'); //4,3
        cache.remove('id3'); //4
        cache.put('id5', 5); //5,4
        cache.put('id6', 6); //6,5,4
        cache.get('id4');    //4,6,5
        cache.put('id7', 7); //7,4,6

        expect(cache.get('id0')).toBeNull();
        expect(cache.get('id1')).toBeNull();
        expect(cache.get('id2')).toBeNull();
        expect(cache.get('id3')).toBeNull();
        expect(cache.get('id4')).toBe(4);
        expect(cache.get('id5')).toBeNull();
        expect(cache.get('id6')).toBe(6);
        expect(cache.get('id7')).toBe(7);

        cache.removeAll();
        cache.put('id0', 0); //0
        cache.put('id1', 1); //1,0
        cache.put('id2', 2); //2,1,0
        cache.put('id3', 3); //3,2,1

        expect(cache.info().size).toBe(3);
        expect(cache.get('id0')).toBeNull();
        expect(cache.get('id1')).toBe(1);
        expect(cache.get('id2')).toBe(2);
        expect(cache.get('id3')).toBe(3);
      }));
    });
  });
});
