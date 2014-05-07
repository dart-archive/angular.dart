library parser_spec;

import '../../_specs.dart';
import 'package:angular/utils.dart' show RESERVED_WORDS;

// Used to test getter / setter logic.
class TestData {
  String _str = "testString";
  get str => _str;
  set str(x) => _str = x;

  method() => "testMethod";
  sub1(a, {b: 0}) => a - b;
  sub2({a: 0, b: 0}) => a - b;
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
    FormatterMap formatters;

    beforeEachModule((Module module) {
      module.bind(IncrementFormatter);
      module.bind(SubstringFormatter);
    });

    beforeEach((Parser injectedParser, FormatterMap injectedFormatters) {
      parser = injectedParser;
      formatters = injectedFormatters;
    });

    eval(String text, [FormatterMap f]) =>
        parser(text).eval(context, f == null ? formatters : f);
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

      beforeEach((Parser p) {
        parser = p;
      });

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

      it("should throw on an unexpected token", (){
        expectEval("[1,2] trac")
            .toThrow('Parser Error: \'trac\' is an unexpected token at column 7 in [[1,2] trac]');
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
        expect(() => eval('map.null'))
            .toThrow("Identifier 'null' is a reserved word.");
      });


      it('should behave gracefully with a null scope', () {
        expect(parser('null').eval(null)).toBe(null);
      });


      it('should eval binary operators with null as null', () {
        expect(eval("null < 0")).toEqual(null);
        expect(eval("null * 3")).toEqual(null);

        // But + and - are special cases.
        expect(eval("null + 6")).toEqual(6);
        expect(eval("5 + null")).toEqual(5);
        expect(eval("null - 4")).toEqual(-4);
        expect(eval("3 - null")).toEqual(3);
        expect(eval("null + null")).toEqual(0);
        expect(eval("null - null")).toEqual(0);
      });


      it('should pass exceptions through getters', () {
        expect(() {
          parser('boo').eval(new ScopeWithErrors());
        }).toThrow('boo to you');
      });


      it('should pass noSuchMethodExceptions through getters', () {
        expect(() {
          parser('getNoSuchMethod').eval(new ScopeWithErrors());
        }).toThrow("null");
        // Dartium throws: The null object does not have a method 'iDontExist'
        // Chrome throws: NullError: Cannot call "iDontExist$0" on null
        // Firefox throws: NullError: null has no properties
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


      it('should only allow identifier or keyword as formatter names', () {
        expect(() => parser('"Foo"|(')).toThrow('identifier or keyword');
        expect(() => parser('"Foo"|1234')).toThrow('identifier or keyword');
        expect(() => parser('"Foo"|"uppercase"')).toThrow('identifier or keyword');
      });


      it('should only allow identifier or keyword as member names', () {
        expect(() => parser('x.(')).toThrow('identifier or keyword');
        expect(() => parser('x. 1234')).toThrow('identifier or keyword');
        expect(() => parser('x."foo"')).toThrow('identifier or keyword');
      });


      it('should only allow identifier, string, or keyword as object literal key', () {
        expect(() => parser('{(:0}')).toThrow('expected identifier, keyword, or string');
        expect(() => parser('{1234:0}')).toThrow('expected identifier, keyword, or string');
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

    xdescribe('reserved words', () {
      iit('should support reserved words in member get access', () {
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
        expect(eval('this["const"]')).toEqual(3);
      });


      it('should evaluate scope call with arguments', () {
        context["add"] = (a,b) => a + b;
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


      it('should work with scopes', (Scope scope) {
        scope.context['a'] = {'b': 6};
        expect(parser('a.b').bind(scope.context, ScopeLocals.wrapper)({'a': {'b':1}})).toEqual(1);
      });

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


    describe('named arguments', () {
      it('should be supported for scope calls', () {
        var data = new TestData();
        expect(parser("sub1(1)").eval(data)).toEqual(1);
        expect(parser("sub1(3, b: 2)").eval(data)).toEqual(1);

        expect(parser("sub2()").eval(data)).toEqual(0);
        expect(parser("sub2(a: 3)").eval(data)).toEqual(3);
        expect(parser("sub2(a: 3, b: 2)").eval(data)).toEqual(1);
        expect(parser("sub2(b: 4)").eval(data)).toEqual(-4);
      });


      it('should be supported for scope calls (map)', () {
        context["sub1"] = (a, {b: 0}) => a - b;
        expect(eval("sub1(1)")).toEqual(1);
        expect(eval("sub1(3, b: 2)")).toEqual(1);

        context["sub2"] = ({a: 0, b: 0}) => a - b;
        expect(eval("sub2()")).toEqual(0);
        expect(eval("sub2(a: 3)")).toEqual(3);
        expect(eval("sub2(a: 3, b: 2)")).toEqual(1);
        expect(eval("sub2(b: 4)")).toEqual(-4);
      });


      it('should be supported for member calls', () {
        context['o'] = new TestData();
        expect(eval("o.sub1(1)")).toEqual(1);
        expect(eval("o.sub1(3, b: 2)")).toEqual(1);

        expect(eval("o.sub2()")).toEqual(0);
        expect(eval("o.sub2(a: 3)")).toEqual(3);
        expect(eval("o.sub2(a: 3, b: 2)")).toEqual(1);
        expect(eval("o.sub2(b: 4)")).toEqual(-4);
      });


      it('should be supported for member calls (map)', () {
        context['o'] = {
          'sub1': (a, {b: 0}) => a - b,
          'sub2': ({a: 0, b: 0}) => a - b
        };
        expect(eval("o.sub1(1)")).toEqual(1);
        expect(eval("o.sub1(3, b: 2)")).toEqual(1);

        expect(eval("o.sub2()")).toEqual(0);
        expect(eval("o.sub2(a: 3)")).toEqual(3);
        expect(eval("o.sub2(a: 3, b: 2)")).toEqual(1);
        expect(eval("o.sub2(b: 4)")).toEqual(-4);
      });


      it('should be supported for function calls', () {
        context["sub1"] = (a, {b: 0}) => a - b;
        expect(eval("(sub1)(1)")).toEqual(1);
        expect(eval("(sub1)(3, b: 2)")).toEqual(1);

        context["sub2"] = ({a: 0, b: 0}) => a - b;
        expect(eval("(sub2)()")).toEqual(0);
        expect(eval("(sub2)(a: 3)")).toEqual(3);
        expect(eval("(sub2)(a: 3, b: 2)")).toEqual(1);
        expect(eval("(sub2)(b: 4)")).toEqual(-4);
      });


      it('should be an error to use the same name twice', () {
        expect(() => parser('foo(a: 0, a: 1)')).toThrow("Duplicate argument named 'a' at column 11");
        expect(() => parser('foo(a: 0, b: 1, a: 2)')).toThrow("Duplicate argument named 'a' at column 17");
        expect(() => parser('foo(0, a: 1, a: 2)')).toThrow("Duplicate argument named 'a' at column 14");
        expect(() => parser('foo(0, a: 1, b: 2, a: 3)')).toThrow("Duplicate argument named 'a' at column 20");
      });


      it('should be an error to use Dart reserved words as names', () {
        expect(() => parser('foo(if: 0)')).toThrow("Cannot use Dart reserved word 'if' as named argument at column 5");
        expect(() => parser('foo(a: 0, class: 0)')).toThrow("Cannot use Dart reserved word 'class' as named argument at column 11");
      });


      it('should pretty print scope calls correctly', () {
        expect(parser('foo(a: 0)').toString()).toEqual('foo(a: 0)');
        expect(parser('foo(a: 0, b: 1)').toString()).toEqual('foo(a: 0, b: 1)');
        expect(parser('foo(b: 1, a: 0)').toString()).toEqual('foo(b: 1, a: 0)');

        expect(parser('foo(0)').toString()).toEqual('foo(0)');
        expect(parser('foo(0, a: 0)').toString()).toEqual('foo(0, a: 0)');
        expect(parser('foo(0, a: 0, b: 1)').toString()).toEqual('foo(0, a: 0, b: 1)');
        expect(parser('foo(0, b: 1, a: 0)').toString()).toEqual('foo(0, b: 1, a: 0)');
      });


      it('should pretty print member calls correctly', () {
        expect(parser('o.foo(a: 0)').toString()).toEqual('o.foo(a: 0)');
        expect(parser('o.foo(a: 0, b: 1)').toString()).toEqual('o.foo(a: 0, b: 1)');
        expect(parser('o.foo(b: 1, a: 0)').toString()).toEqual('o.foo(b: 1, a: 0)');

        expect(parser('o.foo(0)').toString()).toEqual('o.foo(0)');
        expect(parser('o.foo(0, a: 0)').toString()).toEqual('o.foo(0, a: 0)');
        expect(parser('o.foo(0, a: 0, b: 1)').toString()).toEqual('o.foo(0, a: 0, b: 1)');
        expect(parser('o.foo(0, b: 1, a: 0)').toString()).toEqual('o.foo(0, b: 1, a: 0)');
      });


      it('should pretty print function calls correctly', () {
        expect(parser('(foo)(a: 0)').toString()).toEqual('(foo)(a: 0)');
        expect(parser('(foo)(a: 0, b: 1)').toString()).toEqual('(foo)(a: 0, b: 1)');
        expect(parser('(foo)(b: 1, a: 0)').toString()).toEqual('(foo)(b: 1, a: 0)');

        expect(parser('(foo)(0)').toString()).toEqual('(foo)(0)');
        expect(parser('(foo)(0, a: 0)').toString()).toEqual('(foo)(0, a: 0)');
        expect(parser('(foo)(0, a: 0, b: 1)').toString()).toEqual('(foo)(0, a: 0, b: 1)');
        expect(parser('(foo)(0, b: 1, a: 0)').toString()).toEqual('(foo)(0, b: 1, a: 0)');
      });
    });


    describe('formatters', () {
      it('should call a formatter', () {
        expect(eval("'Foo'|uppercase", formatters)).toEqual("FOO");
        // Re-enable after static parser is removed
        //expect(eval("'f' + ('o'|uppercase) + 'o'", formatters)).toEqual("fOo");
        expect(eval("'fOo'|uppercase|lowercase", formatters)).toEqual("foo");
      });

      it('should call a formatter with arguments', () {
        expect(eval("1|increment:2", formatters)).toEqual(3);
      });

      it('should evaluate grouped formatters', () {
        context = {'name': 'MISKO'};
        expect(eval('n = (name|lowercase)', formatters)).toEqual('misko');
        expect(eval('n')).toEqual('misko');
      });

      it('should parse formatters', () {
        expect(() {
          eval("1|nonexistent");
        }).toThrow('No Formatter: nonexistent found!');
        expect(() {
          eval("1|nonexistent", formatters);
        }).toThrow('No Formatter: nonexistent found!');

        context['offset'] =  3;
        expect(eval("'abcd'|substring:1:offset")).toEqual("bc");
        expect(eval("'abcd'|substring:1:3|uppercase")).toEqual("BC");
      });

      it('should only use formatters that are passed as an argument', (Injector injector) {
        var expression = parser("'World'|hello");
        expect(() {
          expression.eval({}, formatters);
        }).toThrow('No Formatter: hello found!');

        var module = new Module()
            ..bind(HelloFormatter);
        var childInjector = injector.createChild([module],
            forceNewInstances: [FormatterMap]);
        var newFormatters = childInjector.get(FormatterMap);

        expect(expression.eval({}, newFormatters)).toEqual('Hello, World!');
      });

      it('should not allow formatters in a chain', () {
        expect(() {
          parser("1;'World'|hello");
        }).toThrow('Cannot have a formatter in a chain the end of the expression [1;\'World\'|hello]');
        expect(() {
          parser("'World'|hello;1");
        }).toThrow('Cannot have a formatter in a chain at column 15 in [\'World\'|hello;1]');
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

@Formatter(name:'increment')
class IncrementFormatter {
  call(a, b) => a + b;
}

@Formatter(name:'substring')
class SubstringFormatter {
  call(String str, startIndex, [endIndex]) {
    return str.substring(startIndex, endIndex);
  }
}

@Formatter(name:'hello')
class HelloFormatter {
  call(String str) {
    return 'Hello, $str!';
  }
}
