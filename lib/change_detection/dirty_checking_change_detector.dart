library dirty_checking_change_detector;

import 'dart:mirrors';
import 'package:angular/change_detection/change_detection.dart';

class DirtyCheckingChangeDetector<ID extends Comparable, H> implements ChangeDetector<ID, H> {
  static final ChangeRecords<ID, H> EMPTY_CHANGE_RECORDS = new ChangeRecords(null, null, null);

  WatchRecord head;
  WatchRecord tail;

  DirtyCheckingChangeDetector() {
    head = tail = new WatchRecord.head();
  }

  UnWatch watch(Object object, String field, ID id, H handler) {
    var watch = new WatchRecord(object, field, id, handler);
    tail = tail._nextDetector = watch;
    return () {
      throw 'implement';
    };
  }

  UnWatch watchList(List list, ID id, H handler) {throw 'implement';}
  UnWatch watchMap(Map map, ID id, H handler) {throw 'implement';}


  WatchRecord<ID, H> collectChanges() {
    WatchRecord changeHead = head;
    WatchRecord changeTail = head;
    WatchRecord c = head;
    while( (c = c._nextDetector) != null) {
      var currentValue = c.currentValue;
      var getter = c.getter;
      if (identical(getter, null)) {
        if (currentValue is List) {
          throw 'implement';
        } else if (currentValue is Map) {
          throw 'implement';
        } else {
          throw new StateError();
        }
      } else {
        var value = getter(c.object);
        if (!identical(currentValue, value)) {
          if (value is String && currentValue is String && value == currentValue) {
            // this is false change we need to recover.
            c.currentValue = value;
          } else {
            c.previousValue = c.currentValue;
            c.currentValue = value;
            changeTail = changeTail._nextChange = c;
          }
        }
      }
    };

    changeTail._nextChange = null;

    return changeHead._nextChange;
  }
  void unWatch(ID inclusiveFrom, ID exclusiveTo) {throw 'implement';}
}


class WatchRecord<ID extends Comparable, H> extends ChangeRecord<ID, H> {
  final ID id;
  final H handler;

  final String field;
  Function getter;

  dynamic previousValue;
  dynamic currentValue;
  WatchRecord<ID, H> _nextDetector;
  WatchRecord<ID, H> _nextChange;
  dynamic _object;

  WatchRecord(obj, this.field, this.id, this.handler) {
    this.object = obj;
    previousValue = currentValue = getter(obj);
  }

  WatchRecord.head():
      _object = null,
      field = null,
      id = null,
      handler = null;

  get next => _nextChange;

  get object => _object;
  set object(obj) {
    this._object = obj;
    if (obj is Map) {
      var key = this.field;
      this.getter = (obj) => obj[key];
    } else {
      var symbol = new Symbol(field);
      var instanceMirror = reflect(obj);
      this.getter = (obj) => instanceMirror.getField(symbol).reflectee;
    }
  }

  call() {
    throw 'implement removal';
  }
}
