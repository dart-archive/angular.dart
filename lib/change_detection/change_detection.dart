library change_detection;

/**
 * Factory method for creating dirty checkers. This method would return a polyfill or
 * native VM implementation depending on the browser.
 *
 */
ChangeDetector createChangeDetector() => null;

/**
 * An interface for ChangeDetector. An application can have multiple instance of the
 * [ChangeDetector] to be used for checking different application domains.
 *
 * ChangeDetector works by comparing the identity of the objects not by calling the [.equals()]
 * method. This is because ChangeDetector needs to have predictable performance, and the
 * developer can implement [.equals()] on top of identity checks.
 *
 * - [H] A watch has associated handler object. The handler object is opaque to the [ChangeDetector]
 *   but it is meaningful to the code which registered the watcher. It can be data structure,
 *   object, or function. It is up to the developer to attach meaning to it.
 */
abstract class ChangeDetector<H> {

  /**
   * Watch a specific [field] on an [object].
   *
   * If the [field] is:
   *   - _name_ - Name of the field to watch. (If the [object is a Map then treat it as a key.)
   *   - _[]_ - Watch all items in an array.
   *   - _{}_ - Watch all items in a Map.
   *   - _._ - Watch the actual object identity.
   *
   *
   * Parameters:
   * - [object] to watch.
   * - [field] to watch on the [object].
   * - [handler] an opaque object passed on to [ChangeRecord].
   * - [after] the [WatchRecord] is to be inserted [after] a given WatchRecord.
   */
  WatchRecord<H> watch(Object object, String field, H handler, {WatchRecord<H> after});

  /**
   * This method does the work of collecting the changes and returns them as a List of
   * [ChangeRecord]s. The [ChangeRecord]s are to be sorted by the [ID].
   */
  ChangeRecord<H> collectChanges();


  /**
   * Use to remove large blocks of watches efficiently.
   *
   * - [from] An [WatcheRecord] from which the removal will start (inclusive).
   * - [to] An [WatchRecord] where the removal will stop (inclusive). (if omitted only change
   *   remove the from record.)
   */
  void remove(WatchRecord<H> from, [WatchRecord<H> to]);
}

abstract class Record<H> {
  /** The object where the change occurred. */
  Object get object;

  /**
   * The field which is being watched.
   *
   * The string is:
   *   - _name_ - Name of the field to watch.
   *   - _[]_ - Watch all items in an array.
   *   - _{}_ - Watch all items in a Map.
   *   - _._ - Watch the actual object identity.
   */
  String get field;

  /**
   *  The handler is an application provided object which contains the specific logic
   *  which needs to be applied when the change is detected. The handler is opaque to the
   *  ChangeDetector and as such can be anything the application desires.
   */
  H get handler;

  dynamic get currentValue;
  dynamic get previousValue;
}

abstract class WatchRecord<H> extends Record<H> {
  set object(dynamic value);
  ChangeRecord<H> check();
  void remove();
}

/**
 * A change record provides information about the changes which were detected in objects.
 */
abstract class ChangeRecord<H> extends Record<H> {
  ChangeRecord<H> get nextChange;
}

abstract class CollectionChangeItem {
  /** Previous item location in the list or [null] if addition. */
  dynamic get previousKey;

  /** Current item location in the list or [null] if removal. */
  dynamic get currentKey;

  /** The item. */
  dynamic get item;
}
