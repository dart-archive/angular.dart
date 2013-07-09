part of angular;

/**
 * A simple map-backed cache.
 * TODO(pavelgj): add LRU support.
 */
class Cache {
  final String _id;
  Map<String, Object> _data = <String, Object>{};
  CacheFactory _factory;

  Cache._newCache(String this._id, CacheFactory this._factory);

  Object get(key) {
    _checkIfDestroyed();
    key = _stringifyKey(key);
    return _data[key];
  }

  Object put(key, Object value) {
    _checkIfDestroyed();
    if (value == null) {
      return null;
    }
    key = _stringifyKey(key);
    return _data[key] = value;
  }

  void remove(key) {
    _checkIfDestroyed();
    key = _stringifyKey(key);
    _data.remove(key);
  }

  void removeAll() {
    _checkIfDestroyed();
    _data.clear();
  }

  void _checkIfDestroyed() {
    if (_data == null) {
      throw "[\$cacheFactory:iid] CacheId '$_id' is already destroyed!";
    }
  }

  String _stringifyKey(key) {
    if (!(key is String)) {
      key = key.toString();
    }
    return key;
  }

  CacheInfo info() => new CacheInfo(size: _data.length, id: _id);

  void destroy() {
    _data.clear();
    _data = null;
    _factory._cacheMap.remove(_id);
  }
}

class CacheFactory {
  Map<String, Cache> _cacheMap = <String, Cache>{};

  Cache call(String cacheId) {
    var cache = _cacheMap[cacheId];
    if (cache != null) {
      throw "[\$cacheFactory:iid] CacheId '$cacheId' is already taken!";
    }
    _cacheMap[cacheId] = cache = new Cache._newCache(cacheId, this);
    return cache;
  }

  Cache get(String cacheId) {
    return _cacheMap[cacheId];
  }

  Map<String, CacheInfo> info() {
    Map<String, CacheInfo> info = <String, CacheInfo>{};
    _cacheMap.keys.forEach((cacheId) {
      info[cacheId] = _cacheMap[cacheId].info();
    });
    return info;
  }
}

class CacheInfo {
  final int size;
  final String id;

  CacheInfo({this.size, this.id});

  bool operator ==(other) {
    return other is CacheInfo && size == other.size && id == other.id;
  }

  String toString() => '{size: $size, id: $id}';
}