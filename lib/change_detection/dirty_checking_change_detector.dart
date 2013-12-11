library dirty_checking_change_detector;

import 'dart:mirrors';
import 'package:angular/change_detection/change_detection.dart';

class DirtyCheckingChangeDetector<ID extends Comparable, H> implements ChangeDetector<ID, H> {
  static final ChangeRecords<ID, H> EMPTY_CHANGE_RECORDS = new ChangeRecords(null, null, null);

  _Detector head;
  _Detector tail;

  DirtyCheckingChangeDetector() {
    head = tail = new _Detector.head();
  }

  UnWatch watch(Object object, String field, ID id, H handler) {
    var watch = new _Detector(object, field, id, handler);
    tail = tail._nextDetector = watch;
    return () {
      throw 'implement';
    };
  }

  UnWatch watchList(List list, ID id, H handler) {throw 'implement';}
  UnWatch watchMap(Map map, ID id, H handler) {throw 'implement';}


  _Detector<ID, H> collectChanges() {
    _Detector changeHead = head;
    _Detector changeTail = head;
    _Detector c = head;
    while( (c = c._nextDetector) != null) {
      var currentValue = c.currentValue;
      var instanceMirror = c._instanceMirror;
      if (identical(instanceMirror, null)) {
        if (currentValue is List) {
          throw 'implement';
        } else if (currentValue is Map) {
          throw 'implement';
        } else {
          throw new StateError();
        }
      } else {
        var symbol = c._symbol;
        var value = symbol == null ? c.object[c.field] : instanceMirror.getField(symbol).reflectee;
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


class _Detector<ID extends Comparable, H> {
  final dynamic object;
  final ID id;
  final H handler;

  final String field;
  final Symbol _symbol;
  final InstanceMirror _instanceMirror;

  dynamic previousValue;
  dynamic currentValue;
  _Detector<ID, H> _nextDetector;
  _Detector<ID, H> _nextChange;

  _Detector(obj, fieldName, this.id, this.handler):
        _instanceMirror = reflect(obj),
        field = fieldName,
        _symbol = obj is Map ? null : new Symbol(fieldName),
        object = obj
  {
    if (_symbol != null) {
      previousValue = currentValue = _instanceMirror.getField(_symbol).reflectee;
    } else {
      previousValue = currentValue = obj[fieldName];
    }
  }

  _Detector.head():
      object = null,
      _instanceMirror = null,
      _symbol = null,
      field = null,
      id = null,
      handler = null;

  get next => _nextChange;
}
