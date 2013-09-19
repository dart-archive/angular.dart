part of angular.mock;

/**
 * A convenient way to assert the order in which the DOM elements are processed.
 *
 * In your test create:
 *
 *     <div log="foo">...</div>
 *
 * And then assert:
 *
 *     expect(logger).toEqual(['foo']);
 */
@NgDirective(
    selector: '[log]',
    map: const {
        'log': '@.message'
    }
)
class LogAttrDirective implements NgAttachAware {
  final Logger log;
  String message;
  LogAttrDirective(Logger this.log);
  attach() => log(message == '' ? 'LOG' : message);
}

/**
 * A convenient way to verify that a set of operations executed in a specific
 * order. Simply inject the Logger into each operation and call:
 *
 *     operation1(Logger logger) => logger('foo');
 *     operation2(Logger logger) => logger('bar');
 *
 *  Then in the test:
 *
 *     expect(logger).toEqual(['foo', 'bar']);
 */
class Logger implements List<String> {
  final List<Node> _list = [];

  /**
   * Add string token to the list.
   */
  call(String text) => _list.add(text);

  /**
   * Return a `;` separated list of recorded tokens.
   */
  String result() => _list.join('; ');
}
