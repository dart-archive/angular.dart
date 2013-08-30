import "../test/_specs.dart";
import "_perf.dart";
import '../test/parser/parser_spec.dart' as parser_spec;

class ATest {
  var b = new BTest();
}

class BTest {
  var c = 6;
}

class EqualsThrows {
  var b = 3;
  operator ==(x) {
    try {
      throw "no";
    } catch (e) {
      return false;
    }
  }
}

main() => describe('parser', () {
  var scope;
  var dABC, sABC;
  var dET, staticEqualsThrows;
  var dynamicNull, staticNull;
  var dynamicDoesNotExist, staticDoesNotExist;

  beforeEach(module((Module module) {
    module.type(StaticParser);
    module.value(StaticParserFunctions, parser_spec.functions());
  }));

  beforeEach(inject((Scope _scope, DynamicParser _dynamic, StaticParser _parser){
    scope = _scope;
    scope['a'] = new ATest();
    scope['e1'] = new EqualsThrows();

    dABC = _dynamic.call('a.b.c');
    sABC = _parser.call('a.b.c');

    dET = _dynamic.call('e1.b');
    staticEqualsThrows = _parser.call('e1.b');

    dynamicNull = _dynamic.call(null);
    staticNull = _parser.call(null);

    dynamicDoesNotExist = _dynamic.call('doesNotExist');
    staticDoesNotExist = _parser.call('doesNotExist');
  }));

  time('dynamic a.b.c', () {
    dABC.eval(scope);
  });

  time('static a.b.c', () {
    sABC.eval(scope);
  });

  time('static equal throws', () {
    staticEqualsThrows.eval(scope);
  });

  time('dynamic equal throws', () {
    dET.eval(scope);
  });

  time('static null', () {
    staticNull.eval(scope);
  });

  time('dynamic null', () {
    dynamicNull.eval(scope);
  });

/**
  * Results:
  * LOG: '"dynamic a.b.c: 511,357 ops/sec (2 us.)"'
.
LOG: '"static a.b.c: 2,670,663 ops/sec (0 us.)"'
.
LOG: '"static equal throws: 2,294,588 ops/sec (0 us.)"'
.
LOG: '"dynamic equal throws: 650,984 ops/sec (2 us.)"'
.
LOG: '"static null: 9,923,340 ops/sec (0 us.)"'
.
LOG: '"dynamic null: 9,895,741 ops/sec (0 us.)"'

LOG: '"static does not exist: 6,525,547 ops/sec (0 us.)"'
.
LOG: '"dynamic does not exist: 2,050,241 ops/sec (0 us.)"'
*/

  ttime('static does not exist', () {
    staticDoesNotExist.eval(scope);
  });

  ttime('dynamic does not exist', () {
    dynamicDoesNotExist.eval(scope);
  });
});
