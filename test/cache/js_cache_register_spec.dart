library js_cache_register_spec;

import '../_specs.dart';
import 'dart:js' as js;

main() => describe('JsCacheRegister', () {
  beforeEachModule((Module m) {
    m.bind(CacheRegister);
  });

  s() => js.context['ngCaches']['sizes'].apply([]);

  // Create some caches in the system
  beforeEach((JsCacheRegister js, Parser dp, ViewFactoryCache vc) {});

  it('should publish a JS interface', () {
    expect(js.context['ngCaches']).toBeDefined();
  });

  it('should return a map of caches', () {
    expect(js.context['Object']['keys'].apply([s()]).length > 0).toBeTruthy();
  });

  it('should clear one cache', (Parser p) {
    p('1');

    expect(s()['Parser'] > 0).toBeTruthy();

    js.context['ngCaches']['clear'].apply(['Parser']);
    expect(s()['Parser']).toEqual(0);
  });

  it('should clear all caches', (Parser p) {
    p('1');

    var stats = s();
    var caches = js.context['Object']['keys'].apply([stats]);
    expect(caches.length > 0).toBeTruthy();
    js.context['ngCaches']['clear'].apply([]);

    var clearedStats = s();
    caches.forEach((cacheName) {
      expect(clearedStats[cacheName]).toEqual(0);
    });
  });
});
