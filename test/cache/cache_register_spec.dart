library cache_register_spec;

import '../_specs.dart';

main() => describe('CacheRegister', () {
  beforeEachModule((Module m) {
    m.bind(CacheRegister);
  });

  it('should clear caches', (CacheRegister register) {
    var map = {'a': 2};
    var map2 = {'b': 3};
    expect(map.length).toEqual(1);
    expect(map2.length).toEqual(1);

    register.registerCache('a', map);
    register.registerCache('b', map2);
    register.clear('a');
    expect(map.length).toEqual(0);
    expect(map2.length).toEqual(1);

    map['a'] = 2;
    register.clear();
    expect(map.length).toEqual(0);
    expect(map2.length).toEqual(0);


  });

  it('should return stats when empty', (CacheRegister register) {
    expect(register.stats).toEqual([]);
  });

  it('should return correct stats', (CacheRegister register) {
    var map = {'a': 2};
    var map2 = {'b': 3, 'c': 4};
    register.registerCache('a', map);
    register.registerCache('b', map2);

    expect(register.stats.length).toEqual(2);
    if (register.stats[0].name == 'a') {
      expect(register.stats[0].length).toEqual(1);
      expect(register.stats[1].name).toEqual('b');
      expect(register.stats[1].length).toEqual(2);
    } else {
      expect(register.stats[0].name).toEqual('b');
      expect(register.stats[0].length).toEqual(2);
      expect(register.stats[1].name).toEqual('a');
      expect(register.stats[1].length).toEqual(1);
    }

  });
});
