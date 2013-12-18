library linked_list;

class _LinkedList<I extends LinkedListItem> {
  I _head;
  I _tail;

  add(I item) {
    if (tail == null) {
      head = tail = item;
    } else {
      item.previous = tail;
      tail.next = item;
      tail = item;
    }
  }

  remove(I item) {

  }
}

class _LinkedListItem {
  _LinkedListITem _previous;
  _LinkedListItem _next;
}

class _LinkedListItemRef<I> extends _LinkedListItem {
  final I _item;

  _LinkedListItemRef(this._item);
}
