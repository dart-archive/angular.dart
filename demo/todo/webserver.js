var connect = require('connect');
var dart2jsaas = require('dart2jsaas');
var playback = require('../../playback_middleware/lib/middleware.js');

var dart2jsaasEnpoints = dart2jsaas.endpoints({
  fetcherBaseUrl: 'http://localhost:3000/'
});

function endsWith(haystack, needle) {
  if (haystack.length < needle.length) return false;

  var index = haystack.indexOf(needle);
  return index == (haystack.length - needle.length);
}

var app = connect()
    .use(dart2jsaasEnpoints.dart2js)
    .use(dart2jsaasEnpoints.snapshot)
    .use(playback.endpoint())
  // Serve the /todos for the app.
    .use(function(req, res, next) {
      if (req.url.indexOf('/todos') != 0) {
        next();
        return;
      }
      var data = JSON.stringify([
        {text: 'Done from server', done: true},
        {text: 'Not done from server', done: false}
      ]);

      res.writeHead(200, {
        'Content-Type': 'text/plain',
        'Content-Length': data.length
      });
      res.end(data);
    })
    // Redirect the playback_data.dart file to the playback service.
    .use(function(req, res, next) {
      if (endsWith(req.url, '/playback_data.dart')) {
        res.writeHead(302, {
          'Location': '/record'
        });
        res.end();
        return;
      }
      next();
    })
    .use(connect.static(process.cwd()));

connect.createServer(app).listen(3000);

console.log('Listening on port 3000');
