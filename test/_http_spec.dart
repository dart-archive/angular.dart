import "_specs.dart";
import "_http.dart";

main() {
  describe("MockHttp", () {
    MockHttp http;
    beforeEach(inject((MockHttp mock_http) {
      http = mock_http;
    }));

    it('should replay an http request', () {
      http.expectGET('request', 'response');
      http.getString('request').then(expectAsync1((data) {
        expect(data).toEqual('response');
      }));
    });
    
    it('should replay an http request which is expected multiple times', () {
      http.expectGET('request', 'response', times: 2);
      http.getString('request').then(expectAsync1((data) {
        expect(http.gets.length).toEqual(1);
        expect(data).toEqual('response');
        http.getString('request').then(expectAsync1((data) {
          expect(http.gets.length).toEqual(0);
          expect(data).toEqual('response');
        }));
      }));
    });
    
    it('should throw an exeception on assertAllGetsCalled when not all expected GETs were called', () {
      http.expectGET('request', 'response', times: 2);
      http.getString('request').then(expectAsync1((data) {
        expect(() {
          http.assertAllGetsCalled();
        }).toThrow('Expected GETs not called {request: response}');
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

    it('should barf on an unseen request', () {
      expect(() {
        http.getString('unknown');
      }).toThrow('Unexpected URL unknown');
    });

    it('should barf on hanging requests', () {
      http.expectGET('request', 'response');
      expect(() {
        http.flush();
        http.assertAllGetsCalled();
      }).toThrow('Expected GETs not called {request: response}');
    });
  });
}
