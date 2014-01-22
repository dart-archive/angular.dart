part of angular.core.dom;

/**
* ElementWrapper is an interface for [Block]s and [BlockHole]s. Its purpose is
* to allow treating [Block] and [BlockHole] under same interface so that
* [Block]s can be added after [BlockHole].
*/
abstract class ElementWrapper {
  List<dom.Node> elements;
  ElementWrapper next;
  ElementWrapper previous;
}

/**
 * A Block is a fundamental building block of DOM. It is a chunk of DOM which
 * can not be structural changed. It can only have its attributes changed.
 * A Block can have [BlockHole]s embedded in its DOM.  A [BlockHole] can
 * contain other [Block]s and it is the only way in which DOM can be changed
 * structurally.
 *
 * A [Block] is a collection of DOM nodes and [Directive]s for those nodes.
 *
 * A [Block] is responsible for instantiating the [Directive]s and for
 * inserting / removing itself to/from DOM.
 *
 * A [Block] can be created from [BlockFactory].
 *
 */
class Block implements ElementWrapper {
  List<dom.Node> elements;
  ElementWrapper next;
  ElementWrapper previous;

  Function onInsert;
  Function onRemove;
  Function onMove;

  List<dynamic> _directives = [];

  Block(this.elements);

  Block insertAfter(ElementWrapper previousBlock) {
    // Update Link List.
    next = previousBlock.next;
    if (next != null) {
      next.previous = this;
    }
    previous = previousBlock;
    previousBlock.next = this;

    // Update DOM
    List<dom.Node> previousElements = previousBlock.elements;
    dom.Node previousElement = previousElements[previousElements.length - 1];
    dom.Node insertBeforeElement = previousElement.nextNode;
    dom.Node parentElement = previousElement.parentNode;
    bool preventDefault = false;

    Function insertDomElements = () =>
        elements.forEach((el) => parentElement.insertBefore(el, insertBeforeElement));

    if (onInsert != null) {
      onInsert({
        "preventDefault": () {
          preventDefault = true;
          return insertDomElements;
        },
        "element": elements[0]
      });
    }

    if (!preventDefault) {
      insertDomElements();
    }
    return this;
  }

  Block remove() {
    bool preventDefault = false;

    Function removeDomElements = () {
      for(var j = 0, jj = elements.length; j < jj; j++) {
        dom.Node current = elements[j];
        dom.Node next = j+1 < jj ? elements[j+1] : null;

        while(next != null && current.nextNode != next) {
          current.nextNode.remove();
        }
        elements[j].remove();
      }
    };

    if (onRemove != null) {
      onRemove({
        "preventDefault": () {
          preventDefault = true;
          return removeDomElements();
        },
        "element": elements[0]
      });
    }

    if (!preventDefault) {
      removeDomElements();
    }

    // Remove block from list
    if (previous != null && (previous.next = next) != null) {
      next.previous = previous;
    }
    next = previous = null;
    return this;
  }

  Block moveAfter(ElementWrapper previousBlock) {
    var previousElements = previousBlock.elements,
        previousElement = previousElements[previousElements.length - 1],
        insertBeforeElement = previousElement.nextNode,
        parentElement = previousElement.parentNode;

    elements.forEach((el) => parentElement.insertBefore(el, insertBeforeElement));

    // Remove block from list
    previous.next = next;
    if (next != null) {
      next.previous = previous;
    }
    // Add block to list
    next = previousBlock.next;
    if (next != null) {
      next.previous = this;
    }
    previous = previousBlock;
    previousBlock.next = this;
    return this;
  }
}

/**
 * A BlockHole is an instance of a hole. BlockHoles designate where child
 * [Block]s can be added in parent [Block]. BlockHoles wrap a DOM element,
 * and act as references which allows more blocks to be added.
 */
class BlockHole extends ElementWrapper {
  List<dom.Node> elements;
  ElementWrapper previous;
  ElementWrapper next;

  BlockHole(this.elements);
}

