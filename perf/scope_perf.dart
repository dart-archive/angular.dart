import "../test/_specs.dart";
import "_perf.dart";
import "dart:async";

main() {
  describe('scope', () {
    var scope;
    var scope2, scope3, scope4, scope5;
    var fill = (scope) {
      for(var i = 0; i < 10000; i++) {
        scope['key_$i'] = i;
      }
      return scope;
    };

    beforeEach(inject((Scope _scope){
      scope = fill(_scope);
      scope2 = fill(scope.$new());
      scope3 = fill(scope2.$new());
      scope4 = fill(scope3.$new());
      scope5 = fill(scope4.$new());
    }));

    time('noop', () {});

    time('empty scope \$digest()', () {
      scope.$digest();
    });

    describe('primitives', () {
      beforeEach(() {
        scope.a = new A();

        for(var i = 0; i < 1000; i++ ) {
          scope.$watch('a.number', () => null);
          scope.$watch('a.str', () => null);
          scope.$watch('a.obj', () => null);
        }
      });

      time('3000 watchers on scope', () => scope.$digest());

      time('scope[] 1 deep', () => scope['nenexistant']);
      time('scope[] 2 deep', () => scope2['nenexistant']);
      time('scope[] 3 deep', () => scope3['nenexistant']);
      time('scope[] 4 deep', () => scope4['nenexistant']);
      time('scope[] 5 deep', () => scope5['nenexistant']);

    });
  });

  describe('callback', () {
    var handleDirect = (a, b, c) => a + b + c;
    var handleDirectNamed = ({a, b, c}) => a + b + c;
    var handleIndirect = (e) => e.a + e.b + e.c;
    var streamC = new StreamController(sync:true);
    var stream = streamC.stream..listen(handleIndirect);

    time('direct', () => handleDirect(1, 2, 3) );
    time('directNamed', () => handleDirectNamed(a:1, b:2, c:3) );
    time('indirect', () => handleIndirect(new Container(1, 2, 3)) );
    time('stream', () => streamC.add(new Container(1, 2, 3)));
  });

}

class A {
 val number = 1;
 var str = 'abc';
 var obj = {};
}

class Container {
  var a;
  var b;
  var c;

  Container(this.a, this.b, this.c);
}
