part of angular.watch_group;


class _LinkedListItem<I extends _LinkedListItem> {
  I _previous, _next;
}

class _LinkedList<L extends _LinkedList> {
  L _head, _tail;

  static _Handler _add(_Handler list, _LinkedListItem item) {
    assert(item._next     == null);
    assert(item._previous == null);
    if (list._tail == null) {
      list._head = list._tail = item;
    } else {
      item._previous = list._tail;
      list._tail._next = item;
      list._tail = item;
    }
    return item;
  }

  static _isEmpty(_Handler list) => list._head == null;

  static _remove(_Handler list, _Handler item) {
    var previous = item._previous;
    var next = item._next;

    if (previous == null) list._head = next;     else previous._next = next;
    if (next == null)     list._tail = previous; else next._previous = previous;
  }
}

class _ArgHandlerList {
  _ArgHandler _argHandlerHead, _argHandlerTail;

  static _Handler _add(_ArgHandlerList list, _ArgHandler item) {
    assert(item._nextArgHandler     == null);
    assert(item._previousArgHandler == null);
    if (list._argHandlerTail == null) {
      list._argHandlerHead = list._argHandlerTail = item;
    } else {
      item._previousArgHandler = list._argHandlerTail;
      list._argHandlerTail._nextArgHandler = item;
      list._argHandlerTail = item;
    }
    return item;
  }

  static _isEmpty(_InvokeHandler list) => list._argHandlerHead == null;

  static _remove(_InvokeHandler list, _ArgHandler item) {
    var previous = item._previousArgHandler;
    var next = item._nextArgHandler;

    if (previous == null) list._argHandlerHead = next;     else previous._nextArgHandler = next;
    if (next == null)     list._argHandlerTail = previous; else next._previousArgHandler = previous;
  }
}

class _WatchList {
  Watch _watchHead, _watchTail;

  static Watch _add(_WatchList list, Watch item) {
    assert(item._nextWatch     == null);
    assert(item._previousWatch == null);
    if (list._watchTail == null) {
      list._watchHead = list._watchTail = item;
    } else {
      item._previousWatch = list._watchTail;
      list._watchTail._nextWatch = item;
      list._watchTail = item;
    }
    return item;
  }

  static _isEmpty(_Handler list) => list._watchHead == null;

  static _remove(_Handler list, Watch item) {
    var previous = item._previousWatch;
    var next = item._nextWatch;

    if (previous == null) list._watchHead = next;     else previous._nextWatch = next;
    if (next == null)     list._watchTail = previous; else next._previousWatch = previous;
  }
}

class _EvalWatchList {
  EvalWatchRecord _evalWatchHead, _evalWatchTail;

  static EvalWatchRecord _add(_EvalWatchList list, EvalWatchRecord item) {
    assert(item._nextEvalWatch     == null);
    assert(item._previousEvalWatch == null);
    if (list._evalWatchTail == null) {
      list._evalWatchHead = list._evalWatchTail = item;
    } else {
      item._previousEvalWatch = list._evalWatchTail;
      list._evalWatchTail._nextEvalWatch = item;
      list._evalWatchTail = item;
    }
    return item;
  }

  static _isEmpty(_EvalWatchList list) => list._evalWatchHead == null;

  static _remove(_EvalWatchList list, EvalWatchRecord item) {
    var previous = item._previousEvalWatch;
    var next = item._nextEvalWatch;

    if (previous == null) list._evalWatchHead = next;     else previous._nextEvalWatch = next;
    if (next == null)     list._evalWatchTail = previous; else next._previousEvalWatch = previous;
  }
}
