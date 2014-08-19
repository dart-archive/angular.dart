/**
 * Tracing scopes in AngularDart.
 *
 * This library contains the scope definitions used in AngularDart for tracing purposes.
 */
library angular.tracing.ng;

import 'package:angular/tracing.dart';

/**
 * Name: `Application#bootstrap()`
 *
 * Designates a bootstrapping of AngularDart application in response to [Application.run()].
 * It usually contains compilation of templates and initial [Scope.apply()]
 */
final Application_bootstrap = traceCreateScope('Application#bootstrap()');




/**
 * Name: `ChangeDetector#check()`
 *
 * Designates where AngularDart detects changes in the model.
 * The checking is further subdivided into these sections:
 * - `ChangeDetector#fields()` looking for changes in object fields.
 * - `ChangeDetector#eval()` looking for changes by invoking functions.
 */
final ChangeDetector_check = traceCreateScope('ChangeDetector#check()');

/**
 * Name: `ChangeDetector#fields()`
 *
 * Designates where AngularDart looks for changes in the model by differencing fields in watch
 * expressions.
 */
final ChangeDetector_fields = traceCreateScope('ChangeDetector#fields()');

/**
 * Name: `ChangeDetector#eval()`
 *
 * Designates where AngularDart looks for changes in the model by invoking functions in watch
 * expressions.
 */
final ChangeDetector_eval = traceCreateScope('ChangeDetector#eval()');

/**
 * Name: `ChangeDetector#reaction()`
 *
 * Designates time spent processing the changes which were detected in `ChangeDetector#check()`.
 */
final ChangeDetector_reaction = traceCreateScope('ChangeDetector#reaction()');

/**
 * Name: `ChangeDetector#reaction()`
 *
 * Designates time spent processing the individual expressions in `ChangeDetector#reaction()`.
 */
final ChangeDetector_invoke = traceCreateScope('ChangeDetector#invoke(ascii expression)');




/**
 * Name: `Scope#apply()`
 *
 * When processing events angular transitions through stages in this sequence:
 *
 * - `Scope#apply()`
 * - `Scope#digest()`
 * - `Scope#flush()`
 *   - `Scope#domWrite()`
 *   - `Scope#domRead()`
 * - `Scope#assert()`
 */
final Scope_apply = traceCreateScope('Scope#apply()');

/**
 * Name: `Scope#digest()`
 *
 * Process non-DOM changes in the model.
 */
final Scope_digest = traceCreateScope('Scope#digest()');

/**
 * Name: `Scope#flush()`
 *
 * Process DOM changes in the model.
 */
final Scope_flush = traceCreateScope('Scope#flush()');

/**
 * Name: `Scope#domWrite()`
 *
 * Process DOM write coalescence queue.
 */
final Scope_domWrite = traceCreateScope('Scope#domWrite()');

/**
 * Name: `Scope#domRead()`
 *
 * Process DOM read coalescence queue.
 */
final Scope_domRead = traceCreateScope('Scope#domRead()');

/**
 * Name: `Scope#assert()`
 *
 * When asserts are enabled, verify that the `Scope#flush()` is idempotent, meaning it did
 * not make any further model changes.
 */
final Scope_assert = traceCreateScope('Scope#assert()');


/**
 * Name: `Scope#execAsync()`
 *
 * Process asynchronous microtask queue.
 */
final Scope_execAsync = traceCreateScope('Scope#execAsync()');

/**
 * Name: `Scope#create()`
 *
 * Create new Scope.
 */
final Scope_createChild = traceCreateScope('Scope#create()');

/**
 * Name: `VmTurnZone#run()`
 *
 * Designates VM turn boundary, which ensures that Model changes get processed.
 */
final VmTurnZone_run = traceCreateScope('VmTurnZone#run()');

/**
 * Name: `VmTurnZone#scheduleMicrotask()`
 *
 * Designates where new microtasks are scheduled. This is usually in response to creating [Future]s.
 */
final VmTurnZone_scheduleMicrotask = traceCreateScope('VmTurnZone#scheduleMicrotask()');


/**
 * Name: `Compiler#compile()`
 *
 * Designates where template HTML is compiled. Compilation is a process of walking the DOM and
 * finding all of the directives.
 */
final Compiler_compile = traceCreateScope('Compiler#compile()');

/**
 * Name: `Compiler#template()`
 *
 * Designates `@Template` directive needs to compile its children. For example `ng-repeat`.
 */
final Compiler_template = traceCreateScope('Compiler#template()');

/**
 * Name: `View#create(ascii html)`
 *
 * Designates new views are created.
 */
final View_create = traceCreateScope('View#create(ascii html)');

/**
 * Name: `View#createComponent()`
 *
 * Designates components are created in a view. Components are treated differently than
 * other directives because they require creation of shadow scope and shadow DOM.
 */
final View_createComponent = traceCreateScope('View#createComponent()');

/**
 * Name: `View#styles()`
 *
 * Designates where styles are inserted into component.
 */
final View_styles = traceCreateScope('View#styles()');

/**
 * Name: `Directive#create(ascii name)`
 *
 * Designates a particular directive is created. This includes the setting up of bindings for
 * the directive.
 */
final Directive_create = traceCreateScope('Directive#create(ascii name)');
