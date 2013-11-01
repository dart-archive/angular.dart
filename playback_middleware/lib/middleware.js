
var url = require('url');
var playback = require('./playback.js');

/**
 * Returns connect middleware that will record and playback for Angular.dart's
 * HTTP playback service.
 * @param opts
 *    path is the path where the record / playback endpoint is served
 *    playbackImpl is the playback module, used for mocking
 * @returns {Function}
 */
function endpoint(opts) {
  opts = opts || {};
  opts.path = opts.path || '/record';
  opts.playbackImpl = opts.playbackImpl || playback.playback();


  return function playbackEndpoint(req, res, next) {
    if (url.parse(req.url).path != opts.path) {
      next();
      return;
    }

    if (req.method == 'POST') {
      var body = '';
      req.on('data', function(data) {
        body += data;
      });
      req.on('end', function() {
        var parsedBody = JSON.parse(body);

        opts.playbackImpl.record(parsedBody.key, parsedBody.data);
        res.writeHead(200);
        res.end();
      });
    } else if (req.method == 'GET') {
      var data = opts.playbackImpl.playback();
      res.writeHead(200, {
        'Content-Type': 'application/dart',
        'Content-Length': Buffer.byteLength(data)
      });
      res.end(data);
    }
  }
}

module.exports = {
  endpoint: endpoint
};
