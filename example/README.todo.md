Angular.dart's Todo Demo
========================

This demo is the most complete demo in the repository and a great
starting point for quickly understanding Angular.dart

Getting up and running
----------------------

To run this demo, first clone the entire Angular.dart repository.

Then, run `pub serve` in this directory:

```
$ cd demo
$ pub serve
```

Finally, open `http://localhost:8080/todo.html.`

The server is optional
----------------------

There is a simple Node.js server in this directory, but you do
not need to run it.  It is here to demonstrate the HTTP record /
playback feature, snapshotting and dart2js.

```
$ cd example
$ node webserver.js
Web server is listening on port 3000
```

To use dart2js, open http://localhost:3000/todo.html in a non-Dartium web
browser.

To use snapshotting, open http://localhost:3000/snapshot/todo.html, which
will serve a zip file with all the files used in the application.

To use HTTP record / playback, first open http://localhost:3000/todo.html?record.
Then, without restarting the server, open http://localhost:3000/todo.html?playback.

For more awesomeness, use HTTP playback together with snapshotting to isolate your
Dart application from the server. http://localhost:3000/snapshot/todo.html?playback
