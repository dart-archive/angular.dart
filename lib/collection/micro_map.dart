library angular.collection;

import 'dart:collection';

const int _LIST_ELEMENTS = 20;
const int MODE_ARRAY = 0;
const int MODE_MAP = 1;

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
  int count;
  Map<K, V> delegate;


  MicroMap() {
    count = 0;
  }

  bool containsValue(Object value) {
    if (delegate == null) {
      if(_obj0 == value) return true;
      if(count == 0) return false;
      if(_obj1 == value) return true;
      if(count == 1) return false;
      if(_obj2 == value) return true;
      if(count == 2) return false;
      if(_obj3 == value) return true;
      if(count == 3) return false;
      if(_obj4 == value) return true;
      if(count == 4) return false;
      if(_obj5 == value) return true;
      if(count == 5) return false;
      if(_obj6 == value) return true;
      if(count == 6) return false;
      if(_obj7 == value) return true;
      if(count == 7) return false;
      if(_obj8 == value) return true;
      if(count == 8) return false;
      if(_obj9 == value) return true;
      if(count == 9) return false;
      if(_obj10 == value) return true;
      if(count == 10) return false;
      if(_obj11 == value) return true;
      if(count == 11) return false;
      if(_obj12 == value) return true;
      if(count == 12) return false;
      if(_obj13 == value) return true;
      if(count == 13) return false;
      if(_obj14 == value) return true;
      if(count == 14) return false;
      if(_obj15 == value) return true;
      if(count == 15) return false;
      if(_obj16 == value) return true;
      if(count == 16) return false;
      if(_obj17 == value) return true;
      if(count == 17) return false;
      if(_obj18 == value) return true;
      if(count == 18) return false;
      if(_obj19 == value) return true;
      return false;
    } else {
      return delegate.containsValue(value);
    }
  }

  bool containsKey(Object key) {
    if (delegate == null) {
      if(_key0 == null) return false;
      if(_key0 == key) return true;
      if(_key1 == null) return false;
      if(_key1 == key) return true;
      if(_key2 == null) return false;
      if(_key2 == key) return true;
      if(_key3 == null) return false;
      if(_key3 == key) return true;
      if(_key4 == null) return false;
      if(_key4 == key) return true;
      if(_key5 == null) return false;
      if(_key5 == key) return true;
      if(_key6 == null) return false;
      if(_key6 == key) return true;
      if(_key7 == null) return false;
      if(_key7 == key) return true;
      if(_key8 == null) return false;
      if(_key8 == key) return true;
      if(_key9 == null) return false;
      if(_key9 == key) return true;
      if(_key10 == null) return false;
      if(_key10 == key) return true;
      if(_key11 == null) return false;
      if(_key11 == key) return true;
      if(_key12 == null) return false;
      if(_key12 == key) return true;
      if(_key13 == null) return false;
      if(_key13 == key) return true;
      if(_key14 == null) return false;
      if(_key14 == key) return true;
      if(_key15 == null) return false;
      if(_key15 == key) return true;
      if(_key16 == null) return false;
      if(_key16 == key) return true;
      if(_key17 == null) return false;
      if(_key17 == key) return true;
      if(_key18 == null) return false;
      if(_key18 == key) return true;
      if(_key19 == null) return false;
      if(_key19 == key) return true;
      return false;
    } else {
      return delegate.containsKey(key);
    }
  }

  V putIfAbsent(K key, V ifAbsent()) {
    if(delegate==null) {
      if (_key0 == null) { _key0 = key; _obj0 = ifAbsent(); count++; return _obj0; }
      else if (_key0 == key ) { return _obj0; }
      else if (_key1 == null) { _key1 = key; _obj1 = ifAbsent(); count++; return _obj1; }
      else if (_key1 == key ) { return _obj1; }
      else if (_key2 == null) { _key2 = key; _obj2 = ifAbsent(); count++; return _obj2; }
      else if (_key2 == key ) { return _obj2; }
      else if (_key3 == null) { _key3 = key; _obj3 = ifAbsent(); count++; return _obj3; }
      else if (_key3 == key ) { return _obj3; }
      else if (_key4 == null) { _key4 = key; _obj4 = ifAbsent(); count++; return _obj4; }
      else if (_key4 == key ) { return _obj4; }
      else if (_key5 == null) { _key5 = key; _obj5 = ifAbsent(); count++; return _obj5; }
      else if (_key5 == key ) { return _obj5; }
      else if (_key6 == null) { _key6 = key; _obj6 = ifAbsent(); count++; return _obj6;}
      else if (_key6 == key ) { return _obj6; }
      else if (_key7 == null) { _key7 = key; _obj7 = ifAbsent(); count++; return _obj7; }
      else if (_key7 == key ) { return _obj7; }
      else if (_key8 == null) { _key8 = key; _obj8 = ifAbsent(); count++; return _obj8; }
      else if (_key8 == key ) { return _obj8; }
      else if (_key9 == null) { _key9 = key; _obj9 = ifAbsent(); count++; return _obj9; }
      else if (_key9 == key ) { return _obj9; }
      else if (_key10 == null) { _key10 = key; _obj10 = ifAbsent(); count++; return _obj10; }
      else if (_key10 == key ) { return _obj10; }
      else if (_key11 == null) { _key11 = key; _obj11 = ifAbsent(); count++; return _obj11; }
      else if (_key11 == key ) { return _obj11; }
      else if (_key12 == null) { _key12 = key; _obj12 = ifAbsent(); count++; return _obj12; }
      else if (_key12 == key ) { return _obj12; }
      else if (_key13 == null) { _key13 = key; _obj13 = ifAbsent(); count++; return _obj13; }
      else if (_key13 == key ) { return _obj13; }
      else if (_key14 == null) { _key14 = key; _obj14 = ifAbsent(); count++; return _obj14; }
      else if (_key14 == key ) { return _obj14; }
      else if (_key15 == null) { _key15 = key; _obj15 = ifAbsent(); count++; return _obj15; }
      else if (_key15 == key ) { return _obj15; }
      else if (_key16 == null) { _key16 = key; _obj16 = ifAbsent(); count++; return _obj16; }
      else if (_key16 == key ) { return _obj16; }
      else if (_key17 == null) { _key17 = key; _obj17 = ifAbsent(); count++; return _obj17; }
      else if (_key17 == key ) { return _obj1; }
      else if (_key18 == null) { _key18 = key; _obj18 = ifAbsent(); count++; return _obj18; }
      else if (_key18 == key ) { return _obj1; }
      else if (_key19 == null) { _key19 = key; _obj19 = ifAbsent(); count++; return _obj19; }
      else if (_key19 == key ) { return _obj19; }

    } else {
      return delegate.putIfAbsent(key, ifAbsent);
    }
  }

  void addAll(Map<K, V> other) {
    other.forEach((K key, V value) => _put(key, value));
  }

  V remove(Object key) {
    if (delegate == null) {
      var value = null;
      if (_key0 == key) { value = _obj0; _key0 = null; _obj0 = null; }
      else if (_key1 == key) { value = _obj1; _key1 = null; _obj1 = null; }
      else if (_key2 == key) { value = _obj2; _key2 = null; _obj2 = null; }
      else if (_key3 == key) { value = _obj3; _key3 = null; _obj3 = null; }
      else if (_key4 == key) { value = _obj4; _key4 = null; _obj4 = null; }
      else if (_key5 == key) { value = _obj5; _key5 = null; _obj5 = null; }
      else if (_key6 == key) { value = _obj6; _key6 = null; _obj6 = null; }
      else if (_key7 == key) { value = _obj7; _key7 = null; _obj7 = null; }
      else if (_key8 == key) { value = _obj8; _key8 = null; _obj8 = null; }
      else if (_key9 == key) { value = _obj9; _key9 = null; _obj9 = null; }
      else if (_key10 == key) { value = _obj10; _key10 = null; _obj10 = null; }
      else if (_key11 == key) { value = _obj11; _key11 = null; _obj11 = null; }
      else if (_key12 == key) { value = _obj12; _key12 = null; _obj12 = null; }
      else if (_key13 == key) { value = _obj13; _key13 = null; _obj13 = null; }
      else if (_key14 == key) { value = _obj14; _key14 = null; _obj14 = null; }
      else if (_key15 == key) { value = _obj15; _key15 = null; _obj15 = null; }
      else if (_key16 == key) { value = _obj16; _key16 = null; _obj16 = null; }
      else if (_key17 == key) { value = _obj17; _key17 = null; _obj17 = null; }
      else if (_key18 == key) { value = _obj18; _key18 = null; _obj18 = null; }
      else if (_key19 == key) { value = _obj19; _key19 = null; _obj19 = null; }
      if (value != null) {
        count--;
        _fillHole();
      }
      return value;
    }
    else {
      var value = delegate.remove(key);
      if (delegate.length <= _LIST_ELEMENTS) _copyMapToElements();
      return value;
    }
  }

  void clear() {
    _clearAllElements();
    if (delegate != null) delegate = null;
  }

  void forEach(void f(K key, V value)) {

  }

  Iterable<K> get keys {
    if (delegate != null) return delegate.keys;
    List ks = [];
    if(_key0 != null) ks.add(_key0);
    if(_key1 != null) ks.add(_key1);
    if(_key2 != null) ks.add(_key2);
    if(_key3 != null) ks.add(_key3);
    if(_key4 != null) ks.add(_key4);
    if(_key5 != null) ks.add(_key5);
    if(_key6 != null) ks.add(_key6);
    if(_key7 != null) ks.add(_key7);
    if(_key8 != null) ks.add(_key8);
    if(_key9 != null) ks.add(_key9);
    if(_key10 != null) ks.add(_key10);
    if(_key11 != null) ks.add(_key11);
    if(_key12 != null) ks.add(_key12);
    if(_key13 != null) ks.add(_key13);
    if(_key14 != null) ks.add(_key14);
    if(_key15 != null) ks.add(_key15);
    if(_key16 != null) ks.add(_key16);
    if(_key17 != null) ks.add(_key17);
    if(_key18 != null) ks.add(_key18);
    if(_key19 != null) ks.add(_key19);
    return ks;
  }

  Iterable<V> get values {
    if (delegate != null) return delegate.values;
    List vs = [];
    if(_obj0 != null) vs.add(_obj0);
    if(_obj1 != null) vs.add(_obj1);
    if(_obj2 != null) vs.add(_obj2);
    if(_obj3 != null) vs.add(_obj3);
    if(_obj4 != null) vs.add(_obj4);
    if(_obj5 != null) vs.add(_obj5);
    if(_obj6 != null) vs.add(_obj6);
    if(_obj7 != null) vs.add(_obj7);
    if(_obj8 != null) vs.add(_obj8);
    if(_obj9 != null) vs.add(_obj9);
    if(_obj10 != null) vs.add(_obj10);
    if(_obj11 != null) vs.add(_obj11);
    if(_obj12 != null) vs.add(_obj12);
    if(_obj13 != null) vs.add(_obj13);
    if(_obj14 != null) vs.add(_obj14);
    if(_obj15 != null) vs.add(_obj15);
    if(_obj16 != null) vs.add(_obj16);
    if(_obj17 != null) vs.add(_obj17);
    if(_obj18 != null) vs.add(_obj18);
    if(_obj19 != null) vs.add(_obj19);
    return vs;
  }

  int get length {
    return delegate == null ? count : delegate.length;
  }

  bool get isEmpty {
    return count == 0;
  }

  bool get isNotEmpty {
    return count != 0;
  }

  V operator [](K key) {
    if (delegate == null) {
      if (key == _key0) return _obj0;
      if (key == _key1) return _obj1;
      if (key == _key2) return _obj2;
      if (key == _key3) return _obj3;
      if (key == _key4) return _obj4;
      if (key == _key5) return _obj5;
      if (key == _key6) return _obj6;
      if (key == _key7) return _obj7;
      if (key == _key8) return _obj8;
      if (key == _key9) return _obj9;
      if (key == _key10) return _obj10;
      if (key == _key11) return _obj11;
      if (key == _key12) return _obj12;
      if (key == _key13) return _obj13;
      if (key == _key14) return _obj14;
      if (key == _key15) return _obj15;
      if (key == _key16) return _obj16;
      if (key == _key17) return _obj17;
      if (key == _key18) return _obj18;
      if (key == _key19) return _obj19;
    } else {
      return delegate[key];
    }
    return null;
  }

  void operator []=(K key, V value) {
    if (this[key] == null) count++;
    if      (_key0 == null || _key0 == key) { _key0 = key; _obj0 = value; }
    else if (_key1 == null || _key1 == key) { _key1 = key; _obj1 = value; }
    else if (_key2 == null || _key2 == key) { _key2 = key; _obj2 = value; }
    else if (_key3 == null || _key3 == key) { _key3 = key; _obj3 = value; }
    else if (_key4 == null || _key4 == key) { _key4 = key; _obj4 = value; }
    else if (_key5 == null || _key5 == key) { _key5 = key; _obj5 = value; }
    else if (_key6 == null || _key6 == key) { _key6 = key; _obj6 = value; }
    else if (_key7 == null || _key7 == key) { _key7 = key; _obj7 = value; }
    else if (_key8 == null || _key8 == key) { _key8 = key; _obj8 = value; }
    else if (_key9 == null || _key9 == key) { _key9 = key; _obj9 = value; }
    else if (_key10 == null || _key10 == key) { _key10 = key; _obj10 = value; }
    else if (_key11 == null || _key11 == key) { _key11 = key; _obj11 = value; }
    else if (_key12 == null || _key12 == key) { _key12 = key; _obj12 = value; }
    else if (_key13 == null || _key13 == key) { _key13 = key; _obj13 = value; }
    else if (_key14 == null || _key14 == key) { _key14 = key; _obj14 = value; }
    else if (_key15 == null || _key15 == key) { _key15 = key; _obj15 = value; }
    else if (_key16 == null || _key16 == key) { _key16 = key; _obj16 = value; }
    else if (_key17 == null || _key17 == key) { _key17 = key; _obj17 = value; }
    else if (_key18 == null || _key18 == key) { _key18 = key; _obj18 = value; }
    else if (_key19 == null || _key19 == key) { _key19 = key; _obj19 = value; }
    else {
        _copyAllElementsToMap();
        if (delegate==null) delegate = new HashMap();
        delegate[key] = value;
    }
  }

  int get mode {
    return delegate == null ? MODE_ARRAY : MODE_MAP;
  }

  String toString() {
    var elements = [];
    if (delegate == null) {
        if(_key0 != null) elements.add('${_key0}: ${_obj0}');
        if(_key1 != null) elements.add('${_key1}: ${_obj1}');
        if(_key2 != null) elements.add('${_key2}: ${_obj2}');
        if(_key3 != null) elements.add('${_key3}: ${_obj3}');
        if(_key4 != null) elements.add('${_key4}: ${_obj4}');
        if(_key5 != null) elements.add('${_key5}: ${_obj5}');
        if(_key6 != null) elements.add('${_key6}: ${_obj6}');
        if(_key7 != null) elements.add('${_key7}: ${_obj7}');
        if(_key8 != null) elements.add('${_key8}: ${_obj8}');
        if(_key9 != null) elements.add('${_key9}: ${_obj9}');
        if(_key10 != null) elements.add('${_key10}: ${_obj10}');
        if(_key11 != null) elements.add('${_key11}: ${_obj11}');
        if(_key12 != null) elements.add('${_key12}: ${_obj12}');
        if(_key13 != null) elements.add('${_key13}: ${_obj13}');
        if(_key14 != null) elements.add('${_key14}: ${_obj14}');
        if(_key15 != null) elements.add('${_key15}: ${_obj15}');
        if(_key16 != null) elements.add('${_key16}: ${_obj16}');
        if(_key17 != null) elements.add('${_key17}: ${_obj17}');
        if(_key18 != null) elements.add('${_key18}: ${_obj18}');
        if(_key19 != null) elements.add('${_key19}: ${_obj19}');
      return '{${elements.join(', ')}}';
    }
    return '$delegate';
  }

  void _clearAllElements() {
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
    var i = 0;
    if (delegate==null) delegate = new HashMap();
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

  void _copyMapToElements() {
    List<K> ks = delegate.keys.toList();
    _key0 = ks[0]; _obj0 = delegate[_key0];
    _key1 = ks[1]; _obj1 = delegate[_key1];
    _key2 = ks[2]; _obj2 = delegate[_key2];
    _key3 = ks[3]; _obj3 = delegate[_key3];
    _key4 = ks[4]; _obj4 = delegate[_key4];
    _key5 = ks[5]; _obj5 = delegate[_key5];
    _key6 = ks[6]; _obj6 = delegate[_key6];
    _key7 = ks[7]; _obj7 = delegate[_key7];
    _key8 = ks[8]; _obj8 = delegate[_key8];
    _key9 = ks[9]; _obj9 = delegate[_key9];
    _key10 = ks[10]; _obj10 = delegate[_key10];
    _key11 = ks[11]; _obj11 = delegate[_key11];
    _key12 = ks[12]; _obj12 = delegate[_key12];
    _key13 = ks[13]; _obj13 = delegate[_key13];
    _key14 = ks[14]; _obj14 = delegate[_key14];
    _key15 = ks[15]; _obj15 = delegate[_key15];
    _key16 = ks[16]; _obj16 = delegate[_key16];
    _key17 = ks[17]; _obj17 = delegate[_key17];
    _key18 = ks[18]; _obj18 = delegate[_key18];
    _key19 = ks[19]; _obj19 = delegate[_key19];
    count = _LIST_ELEMENTS;
    delegate = null;
  }

  void _fillHole() {
    var lastKey, lastObj;
    // find the last element which is not null and remove it
    if (_key19 != null) { lastKey = _key19; lastObj = _obj19; }
    else if (_key18 != null) { lastKey = _key18; lastObj = _obj18; _key18 = null; _obj18 = null; }
    else if (_key17 != null) { lastKey = _key17; lastObj = _obj17; _key17 = null; _obj17 = null; }
    else if (_key16 != null) { lastKey = _key16; lastObj = _obj16; _key16 = null; _obj16 = null; }
    else if (_key15 != null) { lastKey = _key15; lastObj = _obj15; _key15 = null; _obj15 = null; }
    else if (_key14 != null) { lastKey = _key14; lastObj = _obj14; _key14 = null; _obj14 = null; }
    else if (_key13 != null) { lastKey = _key13; lastObj = _obj13; _key13 = null; _obj13 = null; }
    else if (_key12 != null) { lastKey = _key12; lastObj = _obj12; _key12 = null; _obj12 = null; }
    else if (_key11 != null) { lastKey = _key11; lastObj = _obj11; _key11 = null; _obj11 = null; }
    else if (_key10 != null) { lastKey = _key10; lastObj = _obj10; _key10 = null; _obj10 = null; }
    else if (_key9  != null) { lastKey = _key9 ; lastObj = _obj9 ; _key9  = null; _obj9  = null; }
    else if (_key8  != null) { lastKey = _key8 ; lastObj = _obj8 ; _key8  = null; _obj8  = null; }
    else if (_key7  != null) { lastKey = _key7 ; lastObj = _obj7 ; _key7  = null; _obj7  = null; }
    else if (_key6  != null) { lastKey = _key6 ; lastObj = _obj6 ; _key6  = null; _obj6  = null; }
    else if (_key5  != null) { lastKey = _key5 ; lastObj = _obj5 ; _key5  = null; _obj5  = null; }
    else if (_key4  != null) { lastKey = _key4 ; lastObj = _obj4 ; _key4  = null; _obj4  = null; }
    else if (_key3  != null) { lastKey = _key3 ; lastObj = _obj3 ; _key3  = null; _obj3  = null; }
    else if (_key2  != null) { lastKey = _key2 ; lastObj = _obj2 ; _key2  = null; _obj2  = null; }
    else if (_key1  != null) { lastKey = _key1 ; lastObj = _obj1 ; _key1  = null; _obj1  = null; }
    else if (_key0  != null) { lastKey = _key0 ; lastObj = _obj0 ; _key0  = null; _obj0  = null; }
    if (lastKey != null) {
      // fill in first element which is null
      if(_key0  == null) { _key0  = lastKey; _obj0  = lastObj; }
      else if(_key1  == null) { _key1  = lastKey; _obj1  = lastObj; }
      else if(_key2  == null) { _key2  = lastKey; _obj2  = lastObj; }
      else if(_key3  == null) { _key3  = lastKey; _obj3  = lastObj; }
      else if(_key4  == null) { _key4  = lastKey; _obj4  = lastObj; }
      else if(_key5  == null) { _key5  = lastKey; _obj5  = lastObj; }
      else if(_key6  == null) { _key6  = lastKey; _obj6  = lastObj; }
      else if(_key7  == null) { _key7  = lastKey; _obj7  = lastObj; }
      else if(_key8  == null) { _key8  = lastKey; _obj8  = lastObj; }
      else if(_key9  == null) { _key9  = lastKey; _obj9  = lastObj; }
      else if(_key10 == null) { _key10 = lastKey; _obj10 = lastObj; }
      else if(_key11 == null) { _key11 = lastKey; _obj11 = lastObj; }
      else if(_key12 == null) { _key12 = lastKey; _obj12 = lastObj; }
      else if(_key13 == null) { _key13 = lastKey; _obj13 = lastObj; }
      else if(_key14 == null) { _key14 = lastKey; _obj14 = lastObj; }
      else if(_key15 == null) { _key15 = lastKey; _obj15 = lastObj; }
      else if(_key16 == null) { _key16 = lastKey; _obj16 = lastObj; }
      else if(_key17 == null) { _key17 = lastKey; _obj17 = lastObj; }
      else if(_key18 == null) { _key18 = lastKey; _obj18 = lastObj; }
      else if(_key18 == null) { _key18 = lastKey; _obj18 = lastObj; }
    }
  }

  V _put(K key, V value) {
    if (count >= _LIST_ELEMENTS) {
      _copyAllElementsToMap();
      return delegate[key] = value;
    } else {
      this[key] = value;
      return value;
    }
  }
}