var middleware = require('../lib/middleware.js');

describe('middleware', function() {
  var m, next, playImpl;
  beforeEach(function() {
    playImpl = { burn: false,
        record: jasmine.createSpy('record'),
        playback: jasmine.createSpy('playback')
    };
    m = middleware.endpoint({
      playbackImpl: playImpl
    });
    next = jasmine.createSpy('next');
  });


  it('should call next() for requests it does not handle', function() {
    m({url: '/notrecord'}, undefined, next);
    expect(next).toHaveBeenCalled();
  });

  it('should call playback.record for POST requests', function() {
    var req = jasmine.createSpy('req');
    var res = {
        writeHead: jasmine.createSpy('writeHead'),
        end: jasmine.createSpy('end')
    };

    req.url = '/record';
    req.method = 'POST';
    var dataCb, endCb;
    req.on = function(type, cb) {
      if (type == 'data') dataCb = cb;
      else if (type == 'end') endCb = cb;
      else throw "Unknown type " + type;
    };

    m(req, res, next);

    dataCb('{"key": "K",');
    dataCb('"data": "V"}');
    endCb();

    expect(next).not.toHaveBeenCalled();
    expect(playImpl.record).toHaveBeenCalledWith('K', 'V');
    expect(res.writeHead).toHaveBeenCalledWith(200);
    expect(res.end).toHaveBeenCalled();
  });


  it('should call playback.playback for GET requests', function() {
    var req = {
      url: '/record',
      method: 'GET'
    };

    var res = {
      writeHead: jasmine.createSpy('writeHead'),
      end: jasmine.createSpy('end')
    };

    playImpl.playback.andReturn('data from a dart file');

    m(req, res, next);

    expect(next).not.toHaveBeenCalled();
    expect(playImpl.playback).toHaveBeenCalled();
    expect(res.writeHead).toHaveBeenCalledWith(200, {
      'Content-Type' : 'application/dart',
      'Content-Length' : 21 });
    expect(res.end).toHaveBeenCalledWith('data from a dart file');
  });
});
