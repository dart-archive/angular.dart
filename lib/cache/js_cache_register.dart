library angular.cache.js;

// This is a separate module since it depends on dart:js

import 'dart:js' as js;
import 'package:di/di.dart';
import 'package:angular/core/annotation_src.dart';
import 'package:angular/cache/module.dart';

Key JS_CACHE_REGISTER_KEY = new Key(JsCacheRegister);

/**
 * Publishes an interface to the CacheRegister in Javascript.  When installed,
 * a 'ngCaches' object will be available in Javascript.
 *
 * ngCaches.sizes() returns a map of cache name -> number of entries in the cache
 * ngCaches.dump() prints the cache information to the console
 * ngCaches.clear(name) clears the cache named 'name', or if name is omitted, all caches.
 */
@Injectable()
class JsCacheRegister {
  CacheRegister _caches;

  JsCacheRegister(CacheRegister this._caches) {
    js.context['ngCaches'] = new js.JsObject.jsify({
        "sizes": sizesAsMap,
        "clear": _caches.clear,
        "dump": dump
    });
  }

  void dump() {
    var toPrint = ['Angular Cache Sizes:'];
    _caches.stats.forEach((CacheRegisterStats stat) {
      toPrint.add('${stat.name.padLeft(35)} ${stat.length}');
    });
    print(toPrint.join('\n'));
  }

  js.JsObject sizesAsMap() {
    var map = {};
    _caches.stats.forEach((CacheRegisterStats stat) {
      map[stat.name] = stat.length;
    });
    return new js.JsObject.jsify(map);
  }
}

class JsCacheModule extends Module {
  JsCacheModule() {
    bind(JsCacheRegister);
  }
}
