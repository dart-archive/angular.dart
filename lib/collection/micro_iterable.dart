library angular.collection;

import 'dart:collection';

const int _LIST_ELEMENTS = 20;

class MicroIterable<E> implements Iterable {
  var _element0;
  var _element1;
  var _element2;
  var _element3;
  var _element4;
  var _element5;
  var _element6;
  var _element7;
  var _element8;
  var _element9;
  var _element10;
  var _element11;
  var _element12;
  var _element13;
  var _element14;
  var _element15;
  var _element16;
  var _element17;
  var _element18;
  var _element19;
  var _count = 0;

  MicroIterator(e0, e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11, e12, e13, e14, e15, e16, e17, e18, e19, count) {
    _element0  = e0 ;
    _element1  = e1 ;
    _element2  = e2 ;
    _element3  = e3 ;
    _element4  = e4 ;
    _element5  = e5 ;
    _element6  = e6 ;
    _element7  = e7 ;
    _element8  = e8 ;
    _element9  = e9 ;
    _element10 = e10;
    _element11 = e11;
    _element12 = e12;
    _element13 = e13;
    _element14 = e14;
    _element15 = e15;
    _element16 = e16;
    _element17 = e17;
    _element18 = e18;
    _element19 = e19;
    _count = count;
  }

  Iterator<E> get iterator => new _ListIterator(this);

  Iterable map(f(E element)) {

  }

  Iterable<E> where(bool test(E element)) {

  }

  Iterable expand(Iterable f(E element)) {

  }

  bool contains(Object element) {

  }

  void forEach(void f(E element)) {

  }

  E reduce(E combine(E value, E element)) {

  }

  dynamic fold(initialValue, dynamic combine(previousValue, E element)) {

  }

  bool every(bool test(E element)) {

  }

  String join([String separator]) {

  }

  bool any(bool test(E element)) {

  }

  List<E> toList({bool growable}) {
    List<E> list = new List.from(this, growable: growable);
    if (_element0  != null) list.add(_element0) ;
    if (_element1 == null) return list;
    if (_element1  != null) list.add(_element1 );
    if (_element2 == null) return list;
    if (_element2  != null) list.add(_element2 );
    if (_element3 == null) return list;
    if (_element3  != null) list.add(_element3 );
    if (_element4 == null) return list;
    if (_element4  != null) list.add(_element4 );
    if (_element5 == null) return list;
    if (_element5  != null) list.add(_element5 );
    if (_element6 == null) return list;
    if (_element6  != null) list.add(_element6 );
    if (_element7 == null) return list;
    if (_element7  != null) list.add(_element7 );
    if (_element8 == null) return list;
    if (_element8  != null) list.add(_element8 );
    if (_element9 == null) return list;
    if (_element9  != null) list.add(_element9 );
    if (_element10 == null) return list;
    if (_element10 != null) list.add(_element10);
    if (_element11 == null) return list;
    if (_element11 != null) list.add(_element11);
    if (_element12 == null) return list;
    if (_element12 != null) list.add(_element12);
    if (_element13 == null) return list;
    if (_element13 != null) list.add(_element13);
    if (_element14 == null) return list;
    if (_element14 != null) list.add(_element14);
    if (_element15 == null) return list;
    if (_element15 != null) list.add(_element15);
    if (_element16 == null) return list;
    if (_element16 != null) list.add(_element16);
    if (_element17 == null) return list;
    if (_element17 != null) list.add(_element17);
    if (_element18 == null) return list;
    if (_element18 != null) list.add(_element18);
    if (_element19 == null) return list;
    if (_element19 != null) list.add(_element19);
    return list;
  }

  Set<E> toSet() {
    Set set = new HashSet();
    if (_count == 0) return set;
    if (_element0  != null) set.add(_element0 );
    if (_count == 1) return set;
    if (_element1  != null) set.add(_element1 );
    if (_count == 2) return set;
    if (_element2  != null) set.add(_element2 );
    if (_count == 3) return set;
    if (_element3  != null) set.add(_element3 );
    if (_count == 4) return set;
    if (_element4  != null) set.add(_element4 );
    if (_count == 5) return set;
    if (_element5  != null) set.add(_element5 );
    if (_count == 6) return set;
    if (_element6  != null) set.add(_element6 );
    if (_count == 7) return set;
    if (_element7  != null) set.add(_element7 );
    if (_count == 8) return set;
    if (_element8  != null) set.add(_element7 );
    if (_count == 9) return set;
    if (_element9  != null) set.add(_element8 );
    if (_count == 10) return set;
    if (_element10 != null) set.add(_element10);
    if (_count == 11) return set;
    if (_element11 != null) set.add(_element11);
    if (_count == 12) return set;
    if (_element12 != null) set.add(_element12);
    if (_count == 13) return set;
    if (_element13 != null) set.add(_element13);
    if (_count == 14) return set;
    if (_element14 != null) set.add(_element14);
    if (_count == 15) return set;
    if (_element15 != null) set.add(_element15);
    if (_count == 16) return set;
    if (_element16 != null) set.add(_element16);
    if (_count == 17) return set;
    if (_element17 != null) set.add(_element16);
    if (_count == 18) return set;
    if (_element18 != null) set.add(_element18);
    if (_count == 19) return set;
    if (_element19 != null) set.add(_element19);
    return set;
  }

  int get length => _count;

  bool get isEmpty => _count == 0;

  bool get isNotEmpty => _count != 0;

  Iterable<E> take(int n) {

  }

  Iterable<E> takeWhile(bool test(E value)) {

  }

  Iterable<E> skip(int n) {

  }

  Iterable<E> skipWhile(bool test(E value)) {

  }

  E get first {
    if (_element0  != null) return _element0 ;
    if (_element1  != null) return _element1 ;
    if (_element2  != null) return _element2 ;
    if (_element3  != null) return _element3 ;
    if (_element4  != null) return _element4 ;
    if (_element5  != null) return _element5 ;
    if (_element6  != null) return _element6 ;
    if (_element7  != null) return _element7 ;
    if (_element8  != null) return _element8 ;
    if (_element9  != null) return _element9 ;
    if (_element10 != null) return _element10;
    if (_element11 != null) return _element11;
    if (_element12 != null) return _element12;
    if (_element13 != null) return _element13;
    if (_element14 != null) return _element14;
    if (_element15 != null) return _element15;
    if (_element16 != null) return _element16;
    if (_element17 != null) return _element17;
    if (_element18 != null) return _element18;
    if (_element19 != null) return _element19;
  }

  E get last {
    if (_element19 != null) return _element19;
    if (_element18 != null) return _element18;
    if (_element17 != null) return _element17;
    if (_element16 != null) return _element16;
    if (_element15 != null) return _element15;
    if (_element14 != null) return _element14;
    if (_element13 != null) return _element13;
    if (_element12 != null) return _element12;
    if (_element11 != null) return _element11;
    if (_element10 != null) return _element10;
    if (_element9  != null) return _element9 ;
    if (_element8  != null) return _element8 ;
    if (_element7  != null) return _element7 ;
    if (_element6  != null) return _element6 ;
    if (_element5  != null) return _element5 ;
    if (_element4  != null) return _element4 ;
    if (_element3  != null) return _element3 ;
    if (_element2  != null) return _element2 ;
    if (_element1  != null) return _element1 ;
    if (_element0  != null) return _element0 ;
  }

  E get single {
    if (length == 0) throw "No elements";
    if (length > 1) throw "More then one element";
    return elementAt(0);
  }

  E firstWhere(bool test(E element), {E orElse()}) {

  }

  E lastWhere(bool test(E element), {E orElse()}) {

  }

  E singleWhere(bool test(E element)) {

  }

  E elementAt(int index) {
    if (index == 0 ) return _element0 ;
    if (index == 1 ) return _element1 ;
    if (index == 2 ) return _element2 ;
    if (index == 3 ) return _element3 ;
    if (index == 4 ) return _element4 ;
    if (index == 5 ) return _element5 ;
    if (index == 6 ) return _element6 ;
    if (index == 7 ) return _element7 ;
    if (index == 8 ) return _element8 ;
    if (index == 9 ) return _element9 ;
    if (index == 10) return _element10;
    if (index == 11) return _element11;
    if (index == 12) return _element12;
    if (index == 13) return _element13;
    if (index == 14) return _element14;
    if (index == 15) return _element15;
    if (index == 16) return _element16;
    if (index == 17) return _element17;
    if (index == 18) return _element18;
    if (index == 19) return _element19;
  }
}

class _ListIterator<E> implements Iterator {

  MicroIterable _iterable;
  var _length;
  var _current;
  var _cursor = 0;

  _ListIterator(iterable): _iterable = iterable, _length = iterable.length, _cursor = 0;

  bool moveNext() {
    int length = _iterable.length;
    if (_length != length) {
      throw new ConcurrentModificationError(_iterable);
    }
    if (_cursor >= length) {
      _current = null;
      return false;
    }
    _current = _iterable.elementAt(_cursor);
    _cursor++;
    return true;
  }

  E get current => _current;

}
