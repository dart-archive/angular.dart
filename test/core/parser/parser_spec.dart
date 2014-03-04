library parser_spec;

import '../../_specs.dart';
import 'package:angular/utils.dart' show RESERVED_WORDS;

// Used to test getter / setter logic.
class TestData {
  String _str = "testString";
  get str => _str;
  set str(x) => _str = x;

  method() => "testMethod";
}

class Ident {
  id(x) => x;
  doubleId(x,y) => [x,y];
}

class Mixin {}
class MixedTestData extends TestData with Mixin {
}

@proxy
class MapData implements Map {
  operator[](x) => "mapped-$x";
  containsKey(x) => true;
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
@proxy
class MixedMapData extends MapData with Mixin {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
@proxy
class InheritedMapData extends MapData {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class WithPrivateField {
  int publicField = 4;
  int _privateField = 5;
}

toBool(x) => (x is num) ? x != 0 : x == true;

main() {
  describe('parse', () {
    Map<String, dynamic> context;
    Parser<Expression> parser;
    FilterMap filters;
    beforeEach(module((Module module) {
      module.type(IncrementFilter);
      module.type(SubstringFilter);
    }));
    beforeEach(inject((Parser injectedParser, FilterMap injectedFilters) {
      parser = injectedParser;
      filters = injectedFilters;
    }));

    eval(String text, [FilterMap f])
        => parser(text).eval(context, f == null ? filters : f);
    expectEval(String expr) => expect(() => eval(expr));

    beforeEach((){ context = {}; });

    describe('expressions', () {
      it('should parse numerical expressions', () {
        expect(eval("1")).toEqual(1);
      });


      it('should parse unary - expressions', () {
        expect(eval("-1")).toEqual(-1);
        expect(eval("+1")).toEqual(1);
      });


      it('should parse unary ! expressions', () {
        expect(eval("!true")).toEqual(!true);
      });


      it('should parse multiplicative expressions', () {
        expect(eval("3*4/2%5")).toEqual(3*4/2%5);
        expect(eval("3*4~/2%5")).toEqual(3*4~/2%5);
      });


      it('should parse additive expressions', () {
        expect(eval("3+6-2")).toEqual(3+6-2);
      });


      it('should parse relational expressions', () {
        expect(eval("2<3")).toEqual(2<3);
        expect(eval("2>3")).toEqual(2>3);
        expect(eval("2<=2")).toEqual(2<=2);
        expect(eval("2>=2")).toEqual(2>=2);
      });


      it('should parse equality expressions', () {
        expect(eval("2==3")).toEqual(2==3);
        expect(eval("2!=3")).toEqual(2!=3);
      });


      it('should parse logicalAND expressions', () {
        expect(eval("true&&true")).toEqual(true&&true);
        expect(eval("true&&false")).toEqual(true&&false);
      });


      it('should parse logicalOR expressions', () {
        expect(eval("true||true")).toEqual(true||true);
        expect(eval("true||false")).toEqual(true||false);
        expect(eval("false||false")).toEqual(false||false);
      });


      it('should parse ternary/conditional expressions', () {
        var a, b, c;
        expect(eval("7==3+4?10:20")).toEqual(true?10:20);
        expect(eval("false?10:20")).toEqual(false?10:20);
        expect(eval("5?10:20")).toEqual(toBool(5)?10:20);
        expect(eval("null?10:20")).toEqual(toBool(null)?10:20);
        expect(eval("true||false?10:20")).toEqual(true||false?10:20);
        expect(eval("true&&false?10:20")).toEqual(true&&false?10:20);
        expect(eval("true?a=10:a=20")).toEqual(true?a=10:a=20);
        expect([context['a'], a]).toEqual([10, 10]);
        context['a'] = a = null;
        expect(eval("b=true?a=false?11:c=12:a=13")).toEqual(
                     b=true?a=false?11:c=12:a=13);
        expect([context['a'], context['b'], context['c']]).toEqual([a, b, c]);
        expect([a, b, c]).toEqual([12, 12, 12]);
      });


      it('should auto convert ints to strings', () {
        expect(eval("'str ' + 4")).toEqual("str 4");
        expect(eval("4 + ' str'")).toEqual("4 str");
        expect(eval("4 + 4")).toEqual(8);
        expect(eval("4 + 4 + ' str'")).toEqual("8 str");
        expect(eval("'str ' + 4 + 4")).toEqual("str 44");
      });

      it('should allow keyed access on non-maps', () {
        context['nonmap'] = new BracketButNotMap();
        expect(eval("nonmap['hello']")).toEqual('hello');
        expect(eval("nonmap['hello']=3")).toEqual(3);
      });
    });

    describe('error handling', () {
      Parser<Expression> parser;

      beforeEach(inject((Parser p) {
        parser = p;
      }));

      // We only care about the error strings in the DynamicParser.
      var errStr = (x) {
        if (parser is DynamicParser) { return x; }
        return null;
      };

      // PARSER ERRORS
      it('should throw a reasonable error for unconsumed tokens', () {
        expectEval(")").toThrow('Parser Error: Unconsumed token ) at column 1 in [)]');
      });


      it('should throw on missing expected token', () {
        expectEval("a(b").toThrow('Parser Error: Missing expected ) the end of the expression [a(b]');
      });


      it('should throw on bad assignment', () {
        expectEval("5=4").toThrow('Parser Error: Expression 5 is not assignable at column 2 in [5=4]');
        expectEval("array[5=4]").toThrow('Parser Error: Expression 5 is not assignable at column 8 in [array[5=4]]');
      });


      it('should throw on incorrect ternary operator syntax', () {
        expectEval("true?1").toThrow('Parser Error: Conditional expression true?1 requires all 3 expressions');
      });


      it('should throw on non-function function calls', () {
        expectEval("4()").toThrow('4 is not a function');
      });


      it('should fail gracefully when invoking non-function', () {
        expect(() {
          parser('a[0]()').eval({'a': [4]});
        }).toThrow('a[0] is not a function');

        expect(() {
          parser('a[x()]()').eval({'a': [4], 'x': () => 0});
        }).toThrow('a[x()] is not a function');

        expect(() {
          parser('{}()').eval({});
        }).toThrow('{} is not a function');
      });


      it('should throw on undefined functions (relaxed message)', () {
        expectEval("notAFn()").toThrow('notAFn');
      });


      it('should fail gracefully when missing a function (relaxed message)', () {
        expect(() {
          parser('doesNotExist()').eval({});
        }).toThrow('doesNotExist');

        expect(() {
          parser('exists(doesNotExist())').eval({'exists': () => true});
        }).toThrow('doesNotExist');

        expect(() {
          parser('doesNotExists(exists())').eval({'exists': () => true});
        }).toThrow('doesNotExist');

        expect(() {
          parser('doesNotExist(1)').eval({});
        }).toThrow('doesNotExist');

        expect(() {
          parser('doesNotExist(1, 2)').eval({});
        }).toThrow('doesNotExist');

        expect(() {
          parser('doesNotExist()').eval(new TestData());
        }).toThrow('doesNotExist');

        expect(() {
          parser('doesNotExist(1)').eval(new TestData());
        }).toThrow('doesNotExist');

        expect(() {
          parser('doesNotExist(1, 2)').eval(new TestData());
        }).toThrow('doesNotExist');

        expect(() {
          parser('a.doesNotExist()').eval({'a': {}});
        }).toThrow('doesNotExist');

        expect(() {
          parser('a.doesNotExist(1)').eval({'a': {}});
        }).toThrow('doesNotExist');

        expect(() {
          parser('a.doesNotExist(1, 2)').eval({'a': {}});
        }).toThrow('doesNotExist');

        expect(() {
          parser('a.doesNotExist()').eval({'a': new TestData()});
        }).toThrow('doesNotExist');

        expect(() {
          parser('a.doesNotExist(1)').eval({'a': new TestData()});
        }).toThrow('doesNotExist');

        expect(() {
          parser('a.doesNotExist(1, 2)').eval({'a': new TestData()});
        }).toThrow('doesNotExist');
      });


      it('should let null be null', () {
        context['map'] = {};

        expect(eval('null')).toBe(null);
        expect(eval('map.null')).toBe(null);
      });


      it('should behave gracefully with a null scope', () {
        expect(parser('null').eval(null)).toBe(null);
      });


      it('should pass exceptions through getters', () {
        expect(() {
          parser('boo').eval(new ScopeWithErrors());
        }).toThrow('boo to you');
      });


      it('should pass noSuchMethExceptions through getters', () {
        expect(() {
          parser('getNoSuchMethod').eval(new ScopeWithErrors());
        }).toThrow("iDontExist");
      });


      it('should pass exceptions through methods', () {
        expect(() {
          parser('foo()').eval(new ScopeWithErrors());
        }).toThrow('foo to you');
      });


      it('should fail if reflected object has no property', () {
        expect(() {
          parser('notAProperty').eval(new TestData());
        }).toThrow("notAProperty");
      });

      it('should fail on private field access', () {
        expect(parser('publicField').eval(new WithPrivateField())).toEqual(4);
        // On Dartium, this fails with "NoSuchMethod: no instance getter"
        // On dart2js with generated functions: NoSuchMethod: method not found
        // On dart2js with reflection:  ArgumentError: private identifier"
        expect(() {
          parser('_privateField').eval(new WithPrivateField());
        }).toThrow();
      });
    });

    describe('setters', () {
      it('should set a field in a map', () {
        context['map'] = {};
        eval('map["square"] = 6');
        eval('map.dot = 7');

        expect(context['map']['square']).toEqual(6);
        expect(context['map']['dot']).toEqual(7);
      });


      it('should set a field in a list', () {
        context['list'] = [];
        eval('list[3] = 2');

        expect(context['list'].length).toEqual(4);
        expect(context['list'][3]).toEqual(2);
      });


      it('should set a field on an object', () {
        context['obj'] = new SetterObject();
        eval('obj.field = 1');

        expect(context['obj'].field).toEqual(1);
      });


      it('should set a setter on an object', () {
        context['obj'] = new SetterObject();
        eval('obj.setter = 2');

        expect(context['obj'].setterValue).toEqual(2);
      });


      it('should set a []= on an object', () {
        context['obj'] = new OverloadObject();
        eval('obj.overload = 7');

        expect(context['obj'].overloadValue).toEqual(7);
      });


      it('should set a field in a nested map on an object', () {
        context['obj'] = new SetterObject();
        eval('obj.map.mapKey = 3');

        expect(context['obj'].map['mapKey']).toEqual(3);
      });


      it('should set a field in a nested object on an object', () {
        context['obj'] = new SetterObject();
        eval('obj.nested.field = 1');

        expect(context['obj'].nested.field).toEqual(1);
      });


      it('should create a map for dotted acces', () {
        context['obj'] = new SetterObject();
        eval('obj.field.key = 4');

        expect(context['obj'].field['key']).toEqual(4);
      });


      xit('should throw a nice error for type mismatch', () {
        context['obj'] = new SetterObject();
        expect(() {
          eval('obj.integer = "hello"');
        }).toThrow("Eval Error: Caught type 'String' is not a subtype of type 'int' of 'value'. while evaling [obj.integer = \"hello\"]");
      });
    });

    describe('reserved words', () {
      it('should support reserved words in member get access', () {
        for (String reserved in RESERVED_WORDS) {
          expect(parser("o.$reserved").eval({ 'o': new Object() })).toEqual(null);
          expect(parser("o.$reserved").eval({ 'o': { reserved: reserved }})).toEqual(reserved);
        }
      });


      it('should support reserved words in member set access', () {
        for (String reserved in RESERVED_WORDS) {
          expect(parser("o.$reserved = 42").eval({ 'o': new Object() })).toEqual(42);
          var map = { reserved: 0 };
          expect(parser("o.$reserved = 42").eval({ 'o': map })).toEqual(42);
          expect(map[reserved]).toEqual(42);
        }
      });


      it('should support reserved words in member calls', () {
        for (String reserved in RESERVED_WORDS) {
          expect(() {
            parser("o.$reserved()").eval({ 'o': new Object() });
          }).toThrow('Undefined function $reserved');
          expect(parser("o.$reserved()").eval({ 'o': { reserved: () => reserved }})).toEqual(reserved);
        }
      });


      it('should support reserved words in scope get access', () {
        for (String reserved in RESERVED_WORDS) {
          if ([ "true", "false", "null"].contains(reserved)) continue;
          expect(parser("$reserved").eval(new Object())).toEqual(null);
          expect(parser("$reserved").eval({ reserved: reserved })).toEqual(reserved);
        }
      });


      it('should support reserved words in scope set access', () {
        for (String reserved in RESERVED_WORDS) {
          if ([ "true", "false", "null"].contains(reserved)) continue;
          expect(parser("$reserved = 42").eval(new Object())).toEqual(42);
          var map = { reserved: 0 };
          expect(parser("$reserved = 42").eval(map)).toEqual(42);
          expect(map[reserved]).toEqual(42);
        }
      });


      it('should support reserved words in scope calls', () {
        for (String reserved in RESERVED_WORDS) {
          if ([ "true", "false", "null"].contains(reserved)) continue;
          expect(() {
            parser("$reserved()").eval(new Object());
          }).toThrow('Undefined function $reserved');
          expect(parser("$reserved()").eval({ reserved: () => reserved })).toEqual(reserved);
        }
      });
    });

    describe('test cases imported from AngularJS', () {
      //// ==== IMPORTED ITs
      it('should parse expressions', () {
        expect(eval("-1")).toEqual(-1);
        expect(eval("1 + 2.5")).toEqual(3.5);
        expect(eval("1 + -2.5")).toEqual(-1.5);
        expect(eval("1+2*3/4")).toEqual(1+2*3/4);
        expect(eval("0--1+1.5")).toEqual(0- -1 + 1.5);
        expect(eval("-0--1++2*-3/-4")).toEqual(-0- -1+ 2*-3/-4);
        expect(eval("1/2*3")).toEqual(1/2*3);
      });


      it('should parse comparison', () {
        expect(eval("false")).toBeFalsy();
        expect(eval("!true")).toBeFalsy();
        expect(eval("1==1")).toBeTruthy();
        expect(eval("1!=2")).toBeTruthy();
        expect(eval("1<2")).toBeTruthy();
        expect(eval("1<=1")).toBeTruthy();
        expect(eval("1>2")).toEqual(1>2);
        expect(eval("2>=1")).toEqual(2>=1);
        expect(eval("true==2<3")).toEqual(true == 2<3);
      });


      it('should parse logical', () {
        expect(eval("0&&2")).toEqual((0!=0)&&(2!=0));
        expect(eval("0||2")).toEqual(0!=0||2!=0);
        expect(eval("0||1&&2")).toEqual(0!=0||1!=0&&2!=0);
      });


      it('should parse ternary', () {
        var returnTrue = context['returnTrue'] = () => true;
        var returnFalse = context['returnFalse'] = () => false;
        var returnString = context['returnString'] = () => 'asd';
        var returnInt = context['returnInt'] = () => 123;
        var identity = context['identity'] = (x) => x;
        var B = toBool;

        // Simple.
        expect(eval('0?0:2')).toEqual(B(0)?0:2);
        expect(eval('1?0:2')).toEqual(B(1)?0:2);

        // Nested on the left.
        expect(eval('0?0?0:0:2')).toEqual(B(0)?B(0)?0:0:2);
        expect(eval('1?0?0:0:2')).toEqual(B(1)?B(0)?0:0:2);
        expect(eval('0?1?0:0:2')).toEqual(B(0)?B(1)?0:0:2);
        expect(eval('0?0?1:0:2')).toEqual(B(0)?B(0)?1:0:2);
        expect(eval('0?0?0:2:3')).toEqual(B(0)?B(0)?0:2:3);
        expect(eval('1?1?0:0:2')).toEqual(B(1)?B(1)?0:0:2);
        expect(eval('1?1?1:0:2')).toEqual(B(1)?B(1)?1:0:2);
        expect(eval('1?1?1:2:3')).toEqual(B(1)?B(1)?1:2:3);
        expect(eval('1?1?1:2:3')).toEqual(B(1)?B(1)?1:2:3);

        // Nested on the right.
        expect(eval('0?0:0?0:2')).toEqual(B(0)?0:B(0)?0:2);
        expect(eval('1?0:0?0:2')).toEqual(B(1)?0:B(0)?0:2);
        expect(eval('0?1:0?0:2')).toEqual(B(0)?1:B(0)?0:2);
        expect(eval('0?0:1?0:2')).toEqual(B(0)?0:B(1)?0:2);
        expect(eval('0?0:0?2:3')).toEqual(B(0)?0:B(0)?2:3);
        expect(eval('1?1:0?0:2')).toEqual(B(1)?1:B(0)?0:2);
        expect(eval('1?1:1?0:2')).toEqual(B(1)?1:B(1)?0:2);
        expect(eval('1?1:1?2:3')).toEqual(B(1)?1:B(1)?2:3);
        expect(eval('1?1:1?2:3')).toEqual(B(1)?1:B(1)?2:3);

        // Precedence with respect to logical operators.
        expect(eval('0&&1?0:1')).toEqual(B(0)&&B(1)?0:1);
        expect(eval('1||0?0:0')).toEqual(B(1)||B(0)?0:0);

        expect(eval('0?0&&1:2')).toEqual(B(0)?B(0)&&B(1):2);
        expect(eval('0?1&&1:2')).toEqual(B(0)?B(1)&&B(1):2);
        expect(eval('0?0||0:1')).toEqual(B(0)?B(0)||B(0):1);
        expect(eval('0?0||1:2')).toEqual(B(0)?B(0)||B(1):2);

        expect(eval('1?0&&1:2')).toEqual(B(1)?B(0)&&B(1):2);
        expect(eval('1?1&&1:2')).toEqual(B(1)?B(1)&&B(1):2);
        expect(eval('1?0||0:1')).toEqual(B(1)?B(0)||B(0):1);
        expect(eval('1?0||1:2')).toEqual(B(1)?B(0)||B(1):2);

        expect(eval('0?1:0&&1')).toEqual(B(0)?1:B(0)&&B(1));
        expect(eval('0?2:1&&1')).toEqual(B(0)?2:B(1)&&B(1));
        expect(eval('0?1:0||0')).toEqual(B(0)?1:B(0)||B(0));
        expect(eval('0?2:0||1')).toEqual(B(0)?2:B(0)||B(1));

        expect(eval('1?1:0&&1')).toEqual(B(1)?1:B(0)&&B(1));
        expect(eval('1?2:1&&1')).toEqual(B(1)?2:B(1)&&B(1));
        expect(eval('1?1:0||0')).toEqual(B(1)?1:B(0)||B(0));
        expect(eval('1?2:0||1')).toEqual(B(1)?2:B(0)||B(1));

        // Function calls.
        expect(eval('returnTrue() ? returnString() : returnInt()')).toEqual(
            returnTrue() ? returnString() : returnInt());
        expect(eval('returnFalse() ? returnString() : returnInt()')).toEqual(
            returnFalse() ? returnString() : returnInt());
        expect(eval('returnTrue() ? returnString() : returnInt()')).toEqual(
            returnTrue() ? returnString() : returnInt());
        expect(eval('identity(returnFalse() ? returnString() : returnInt())')).toEqual(
            identity(returnFalse() ? returnString() : returnInt()));
      });


      it('should parse string', () {
        expect(eval("'a' + 'b c'")).toEqual("ab c");
      });


      it('should access scope', () {
        context['a'] =  123;
        context['b'] = {'c': 456};
        expect(eval("a")).toEqual(123);
        expect(eval("b.c")).toEqual(456);
        expect(eval("x.y.z")).toEqual(null);
      });


      it('should access classes on scope', () {
        context['ident'] = new Ident();
        expect(eval('ident.id(6)')).toEqual(6);
        expect(eval('ident.doubleId(4,5)')).toEqual([4, 5]);
      });


      it('should resolve deeply nested paths (important for CSP mode)', () {
        context['a'] = {'b': {'c': {'d': {'e': {'f': {'g': {'h': {'i': {'j': {'k': {'l': {'m': {'n': 'nooo!'}}}}}}}}}}}}};
        expect(eval("a.b.c.d.e.f.g.h.i.j.k.l.m.n")).toBe('nooo!');
      });


      it('should be forgiving', () {
        context = {'a': {'b': 23}};
        expect(eval('b')).toBeNull();
        expect(eval('a.x')).toBeNull();
      });


      it('should catch NoSuchMethod', () {
        context = {'a': {'b': 23}};
        expect(() => eval('a.b.c.d')).toThrow('NoSuchMethod');
      });


      it('should evaluate grouped expressions', () {
        expect(eval("(1+2)*3")).toEqual((1+2)*3);
      });


      it('should evaluate assignments', () {
        context = {'g': 4, 'arr': [3,4]};

        expect(eval("a=12")).toEqual(12);
        expect(context["a"]).toEqual(12);

        expect(eval("arr[c=1]")).toEqual(4);
        expect(context["c"]).toEqual(1);

        expect(eval("x.y.z=123;")).toEqual(123);
        expect(context["x"]["y"]["z"]).toEqual(123);

        expect(eval("a=123; b=234")).toEqual(234);
        expect(context["a"]).toEqual(123);
        expect(context["b"]).toEqual(234);
      });

      // TODO: assignment to an arr[c]
      // TODO: failed assignment
      // TODO: null statements in multiple statements


      it('should evaluate function call without arguments', () {
        context['constN'] = () => 123;
        expect(eval("constN()")).toEqual(123);
      });

      it('should access a protected keyword on scope', () {
        context['const'] = 3;
        expect(eval('const')).toEqual(3);
      });


      it('should evaluate function call with arguments', () {
        context["add"] =  (a,b) {
          return a+b;
        };
        expect(eval("add(1,2)")).toEqual(3);
      });


      it('should evaluate function call from a return value', () {
        context["val"] = 33;
        context["getter"] = () { return () { return context["val"]; };};
        expect(eval("getter()()")).toBe(33);
      });


      it('should evaluate methods on object', () {
        context['obj'] = ['ABC'];
        var fn = parser("obj.elementAt(0)").eval;
        expect(fn(context)).toEqual('ABC');
      });


      it('should only check locals on first dereference', () {
        context['a'] = {'b': 1};
        context['this'] = context;
        var locals = {'b': 2};
        var fn = parser("this['a'].b").bind(context, ScopeLocals.wrapper);
        expect(fn(locals)).toEqual(1);
      });


      it('should evaluate multiplication and division', () {
        context["taxRate"] =  8;
        context["subTotal"] =  100;
        expect(eval("taxRate / 100 * subTotal")).toEqual(8);
        expect(eval("taxRate ~/ 100 * subTotal")).toEqual(0);
        expect(eval("subTotal * taxRate / 100")).toEqual(8);
      });


      it('should evaluate array', () {
        expect(eval("[]").length).toEqual(0);
        expect(eval("[1, 2]").length).toEqual(2);
        expect(eval("[1, 2]")[0]).toEqual(1);
        expect(eval("[1, 2]")[1]).toEqual(2);
      });


      it('should evaluate array access', () {
        expect(eval("[1][0]")).toEqual(1);
        expect(eval("[[1]][0][0]")).toEqual(1);
        expect(eval("[]")).toEqual([]);
        expect(eval("[].length")).toEqual(0);
        expect(eval("[1, 2].length")).toEqual(2);
      });


      it('should evaluate object', () {
        expect(eval("{}")).toEqual({});
        expect(eval("{a:'b'}")).toEqual({"a":"b"});
        expect(eval("{'a':'b'}")).toEqual({"a":"b"});
        expect(eval("{\"a\":'b'}")).toEqual({"a":"b"});
      });


      it('should evaluate object access', () {
        expect(eval("{false:'WC', true:'CC'}[false]")).toEqual("WC");
      });


      it('should evaluate JSON', () {
        expect(eval("[{}]")).toEqual([{}]);
        expect(eval("[{a:[]}, {b:1}]")).toEqual([{"a":[]},{"b":1}]);
      });


      it('should evaluate multiple statements', () {
        expect(eval("a=1;b=3;a+b")).toEqual(4);
        expect(eval(";;1;;")).toEqual(1);
      });


      // skipping should evaluate object methods in correct context (this)
      // skipping should evaluate methods in correct context (this) in argument


      it('should evaluate objects on scope context', () {
        context["a"] =  "abc";
        expect(eval("{a:a}")["a"]).toEqual("abc");
      });


      it('should evaluate field access on function call result', () {
        context["a"] =  () {
          return {'name':'misko'};
        };
        expect(eval("a().name")).toEqual("misko");
      });


      it('should evaluate field access after array access', () {
        context["items"] =  [{}, {'name':'misko'}];
        expect(eval('items[1].name')).toEqual("misko");
      });


      it('should evaluate array assignment', () {
        context["items"] =  [];

        expect(eval('items[1] = "abc"')).toEqual("abc");
        expect(eval('items[1]')).toEqual("abc");
        //    Dont know how to make this work....
        //    expect(eval('books[1] = "moby"')).toEqual("moby");
        //    expect(eval('books[1]')).toEqual("moby");
      });


      it('should evaluate remainder', () {
        expect(eval('1%2')).toEqual(1);
      });


      it('should evaluate sum with undefined', () {
        expect(eval('1+undefined')).toEqual(1);
        expect(eval('undefined+1')).toEqual(1);
      });


      it('should throw exception on non-closed bracket', () {
        expect(() {
          eval('[].count(');
        }).toThrow('Unexpected end of expression: [].count(');
      });


      it('should evaluate double negation', () {
        expect(eval('true')).toBeTruthy();
        expect(eval('!true')).toBeFalsy();
        expect(eval('!!true')).toBeTruthy();
        expect(eval('{true:"a", false:"b"}[!!true]')).toEqual('a');
      });


      it('should evaluate negation', () {
        expect(eval("!false || true")).toEqual(!false || true);
        expect(eval("!(11 == 10)")).toEqual(!(11 == 10));
        expect(eval("12/6/2")).toEqual(12/6/2);
      });


      it('should evaluate exclamation mark', () {
        expect(eval('suffix = "!"')).toEqual('!');
      });


      it('should evaluate minus', () {
        expect(eval("{a:'-'}")).toEqual({'a': "-"});
      });


      it('should evaluate undefined', () {
        expect(eval("undefined")).toBeNull();
        expect(eval("a=undefined")).toBeNull();
        expect(context["a"]).toBeNull();
      });


      it('should allow assignment after array dereference', () {
        context["obj"] = [{}];
        eval('obj[0].name=1');
        // can not be expressed in Dart expect(scope["obj"]["name"]).toBeNull();
        expect(context["obj"][0]["name"]).toEqual(1);
      });


      it('should short-circuit AND operator', () {
        context["run"] = () {
          throw "IT SHOULD NOT HAVE RUN";
        };
        expect(eval('false && run()')).toBe(false);
      });


      it('should short-circuit OR operator', () {
        context["run"] = () {
          throw "IT SHOULD NOT HAVE RUN";
        };
        expect(eval('true || run()')).toBe(true);
      });


      it('should support method calls on primitive types', () {
        context["empty"] = '';
        context["zero"] = 0;
        context["bool"] = false;

        // DOES NOT WORK. String.substring is not reflected. Or toString
        // expect(eval('empty.substring(0)')).toEqual('');
        // expect(eval('zero.toString()')).toEqual('0');
        // DOES NOT WORK.  bool.toString is not reflected
        // expect(eval('bool.toString()')).toEqual('false');
      });


      it('should support map getters', () {
        expect(parser('a').eval({'a': 4})).toEqual(4);
      });


      it('should support member getters', () {
        expect(parser('str').eval(new TestData())).toEqual('testString');
      });


      it('should support returning member functions', () {
        expect(parser('method').eval(new TestData())()).toEqual('testMethod');
      });


      it('should support calling member functions', () {
        expect(parser('method()').eval(new TestData())).toEqual('testMethod');
      });


      it('should support array setters', () {
        var data = {'a': [1,3]};
        expect(parser('a[1]=2').eval(data)).toEqual(2);
        expect(data['a'][1]).toEqual(2);
      });


      it('should support member field setters', () {
        TestData data = new TestData();
        expect(parser('str="bob"').eval(data)).toEqual('bob');
        expect(data.str).toEqual("bob");
      });


      it('should support member field getters from mixins', () {
        MixedTestData data = new MixedTestData();
        data.str = 'dole';
        expect(parser('str').eval(data)).toEqual('dole');
      });


      it('should support map getters from superclass', () {
       InheritedMapData mapData = new InheritedMapData();
       expect(parser('notmixed').eval(mapData)).toEqual('mapped-notmixed');
      });


      it('should support map getters from mixins', () {
        MixedMapData data = new MixedMapData();
        expect(parser('str').eval(data)).toEqual('mapped-str');
      });


      it('should parse functions for object indices', () {
        expect(parser('a[x()]()').eval({'a': [()=>6], 'x': () => 0})).toEqual(6);
      });
    });

    describe('assignable', () {
      it('should expose assignment function', () {
        var fn = parser('a');
        expect(fn.assign).toBeNotNull();
        var scope = {};
        fn.assign(scope, 123);
        expect(scope).toEqual({'a':123});
      });
    });

    describe('locals', () {
      it('should expose local variables', () {
        expect(parser('a').bind({'a': 6}, ScopeLocals.wrapper)({'a': 1})).toEqual(1);
        expect(parser('add(a,b)').
          bind({'b': 1, 'add': (a, b) { return a + b; }}, ScopeLocals.wrapper)({'a': 2})).toEqual(3);
      });


      it('should expose traverse locals', () {
        expect(parser('a.b').bind({'a': {'b': 6}}, ScopeLocals.wrapper)({'a': {'b':1}})).toEqual(1);
        expect(parser('a.b').bind({'a': null}, ScopeLocals.wrapper)({'a': {'b':1}})).toEqual(1);
        expect(parser('a.b').bind({'a': {'b': 5}}, ScopeLocals.wrapper)({'a': null})).toEqual(null);
      });


      it('should work with scopes', inject((Scope scope) {
        scope.context['a'] = {'b': 6};
        expect(parser('a.b').bind(scope.context, ScopeLocals.wrapper)({'a': {'b':1}})).toEqual(1);
      }));

      it('should expose assignment function', () {
        var fn = parser('a.b');
        expect(fn.assign).toBeNotNull();
        var scope = {};
        var locals = {"a": {}};
        fn.bind(scope, ScopeLocals.wrapper).assign(123, locals);
        expect(scope).toEqual({});
        expect(locals["a"]).toEqual({'b':123});
      });
    });


    describe('filters', () {
      it('should call a filter', () {
        expect(eval("'Foo'|uppercase", filters)).toEqual("FOO");
        expect(eval("'fOo'|uppercase|lowercase", filters)).toEqual("foo");
      });

      it('should call a filter with arguments', () {
        expect(eval("1|increment:2", filters)).toEqual(3);
      });

      it('should parse filters', () {
        expect(() {
          eval("1|nonexistent");
        }).toThrow('No NgFilter: nonexistent found!');
        expect(() {
          eval("1|nonexistent", filters);
        }).toThrow('No NgFilter: nonexistent found!');

        context['offset'] =  3;
        expect(eval("'abcd'|substring:1:offset")).toEqual("bc");
        expect(eval("'abcd'|substring:1:3|uppercase")).toEqual("BC");
      });

      it('should only use filters that are passed as an argument', inject((Injector injector) {
        var expression = parser("'World'|hello");
        expect(() {
          expression.eval({}, filters);
        }).toThrow('No NgFilter: hello found!');

        var module = new Module()
            ..type(HelloFilter);
        var childInjector = injector.createChild([module],
            forceNewInstances: [FilterMap]);
        var newFilters = childInjector.get(FilterMap);

        expect(expression.eval({}, newFilters)).toEqual('Hello, World!');
      }));

      it('should not allow filters in a chain', () {
        expect(() {
          parser("1;'World'|hello");
        }).toThrow('cannot have a filter in a chain the end of the expression [1;\'World\'|hello]');
        expect(() {
          parser("'World'|hello;1");
        }).toThrow('cannot have a filter in a chain at column 15 in [\'World\'|hello;1]');
      });
    });
  });
}

class SetterObject {
  var field;
  int integer;
  var map = {};

  var nest;
  SetterObject get nested => nest != null ? nest : (nest = new SetterObject());

  var setterValue;
  void set setter(x) { setterValue = x; }
}

@proxy
class OverloadObject implements Map {
  var overloadValue;
  operator []=(String name, var value) {
    overloadValue = value;
  }
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class BracketButNotMap {
  operator[](String name) => name;
  operator[]=(String name, value) {}
}

class ScopeWithErrors {
  String get boo { throw "boo to you"; }
  String foo() { throw "foo to you"; }
  get getNoSuchMethod => null.iDontExist();
}

@NgFilter(name:'increment')
class IncrementFilter {
  call(a, b) => a + b;
}

@NgFilter(name:'substring')
class SubstringFilter {
  call(String str, startIndex, [endIndex]) {
    return str.substring(startIndex, endIndex);
  }
}

@NgFilter(name:'hello')
class HelloFilter {
  call(String str) {
    return 'Hello, $str!';
  }
}
