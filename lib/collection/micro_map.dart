library angular.collection;

import 'dart:collection';
import 'micro_iterable.dart';

const int MODE_ARRAY = 0;
const int MODE_MAP = 1;

/**
 * MicroMap is backed by fields until it reaches length 20. After that it
 * delegates storage to a standard HashMap.
 * Once micromap enters map mode (i.e. delegate map is constructed) it would
 * not revert into fields mode (even after removals).
 */
class MicroMap<K, V> implements Map {

  var _key0; var _obj0;
  var _key1; var _obj1;
  var _key2; var _obj2;
  var _key3; var _obj3;
  var _key4; var _obj4;
  var _key5; var _obj5;
  var _key6; var _obj6;
  var _key7; var _obj7;
  var _key8; var _obj8;
  var _key9; var _obj9;
  var _key10; var _obj10;
  var _key11; var _obj11;
  var _key12; var _obj12;
  var _key13; var _obj13;
  var _key14; var _obj14;
  var _key15; var _obj15;
  var _key16; var _obj16;
  var _key17; var _obj17;
  var _key18; var _obj18;
  var _key19; var _obj19;
  // Invariants:
  // delegate != null -> _key*, _obj* = null, count = 0
  // delegate == null -> 0 <= count <= 20
  int count;
  Map<K, V> delegate;


  MicroMap() {
    count = 0;
  }

  bool containsValue(Object value) {
    if (delegate == null) {
      if (count == 0) return false;  if(_obj0 == value) return true;
      if (count == 1) return false;  if(_obj1 == value) return true;
      if (count == 2) return false;  if(_obj2 == value) return true;
      if (count == 3) return false;  if(_obj3 == value) return true;
      if (count == 4) return false;  if(_obj4 == value) return true;
      if (count == 5) return false;  if(_obj5 == value) return true;
      if (count == 6) return false;  if(_obj6 == value) return true;
      if (count == 7) return false;  if(_obj7 == value) return true;
      if (count == 8) return false;  if(_obj8 == value) return true;
      if (count == 9) return false;  if(_obj9 == value) return true;
      if (count == 10) return false; if(_obj10 == value) return true;
      if (count == 11) return false; if(_obj11 == value) return true;
      if (count == 12) return false; if(_obj12 == value) return true;
      if (count == 13) return false; if(_obj13 == value) return true;
      if (count == 14) return false; if(_obj14 == value) return true;
      if (count == 15) return false; if(_obj15 == value) return true;
      if (count == 16) return false; if(_obj16 == value) return true;
      if (count == 17) return false; if(_obj17 == value) return true;
      if (count == 18) return false; if(_obj18 == value) return true;
      if (count == 19) return false; if(_obj19 == value) return true;
      if (count == 20) return false;
    }
    return delegate.containsValue(value);
  }

  bool containsKey(Object key) {
    if (delegate == null) {
      if (count == 0) return false;   if(_key0 == key) return true;
      if (count == 1) return false;   if(_key1 == key) return true;
      if (count == 2) return false;   if(_key2 == key) return true;
      if (count == 3) return false;   if(_key3 == key) return true;
      if (count == 4) return false;   if(_key4 == key) return true;
      if (count == 5) return false;   if(_key5 == key) return true;
      if (count == 6) return false;   if(_key6 == key) return true;
      if (count == 7) return false;   if(_key7 == key) return true;
      if (count == 8) return false;   if(_key8 == key) return true;
      if (count == 9) return false;   if(_key9 == key) return true;
      if (count == 10) return false;  if(_key10 == key) return true;
      if (count == 11) return false;  if(_key11 == key) return true;
      if (count == 12) return false;  if(_key12 == key) return true;
      if (count == 13) return false;  if(_key13 == key) return true;
      if (count == 14) return false;  if(_key14 == key) return true;
      if (count == 15) return false;  if(_key15 == key) return true;
      if (count == 16) return false;  if(_key16 == key) return true;
      if (count == 17) return false;  if(_key17 == key) return true;
      if (count == 18) return false;  if(_key18 == key) return true;
      if (count == 19) return false;  if(_key19 == key) return true;
      if (count == 20) return false;
    }
    return delegate.containsKey(key);
  }

  V putIfAbsent(K key, V ifAbsent()) {
    if (delegate == null) {
      if (count == 0)  { count++; _key0 = key;  return _obj0 = ifAbsent();  } else if (key == _key0) return _obj0;
      if (count == 1)  { count++; _key1 = key;  return _obj1 = ifAbsent();  } else if (key == _key1) return _obj1;
      if (count == 2)  { count++; _key2 = key;  return _obj2 = ifAbsent();  } else if (key == _key2) return _obj2;
      if (count == 3)  { count++; _key3 = key;  return _obj3 = ifAbsent();  } else if (key == _key3) return _obj3;
      if (count == 4)  { count++; _key4 = key;  return _obj4 = ifAbsent();  } else if (key == _key4) return _obj4;
      if (count == 5)  { count++; _key5 = key;  return _obj5 = ifAbsent();  } else if (key == _key5) return _obj5;
      if (count == 6)  { count++; _key6 = key;  return _obj6 = ifAbsent();  } else if (key == _key6) return _obj6;
      if (count == 7)  { count++; _key7 = key;  return _obj7 = ifAbsent();  } else if (key == _key7) return _obj7;
      if (count == 8)  { count++; _key8 = key;  return _obj8 = ifAbsent();  } else if (key == _key8) return _obj8;
      if (count == 9)  { count++; _key9 = key;  return _obj9 = ifAbsent();  } else if (key == _key9) return _obj9;
      if (count == 10) { count++; _key10 = key; return _obj10 = ifAbsent(); } else if (key == _key10) return _obj10;
      if (count == 11) { count++; _key11 = key; return _obj11 = ifAbsent(); } else if (key == _key11) return _obj11;
      if (count == 12) { count++; _key12 = key; return _obj12 = ifAbsent(); } else if (key == _key12) return _obj12;
      if (count == 13) { count++; _key13 = key; return _obj13 = ifAbsent(); } else if (key == _key13) return _obj13;
      if (count == 14) { count++; _key14 = key; return _obj14 = ifAbsent(); } else if (key == _key14) return _obj14;
      if (count == 15) { count++; _key15 = key; return _obj15 = ifAbsent(); } else if (key == _key15) return _obj15;
      if (count == 16) { count++; _key16 = key; return _obj16 = ifAbsent(); } else if (key == _key16) return _obj16;
      if (count == 17) { count++; _key17 = key; return _obj17 = ifAbsent(); } else if (key == _key17) return _obj17;
      if (count == 18) { count++; _key18 = key; return _obj18 = ifAbsent(); } else if (key == _key18) return _obj18;
      if (count == 19) { count++; _key19 = key; return _obj19 = ifAbsent(); } else if (key == _key19) return _obj19;
      if (count == 20) _copyAllElementsToMap();
    }
    return delegate.putIfAbsent(key, ifAbsent);
  }

  void addAll(Map<K, V> other) {
    other.forEach((K key, V value) => this[key] = value);
  }

  void _fill(int idx, Object key, Object value) {
    if (idx == 0)  { _key0 = key; _obj0 = value; return; }
    if (idx == 1)  { _key1 = key; _obj1 = value; return; }
    if (idx == 2)  { _key2 = key; _obj2 = value; return; }
    if (idx == 3)  { _key3 = key; _obj3 = value; return; }
    if (idx == 4)  { _key4 = key; _obj4 = value; return; }
    if (idx == 5)  { _key5 = key; _obj5 = value; return; }
    if (idx == 6)  { _key6 = key; _obj6 = value; return; }
    if (idx == 7)  { _key7 = key; _obj7 = value; return; }
    if (idx == 8)  { _key8 = key; _obj8 = value; return; }
    if (idx == 9)  { _key9 = key; _obj9 = value; return; }
    if (idx == 10) { _key10 = key; _obj10 = value; return; }
    if (idx == 11) { _key11 = key; _obj11 = value; return; }
    if (idx == 12) { _key12 = key; _obj12 = value; return; }
    if (idx == 13) { _key13 = key; _obj13 = value; return; }
    if (idx == 14) { _key14 = key; _obj14 = value; return; }
    if (idx == 15) { _key15 = key; _obj15 = value; return; }
    if (idx == 16) { _key16 = key; _obj16 = value; return; }
    if (idx == 17) { _key17 = key; _obj17 = value; return; }
    if (idx == 18) { _key18 = key; _obj18 = value; return; }
    if (idx == 19) { _key19 = key; _obj19 = value; return; }
  }

  V remove(Object key) {
    if (delegate == null) {
      var value = null;
      var seenIdx = -1;
      if (count == 0)   { return null; } else if (key == _key0) { seenIdx = 0 ; value = _obj0; _obj0 = null;}
      if (count == 1)   { if (seenIdx != -1) { if (seenIdx != 0)  _fill(seenIdx, _key0, _obj0); count--;} return value; } else if (key == _key1)  { seenIdx = 1 ; value = _obj1; _obj1 = null;}
      if (count == 2)   { if (seenIdx != -1) { if (seenIdx != 1)  _fill(seenIdx, _key1, _obj1); count--;} return value; } else if (key == _key2)  { seenIdx = 2 ; value = _obj2; _obj2 = null;}
      if (count == 3)   { if (seenIdx != -1) { if (seenIdx != 2)  _fill(seenIdx, _key2, _obj2); count--;} return value; } else if (key == _key3)  { seenIdx = 3 ; value = _obj3; _obj3 = null;}
      if (count == 4)   { if (seenIdx != -1) { if (seenIdx != 3)  _fill(seenIdx, _key3, _obj3); count--;} return value; } else if (key == _key4)  { seenIdx = 4 ; value = _obj4; _obj4 = null;}
      if (count == 5)   { if (seenIdx != -1) { if (seenIdx != 4)  _fill(seenIdx, _key4, _obj4); count--;} return value; } else if (key == _key5)  { seenIdx = 5 ; value = _obj5; _obj5 = null;}
      if (count == 6)   { if (seenIdx != -1) { if (seenIdx != 5)  _fill(seenIdx, _key5, _obj5); count--;} return value; } else if (key == _key6)  { seenIdx = 6 ; value = _obj6; _obj6 = null;}
      if (count == 7)   { if (seenIdx != -1) { if (seenIdx != 6)  _fill(seenIdx, _key6, _obj6); count--;} return value; } else if (key == _key7)  { seenIdx = 7 ; value = _obj7; _obj7 = null;}
      if (count == 8)   { if (seenIdx != -1) { if (seenIdx != 7)  _fill(seenIdx, _key7, _obj7); count--;} return value; } else if (key == _key8)  { seenIdx = 8 ; value = _obj8; _obj8 = null;}
      if (count == 9)   { if (seenIdx != -1) { if (seenIdx != 8)  _fill(seenIdx, _key8, _obj8); count--;} return value; } else if (key == _key9)  { seenIdx = 9 ; value = _obj9; _obj9 = null;}
      if (count == 10)  { if (seenIdx != -1) { if (seenIdx != 9)  _fill(seenIdx, _key9, _obj9); count--;} return value; } else if (key == _key10)  { seenIdx = 10 ; value = _obj10; _obj10 = null;}
      if (count == 11)  { if (seenIdx != -1) { if (seenIdx != 10) _fill(seenIdx, _key10, _obj10); count--;} return value; } else if (key == _key11)  { seenIdx = 11 ; value = _obj11; _obj11 = null;}
      if (count == 12)  { if (seenIdx != -1) { if (seenIdx != 11) _fill(seenIdx, _key11, _obj11); count--;} return value; } else if (key == _key12)  { seenIdx = 12 ; value = _obj12; _obj12 = null;}
      if (count == 13)  { if (seenIdx != -1) { if (seenIdx != 12) _fill(seenIdx, _key12, _obj12); count--;} return value; } else if (key == _key13)  { seenIdx = 13 ; value = _obj13; _obj13 = null;}
      if (count == 14)  { if (seenIdx != -1) { if (seenIdx != 13) _fill(seenIdx, _key13, _obj13); count--;} return value; } else if (key == _key14)  { seenIdx = 14 ; value = _obj14; _obj14 = null;}
      if (count == 15)  { if (seenIdx != -1) { if (seenIdx != 14) _fill(seenIdx, _key14, _obj14); count--;} return value; } else if (key == _key15)  { seenIdx = 15 ; value = _obj15; _obj15 = null;}
      if (count == 16)  { if (seenIdx != -1) { if (seenIdx != 15) _fill(seenIdx, _key15, _obj15); count--;} return value; } else if (key == _key16)  { seenIdx = 16 ; value = _obj16; _obj16 = null;}
      if (count == 17)  { if (seenIdx != -1) { if (seenIdx != 16) _fill(seenIdx, _key16, _obj16); count--;} return value; } else if (key == _key17)  { seenIdx = 17 ; value = _obj17; _obj17 = null;}
      if (count == 18)  { if (seenIdx != -1) { if (seenIdx != 17) _fill(seenIdx, _key17, _obj17); count--;} return value; } else if (key == _key18)  { seenIdx = 18 ; value = _obj18; _obj18 = null;}
      if (count == 19)  { if (seenIdx != -1) { if (seenIdx != 18) _fill(seenIdx, _key18, _obj18); count--;} return value; } else if (key == _key19)  { seenIdx = 19 ; value = _obj19; _obj19 = null;}
      if (count == 20)  { if (seenIdx != -1) { if (seenIdx != 19) _fill(seenIdx, _key19, _obj19); count--;} return value; }
      return null;
    } else {
      return delegate.remove(key);
    }
  }

  void clear() {
    if (delegate == null) {
      _clearAllElements();
    } else {
      delegate.clear();
    }
  }

  void forEach(void f(K key, V value)) {
    if (delegate == null) {
      if (count == 0)  return; f(_key0 , _obj0 );
      if (count == 1)  return; f(_key1 , _obj1 );
      if (count == 2)  return; f(_key2 , _obj2 );
      if (count == 3)  return; f(_key3 , _obj3 );
      if (count == 4)  return; f(_key4 , _obj4 );
      if (count == 5)  return; f(_key5 , _obj5 );
      if (count == 6)  return; f(_key6 , _obj6 );
      if (count == 7)  return; f(_key7 , _obj7 );
      if (count == 8)  return; f(_key8 , _obj8 );
      if (count == 9)  return; f(_key9 , _obj9 );
      if (count == 10) return; f(_key10, _obj10);
      if (count == 11) return; f(_key11, _obj11);
      if (count == 12) return; f(_key12, _obj12);
      if (count == 13) return; f(_key13, _obj13);
      if (count == 14) return; f(_key14, _obj14);
      if (count == 15) return; f(_key15, _obj15);
      if (count == 16) return; f(_key16, _obj16);
      if (count == 17) return; f(_key17, _obj17);
      if (count == 18) return; f(_key18, _obj18);
      if (count == 19) return; f(_key19, _obj19);
    } else {
      delegate.forEach(f);
    }
  }

  Iterable<K> get keys {
    if (delegate != null) return delegate.keys;
    return new MicroIterable(_key0, _key1, _key2, _key3, _key4, _key5, _key6, _key7, _key8, _key9, _key10, _key11, _key12,
        _key13, _key14, _key15, _key16, _key17, _key18, _key19, length);
  }

  Iterable<V> get values {
    if (delegate != null) return delegate.values;
    List vs = [];
    return new MicroIterable(_obj0, _obj1, _obj2, _obj3, _obj4, _obj5, _obj6, _obj7, _obj8, _obj9, _obj0, _obj11, _obj12,
        _obj13, _obj14, _obj15, _obj16, _obj17, _obj18, _obj19, length);
  }

  int get length => delegate == null ? count : delegate.length;
  bool get isEmpty => delegate == null ? count == 0 : delegate.isEmpty;
  bool get isNotEmpty => delegate == null ? count != 0 : delegate.isNotEmpty;

  V operator [](K key) {
    if (delegate == null) {
      if (count == 0)  return null; if (key == _key0) return _obj0;
      if (count == 1)  return null; if (key == _key1) return _obj1;
      if (count == 2)  return null; if (key == _key2) return _obj2;
      if (count == 3)  return null; if (key == _key3) return _obj3;
      if (count == 4)  return null; if (key == _key4) return _obj4;
      if (count == 5)  return null; if (key == _key5) return _obj5;
      if (count == 6)  return null; if (key == _key6) return _obj6;
      if (count == 7)  return null; if (key == _key7) return _obj7;
      if (count == 8)  return null; if (key == _key8) return _obj8;
      if (count == 9)  return null; if (key == _key9) return _obj9;
      if (count == 10) return null; if (key == _key10) return _obj10;
      if (count == 11) return null; if (key == _key11) return _obj11;
      if (count == 12) return null; if (key == _key12) return _obj12;
      if (count == 13) return null; if (key == _key13) return _obj13;
      if (count == 14) return null; if (key == _key14) return _obj14;
      if (count == 15) return null; if (key == _key15) return _obj15;
      if (count == 16) return null; if (key == _key16) return _obj16;
      if (count == 17) return null; if (key == _key17) return _obj17;
      if (count == 18) return null; if (key == _key18) return _obj18;
      if (count == 19) return null; if (key == _key19) return _obj19;
      if (count == 20) return null;
    } else {
      return delegate[key];
    }
  }

  void operator []=(K key, V value) {
    if (delegate == null) {
      if      (count == 0)  { _key0  = key; _obj0  = value; count++; } else if (key == _key0)  { _obj0  = value; }
      else if (count == 1)  { _key1  = key; _obj1  = value; count++; } else if (key == _key1)  { _obj1  = value; }
      else if (count == 2)  { _key2  = key; _obj2  = value; count++; } else if (key == _key2)  { _obj2  = value; }
      else if (count == 3)  { _key3  = key; _obj3  = value; count++; } else if (key == _key3)  { _obj3  = value; }
      else if (count == 4)  { _key4  = key; _obj4  = value; count++; } else if (key == _key4)  { _obj4  = value; }
      else if (count == 5)  { _key5  = key; _obj5  = value; count++; } else if (key == _key5)  { _obj5  = value; }
      else if (count == 6)  { _key6  = key; _obj6  = value; count++; } else if (key == _key6)  { _obj6  = value; }
      else if (count == 7)  { _key7  = key; _obj7  = value; count++; } else if (key == _key7)  { _obj7  = value; }
      else if (count == 8)  { _key8  = key; _obj8  = value; count++; } else if (key == _key8)  { _obj8  = value; }
      else if (count == 9)  { _key9  = key; _obj9  = value; count++; } else if (key == _key9)  { _obj9  = value; }
      else if (count == 10) { _key10 = key; _obj10 = value; count++; } else if (key == _key10) { _obj10 = value; }
      else if (count == 11) { _key11 = key; _obj11 = value; count++; } else if (key == _key11) { _obj11 = value; }
      else if (count == 12) { _key12 = key; _obj12 = value; count++; } else if (key == _key12) { _obj12 = value; }
      else if (count == 13) { _key13 = key; _obj13 = value; count++; } else if (key == _key13) { _obj13 = value; }
      else if (count == 14) { _key14 = key; _obj14 = value; count++; } else if (key == _key14) { _obj14 = value; }
      else if (count == 15) { _key15 = key; _obj15 = value; count++; } else if (key == _key15) { _obj15 = value; }
      else if (count == 16) { _key16 = key; _obj16 = value; count++; } else if (key == _key16) { _obj16 = value; }
      else if (count == 17) { _key17 = key; _obj17 = value; count++; } else if (key == _key17) { _obj17 = value; }
      else if (count == 18) { _key18 = key; _obj18 = value; count++; } else if (key == _key18) { _obj18 = value; }
      else if (count == 19) { _key19 = key; _obj19 = value; count++; } else if (key == _key19) { _obj19 = value; }
      else if (count == 20) {
        _copyAllElementsToMap();
        delegate[key] = value;
      }
    } else {
      delegate[key] = value;
    }
  }

  int get mode {
    return delegate == null ? MODE_ARRAY : MODE_MAP;
  }

  String toString() {
    var elements = [];
    if (delegate == null) {
      if (count > 0)  elements.add('${_key0}: ${_obj0}');
      if (count > 1)  elements.add('${_key1}: ${_obj1}');
      if (count > 2)  elements.add('${_key2}: ${_obj2}');
      if (count > 3)  elements.add('${_key3}: ${_obj3}');
      if (count > 4)  elements.add('${_key4}: ${_obj4}');
      if (count > 5)  elements.add('${_key5}: ${_obj5}');
      if (count > 6)  elements.add('${_key6}: ${_obj6}');
      if (count > 7)  elements.add('${_key7}: ${_obj7}');
      if (count > 8)  elements.add('${_key8}: ${_obj8}');
      if (count > 9)  elements.add('${_key9}: ${_obj9}');
      if (count > 10) elements.add('${_key10}: ${_obj10}');
      if (count > 11) elements.add('${_key11}: ${_obj11}');
      if (count > 12) elements.add('${_key12}: ${_obj12}');
      if (count > 13) elements.add('${_key13}: ${_obj13}');
      if (count > 14) elements.add('${_key14}: ${_obj14}');
      if (count > 15) elements.add('${_key15}: ${_obj15}');
      if (count > 16) elements.add('${_key16}: ${_obj16}');
      if (count > 17) elements.add('${_key17}: ${_obj17}');
      if (count > 18) elements.add('${_key18}: ${_obj18}');
      if (count > 19) elements.add('${_key19}: ${_obj19}');
      return '{${elements.join(', ')}}';
    }
    return '$delegate';
  }

  void _clearAllElements() {
    count = 0;
    _key0 = null; _obj0 = null;
    _key1 = null; _obj1 = null;
    _key2 = null; _obj2 = null;
    _key3 = null; _obj3 = null;
    _key4 = null; _obj4 = null;
    _key5 = null; _obj5 = null;
    _key6 = null; _obj6 = null;
    _key7 = null; _obj7 = null;
    _key8 = null; _obj8 = null;
    _key9 = null; _obj9 = null;
    _key10 = null; _obj10 = null;
    _key11 = null; _obj11 = null;
    _key12 = null; _obj12 = null;
    _key13 = null; _obj13 = null;
    _key14 = null; _obj14 = null;
    _key15 = null; _obj15 = null;
    _key16 = null; _obj16 = null;
    _key17 = null; _obj17 = null;
    _key18 = null; _obj18 = null;
    _key19 = null; _obj19 = null;
  }

  void _copyAllElementsToMap() {
    delegate = new HashMap();
    delegate[_key0] = _obj0;
    delegate[_key1] = _obj1;
    delegate[_key2] = _obj2;
    delegate[_key3] = _obj3;
    delegate[_key4] = _obj4;
    delegate[_key5] = _obj5;
    delegate[_key6] = _obj6;
    delegate[_key7] = _obj7;
    delegate[_key8] = _obj8;
    delegate[_key9] = _obj9;
    delegate[_key10] = _obj10;
    delegate[_key11] = _obj11;
    delegate[_key12] = _obj12;
    delegate[_key13] = _obj13;
    delegate[_key14] = _obj14;
    delegate[_key15] = _obj15;
    delegate[_key16] = _obj16;
    delegate[_key17] = _obj17;
    delegate[_key18] = _obj18;
    delegate[_key19] = _obj19;
    _clearAllElements();
  }
}
