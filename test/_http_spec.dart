import "_specs.dart";
import "_http.dart";

main() {
  describe("MockHttp", () {
    MockHttp http;
    beforeEach(() {
      http = new MockHttp();
    });

    it('should replay an http request', () {
      http.expectGET('request', 'response');
      http.getString('request').then(expectAsync1((data) {
        expect(data).toEqual('response');
      }));
    });

    it('should cache results', inject((CacheFactory $cacheFactory) {
      http.expectGET('request', 'response');
      Cache cache = $cacheFactory('test');
      http.getString('request', cache: cache).then(expectAsync1((data) {
        expect(data).toEqual('response');
        expect(cache.info().size).toEqual(1);
        expect(cache.get('request')).toEqual('response');
      }));
    }));

    it('should return cached results', inject((CacheFactory $cacheFactory) {
      http.expectGET('request', 'response');
      Cache cache = $cacheFactory('test');
      http.getString('request', cache: cache).then(expectAsync1((data) {
        expect(data).toEqual('response');

        http.getString('request', cache: cache).then(expectAsync1((data) {
          expect(data).toEqual('response');
        }));
      }));
    }));

    it('should barf on an unseen request', () {
      expect(() {
        http.getString('unknown');
      }).toThrow('Unexpected URL unknown');
    });

    it('should barf on hanging requests', () {
      http.expectGET('request', 'response');
      expect(() {
        http.flush();
      }).toThrow('Expected GETs not called {request: response}');
    });
  });
}
