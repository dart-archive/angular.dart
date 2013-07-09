import "_specs.dart";

main() => describe('CacheFactory', () {

  it('should be injected', inject((CacheFactory $cacheFactory) {
    expect($cacheFactory).toBeDefined();
  }));


  it('should return a new cache whenever called', inject((CacheFactory $cacheFactory) {
    var cache1 = $cacheFactory('cache1');
    var cache2 = $cacheFactory('cache2');
    expect(cache1).not.toBe(cache2);
  }));


  it('should complain if the cache id is being reused', inject((CacheFactory $cacheFactory) {
    $cacheFactory('cache1');
    expect(() { $cacheFactory('cache1'); }).
    toThrow("[\$cacheFactory:iid] CacheId 'cache1' is already taken!");
  }));


  describe('info', () {

    it('should provide info about all created caches', inject((CacheFactory $cacheFactory) {
      expect($cacheFactory.info()).toEqual({});

      var cache1 = $cacheFactory('cache1');
      expect($cacheFactory.info()).toEqual({'cache1': new CacheInfo(id: 'cache1',  size: 0)});

      cache1.put('foo', 'bar');
      expect($cacheFactory.info()).toEqual({'cache1': new CacheInfo(id: 'cache1', size: 1)});
    }));
  });


  describe('get', () {

    it('should return a cache if looked up by id', inject((CacheFactory $cacheFactory) {
      var cache1 = $cacheFactory('cache1'),
          cache2 = $cacheFactory('cache2');

      expect(cache1).not.toBe(cache2);
      expect(cache1).toBe($cacheFactory.get('cache1'));
      expect(cache2).toBe($cacheFactory.get('cache2'));
    }));
  });

  describe('cache', () {
    var cache;

    beforeEach(inject((CacheFactory $cacheFactory) {
      cache = $cacheFactory('test');
    }));


    describe('put, get & remove', () {

      it('should add cache entries via add and retrieve them via get', inject((CacheFactory $cacheFactory) {
        cache.put('key1', 'bar');
        cache.put('key2', {'bar':'baz'});

        expect(cache.get('key2')).toEqual({'bar':'baz'});
        expect(cache.get('key1')).toBe('bar');
      }));


      it('should ignore put if the value is null', inject((CacheFactory $cacheFactory) {
        cache.put('key2', null);

        expect(cache.info().size).toBe(0);
      }));


      it('should remove entries via remove', inject((CacheFactory $cacheFactory) {
        cache.put('k1', 'foo');
        cache.put('k2', 'bar');

        cache.remove('k2');

        expect(cache.get('k1')).toBe('foo');
        expect(cache.get('k2')).toBeNull();

        cache.remove('k1');

        expect(cache.get('k1')).toBeNull();
        expect(cache.get('k2')).toBeNull();
      }));


      it('should return undefined when entry does not exist', inject((CacheFactory $cacheFactory) {
        expect(cache.remove('non-existent')).toBeNull();
      }));


      it('should stringify keys', inject((CacheFactory $cacheFactory) {
        cache.put('123', 'foo');
        cache.put(123, 'bar');

        expect(cache.get('123')).toBe('bar');
        expect(cache.info().size).toBe(1);

        cache.remove(123);
        expect(cache.info().size).toBe(0);
      }));


      it("should return value from put", inject((CacheFactory $cacheFactory) {
        var obj = {};
        expect(cache.put('k1', obj)).toBe(obj);
      }));
    });


    describe('info', () {

      it('should size increment with put and decrement with remove', inject((CacheFactory $cacheFactory) {
        expect(cache.info().size).toBe(0);

        cache.put('foo', 'bar');
        expect(cache.info().size).toBe(1);

        cache.put('baz', 'boo');
        expect(cache.info().size).toBe(2);

        cache.remove('baz');
        expect(cache.info().size).toBe(1);

        cache.remove('foo');
        expect(cache.info().size).toBe(0);
      }));


      it('should return cache id', inject((CacheFactory $cacheFactory) {
        expect(cache.info().id).toBe('test');
      }));
    });


    describe('removeAll', () {

      it('should blow away all data', inject((CacheFactory $cacheFactory) {
        cache.put('id1', 1);
        cache.put('id2', 2);
        cache.put('id3', 3);
        expect(cache.info().size).toBe(3);

        cache.removeAll();

        expect(cache.info().size).toBe(0);
        expect(cache.get('id1')).toBeNull();
        expect(cache.get('id2')).toBeNull();
        expect(cache.get('id3')).toBeNull();
      }));
    });


    describe('destroy', () {

      it('should make the cache unusable and remove references to it from \$cacheFactory', inject((CacheFactory $cacheFactory) {
        cache.put('foo', 'bar');
        cache.destroy();

        expect(() { cache.get('foo'); } ).toThrow("[\$cacheFactory:iid] CacheId 'test' is already destroyed!");
        expect(() { cache.get('neverexisted'); }).toThrow("[\$cacheFactory:iid] CacheId 'test' is already destroyed!");
        expect(() { cache.put('foo', 'bar'); }).toThrow("[\$cacheFactory:iid] CacheId 'test' is already destroyed!");

        expect($cacheFactory.get('test')).toBeNull();
        expect($cacheFactory.info()).toEqual({});
      }));
    });
  });


  xdescribe('LRU cache', () {

    it('should create cache with defined capacity', inject((CacheFactory $cacheFactory) {
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

      beforeEach(inject((CacheFactory $cacheFactory) {
        cache = $cacheFactory('cache1', {'capacity': 2});

        cache.put('id0', 0);
        cache.put('id1', 1);
      }));


      it('should kick out the first entry on put', inject((CacheFactory $cacheFactory) {
        cache.put('id2', 2);
        expect(cache.get('id0')).toBeNull();
        expect(cache.get('id1')).toBe(1);
        expect(cache.get('id2')).toBe(2);
      }));


      it('should refresh an entry via get', inject((CacheFactory $cacheFactory) {
        cache.get('id0');
        cache.put('id2', 2);
        expect(cache.get('id0')).toBe(0);
        expect(cache.get('id1')).toBeNull();
        expect(cache.get('id2')).toBe(2);
      }));


      it('should refresh an entry via put', inject((CacheFactory $cacheFactory) {
        cache.put('id0', '00');
        cache.put('id2', 2);
        expect(cache.get('id0')).toBe('00');
        expect(cache.get('id1')).toBeNull();
        expect(cache.get('id2')).toBe(2);
      }));


      it('should not purge an entry if another one was removed', inject((CacheFactory $cacheFactory) {
        cache.remove('id1');
        cache.put('id2', 2);
        expect(cache.get('id0')).toBe(0);
        expect(cache.get('id1')).toBeNull();
        expect(cache.get('id2')).toBe(2);
      }));


      it('should purge the next entry if the stalest one was removed', inject((CacheFactory $cacheFactory) {
        cache.remove('id0');
        cache.put('id2', 2);
        cache.put('id3', 3);
        expect(cache.get('id0')).toBeNull();
        expect(cache.get('id1')).toBeNull();
        expect(cache.get('id2')).toBe(2);
        expect(cache.get('id3')).toBe(3);
      }));


      it('should correctly recreate the linked list if all cache entries were removed', inject((CacheFactory $cacheFactory) {
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


      it('should blow away the entire cache via removeAll and start evicting when full', inject((CacheFactory $cacheFactory) {
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


      it('should correctly refresh and evict items if operations are chained', inject((CacheFactory $cacheFactory) {
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
