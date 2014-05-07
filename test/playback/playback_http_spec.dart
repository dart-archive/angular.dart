library playback_http_spec;

import '../_specs.dart';
import 'package:angular/playback/playback_http.dart';

void main() {
  describe('Playback HTTP', () {
    MockHttpBackend backend;
    beforeEachModule((Module m) {
      backend = new MockHttpBackend();
      var wrapper = new HttpBackendWrapper(backend);
      m
        ..bind(HttpBackendWrapper, toValue: wrapper)
        ..bind(PlaybackHttpBackendConfig);
    });

    afterEach(() {
      backend.verifyNoOutstandingRequest();
      backend.verifyNoOutstandingExpectation();
    });

    describe('RecordingHttpBackend', () {
      beforeEachModule((Module m) {
        m.bind(HttpBackend, toImplementation: RecordingHttpBackend);
      });


      it('should record a request', async((Http http) {
        backend.expectGET('request').respond(200, 'response');

        var responseData;

        http(method: 'GET', url: 'request').then((HttpResponse r) {
          responseData = r.data;
        });

        microLeap();
        backend.flush();
        backend
        .expectPOST('/record',
            r'{"key":"{\"url\":\"request\",\"method\":\"GET\",\"requestHeaders\":'
            r'{\"Accept\":\"application/json, text/plain, */*\",\"X-XSRF-TOKEN\":\"secret\"},\"data\":null}",'
            r'"data":"{\"status\":200,\"headers\":\"\",\"data\":\"response\"}"}')
        .respond(200);

        microLeap();
        backend.flush();
        microLeap();

        expect(responseData).toEqual('response');
      }));
    });


    describe('PlaybackHttpBackend', () {
      beforeEachModule((Module m) {
        m.bind(HttpBackend, toImplementation: PlaybackHttpBackend);
      });

      it('should replay a request', async((Http http, HttpBackend hb) {
        (hb as PlaybackHttpBackend).data = {
            r'{"url":"request","method":"GET","requestHeaders":{"Accept":"application/json, text/plain, */*","X-XSRF-TOKEN":"secret"},"data":null}':
            {'status': 200, 'headers': '', 'data': 'playback data'}
        };

        var responseData;

        http(method: 'GET', url: 'request').then((HttpResponse r) {
          responseData = r.data;
        });

        microLeap();

        expect(responseData).toEqual('playback data');
      }));

    });
  });
}
