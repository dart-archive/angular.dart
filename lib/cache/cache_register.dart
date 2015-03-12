part of angular.cache;

class CacheRegisterStats {
  final String name;
  int length;

  CacheRegisterStats(this.name);
}

@Injectable()
class CacheRegister {
  Map<String, dynamic> _caches = {};
  List<CacheRegisterStats> _stats = null;

  /**
   * Registers a cache with the CacheRegister.  The [name] is used for in the stats as
   * well as a key for [clear].
   */
  void registerCache(String name, cache) {
    if (_caches.containsKey(name)) {
      throw "Cache [$name] already registered";
    }
    _caches[name] = cache;

    // The stats object needs to be updated.
    _stats = null;

  }

  /**
   * A list of caches and their sizes.
   */
  List<CacheRegisterStats> get stats {
    if (_stats == null) {
      _stats = [];
      _caches.forEach((k, v) {
        _stats.add(new CacheRegisterStats(k));
      });
    }

    _stats.forEach((CacheRegisterStats stat) {
      stat.length = _caches[stat.name].length;
    });
    return _stats;
  }

  /**
   * Clears one or all the caches.  If [name] is omitted, all caches will be cleared.
   * Otherwise, only the cache named [name] will be cleared.
   */
  void clear([String name]) {
    if (name == null) {
      _caches.forEach((k, v) {
        v.clear();
      });
      return;
    }
    var cache = _caches[name];
    if (cache == null) {
      return;
    }
    _caches[name].clear();
  }
}
