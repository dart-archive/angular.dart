library angular.mock.zone;

import 'dart:async' as dartAsync;

List<Function> _asyncQueue = [];
List _asyncErrors = [];
bool _noMoreAsync = false;

/**
 * Runs any queued up async calls and any async calls queued with
 * running fastForward.
 */
fastForward() {
  while (!_asyncQueue.isEmpty) {
    // copy the queue as it may change.
    var toRun = new List.from(_asyncQueue);
    _asyncQueue = [];
    toRun.forEach((fn) => fn());
  }
}


/**
* Causes runAsync calls to throw exceptions.
*
* This function is useful while debugging async tests: the exception
* is thrown from the runAsync call-site instead later in the test.
*/
noMoreAsync() {
  _noMoreAsync = true;
}

/**
* Captures all runAsync calls inside of a function.
*
* Typically used within a test: it('should be async', async(() { ... }));
*/
async(Function fn) =>
    () {
  _noMoreAsync = false;
  _asyncErrors = [];
  dartAsync.runZonedExperimental(() {
    fn();
    fastForward();
  },
  onRunAsync: (asyncFn) {
    if (_noMoreAsync) {
      throw ['runAsync called after noMoreAsync()'];
    } else {
      _asyncQueue.add(asyncFn);
    }
  },
  onError: (e) => _asyncErrors.add(e));

  _asyncErrors.forEach((e) {
    throw "During runZoned: $e.  Stack:\n${dartAsync.getAttachedStackTrace(e)}";
  });
};

/**
 * Enforces synchronous code.  Any calls to runAsync inside of 'sync'
 * will throw an exception.
 */
sync(Function fn) => () {
  dartAsync.runZonedExperimental(fn,
    onRunAsync: (asyncFn) {
      print('run sync');
      throw ['runAsync called from sync function.'];
    });
};
