library change_detection;

/**
 * An interface for [ChangeDetectorGroup] groups related watches together. It guarentees
 * that within the group all watches will be reported in the order in which they were registered.
 * It also provides an efficient way of removing the watch group.
 */
abstract class ChangeDetectorGroup<H> {
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
   */
  WatchRecord<H> watch(Object object, String field, H handler);


  /** Use to remove all watches in the group in an efficient manner. */
  void remove();

  /** Create a child [ChangeDetectorGroup] */
  ChangeDetectorGroup<H> newGroup();
}

/**
 * An interface for [ChangeDetector]. An application can have multiple instance of the
 * [ChangeDetector] to be used for checking different application domains.
 *
 * [ChangeDetector] works by comparing the identity of the objects not by calling the [.equals()]
 * method. This is because ChangeDetector needs to have predictable performance, and the
 * developer can implement [.equals()] on top of identity checks.
 *
 * - [H] A [ChangeRecord] has associated handler object. The handler object is opaque to the
 *   [ChangeDetector] but it is meaningful to the code which registered the watcher. It can be
 *   data structure, object, or function. It is up to the developer to attach meaning to it.
 */
class ChangeDetector<H> extends ChangeDetectorGroup<H> {
  /**
   * This method does the work of collecting the changes and returns them as a linked list of
   * [ChangeRecord]s. The [ChangeRecord]s are to be returned in the same order as they were
   * registered.
   */
  ChangeRecord<H> collectChanges();
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

  /** Current value of the [field] on the [object] */
  dynamic get currentValue;
  /** Previous value of the [field] on the [object] */
  dynamic get previousValue;
}

/**
 * [WatchRecord] API which allows changing what object is being watched and manually triggering the
 * checking.
 */
abstract class WatchRecord<H> extends Record<H> {
  /** Set a new object for checking */
  set object(dynamic value);

  /**
   * Check to see if the field on the object has changed. Returns [null] if no change, or a
   * [ChangeRecord] if the change has been detected.
   */
  ChangeRecord<H> check();

  void remove();
}

/**
 * A change record provides information about the changes which were detected in objects.
 *
 * It exposes a nextChange method for traversing all of the changes.
 */
abstract class ChangeRecord<H> extends Record<H> {
  /** Next [ChangeRecord] */
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
