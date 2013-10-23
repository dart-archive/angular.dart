library angular.perf.try_catch;

import '_perf.dart';

/**
 * Compare with JS: http://jsperf.com/throw-new-error-vs-throw-name-error
 *
 * JavaScript vs Dart times on same machine:
 *
 *                      JavaScript        Dart
 * try-catch no stack:   4,952,173   3,944,303 ops/sec
 * try-catch with stack:   111,815     840,843 ops/sec
 * try-catch read stack:     9,206       9,356 ops/sec
 */
main() {
  var obj = {};
  time('try-catch no stack', () {
    try { throw obj; } catch(e) { return e; }
  } );
  time('try-catch with stack', () {
    try { throw obj; } catch(e, s) { return s; }
  } );
  time('try-catch read stack', () {
    try { throw obj; } catch(e, s) { return '$s'; }
  } );
}
