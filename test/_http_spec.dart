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
