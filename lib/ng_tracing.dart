/**
 * Tracing scopes in AngularDart.
 *
 * This library contains the scope definitions used in AngularDart for tracing purposes.
 */
library angular.tracing;

import 'package:tracing/tracing.dart';
export 'package:tracing/tracing.dart';

abstract class Application {
  /**
   * Designates a bootstrapping of AngularDart application in response to [Application.run()].
   * It usually contains compilation of templates and initial [Scope.apply()]
   */
  static final bootstrap = createScope('Application#bootstrap()');
}

abstract class ChangeDetector {
  /**
   * Designates where AngularDart detects changes in the model.
   * The checking is further subdivided into these sections:
   * - `ChangeDetector#fields()` looking for changes in object fields.
   * - `ChangeDetector#eval()` looking for changes by invoking functions.
   */
  static final check = createScope('ChangeDetector#check()');

  /**
   * Designates where AngularDart looks for changes in the model by differencing fields in watch
   * expressions.
   */
  static final fields = createScope('ChangeDetector#fields()');

  /**
   * Designates where AngularDart looks for changes in the model by invoking functions in watch
   * expressions.
   */
  static final eval = createScope('ChangeDetector#eval()');

  /**
   * Designates time spent processing the changes which were detected in `ChangeDetector#check()`.
   */
  static final reaction = createScope('ChangeDetector#reaction()');

  /**
   * Designates time spent processing the individual expressions in `ChangeDetector#reaction()`.
   */
  static final invoke = createScope('ChangeDetector#invoke(ascii expression)');
}

abstract class Scope {
  /**
   * When processing events angular transitions through stages in this sequence:
   *
   * - `Scope#apply()`
   * - `Scope#digest()`
   * - `Scope#flush()`
   *   - `Scope#domWrite()`
   *   - `Scope#domRead()`
   * - `Scope#assert()`
   */
  static final apply = createScope('Scope#apply()');

  /**
   * Process non-DOM changes in the model.
   */
  static final digest = createScope('Scope#digest()');

  /**
   * Process DOM changes in the model.
   */
  static final flush = createScope('Scope#flush()');

  /**
   * Process DOM write coalescence queue.
   */
  static final domWrite = createScope('Scope#domWrite()');

  /**
   * Process DOM read coalescence queue.
   */
  static final domRead = createScope('Scope#domRead()');

  /**
   * When asserts are enabled, verify that the `Scope#flush()` is idempotent, meaning it did
   * not make any further model changes.
   */
  static final assertChanges = createScope('Scope#assert()');

  /**
   * Process asynchronous microtask queue.
   */
  static final execAsync = createScope('Scope#execAsync()');

  /**
   * Create new Scope.
   */
  static final createChild = createScope('Scope#create()');
}

abstract class VmTurnZone {
  /**
   * Designates VM turn boundary, which ensures that Model changes get processed.
   */
  static final run = createScope('VmTurnZone#run()');

  /**
   * Designates where new microtasks are scheduled. This is usually in response to creating [Future]s.
   */
  static final scheduleMicrotask = createScope('VmTurnZone#scheduleMicrotask()');

}

abstract class Compiler {
  /**
   * Designates where template HTML is compiled. Compilation is a process of walking the DOM and
   * finding all of the directives.
   */
  static final compile = createScope('Compiler#compile()');

  /**
   * Designates `@Template` directive needs to compile its children. For example `ng-repeat`.
   */
  static final template = createScope('Compiler#template()');
}

abstract class View {
  /**
   * Designates new views are created.
   */
  static final create = createScope('View#create(ascii html)');

  /**
   * Designates components are created in a view. Components are treated differently than
   * other directives because they require creation of shadow scope and shadow DOM.
   */
  static final createComponent = createScope('View#createComponent()');

  /**
   * Designates where styles are inserted into component.
   */
  static final styles = createScope('View#styles()');
}

abstract class Directive {
  /**
   * Designates a particular directive is created. This includes the setting up of bindings for
   * the directive.
   */
  static final create = createScope('Directive#create(ascii name)');
}
