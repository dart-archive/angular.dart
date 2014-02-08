library playback_http_spec;

import '../_specs.dart';
import 'package:angular/playback/playback_http.dart';

main() => describe('Playback HTTP', () {
  MockHttpBackend backend;
  beforeEach(module((Module m) {
    backend = new MockHttpBackend();
    var wrapper = new HttpBackendWrapper(backend);
    m
      ..value(HttpBackendWrapper, wrapper)
      ..type(PlaybackHttpBackendConfig);
  }));

  afterEach(() {
    backend.verifyNoOutstandingRequest();
    backend.verifyNoOutstandingExpectation();
  });

  describe('RecordingHttpBackend', () {
    beforeEach(module((Module m) {
      m.type(HttpBackend, implementedBy: RecordingHttpBackend);
    }));


    it('should record a request', async(inject((Http http) {
      backend.expectGET('request').respond(200, 'response');

      var responseData;

      http(method: 'GET', url: 'request').then((HttpResponse r) {
        responseData = r.data;
      });

      microLeap();
      backend.flush();
      backend
        .expectPOST('/record',
            r'{"key":"{\"url\":\"request\",\"method\":\"GET\",\"requestHeaders\":{\"Accept\":\"application/json, text/plain, */*\",\"X-XSRF-TOKEN\":\"secret\"},\"data\":null}",' +
            r'"data":"{\"status\":200,\"headers\":\"\",\"data\":\"response\"}"}')
        .respond(200);

      microLeap();
      backend.flush();
      microLeap();

      expect(responseData).toEqual('response');
    })));
  });


  describe('PlaybackHttpBackend', () {
    beforeEach(module((Module m) {
      m.type(HttpBackend, implementedBy: PlaybackHttpBackend);
    }));

    it('should replay a request', async(inject((Http http, HttpBackend hb) {
      (hb as PlaybackHttpBackend).data = {
        r'{"url":"request","method":"GET","requestHeaders":{"Accept":"application/json, text/plain, */*","X-XSRF-TOKEN":"secret"},"data":null}': {'status': 200, 'headers': '', 'data': 'playback data'}
      };

      var responseData;

      http(method: 'GET', url: 'request').then((HttpResponse r) {
        responseData = r.data;
      });

      microLeap();

      expect(responseData).toEqual('playback data');
    })));

  });
});
