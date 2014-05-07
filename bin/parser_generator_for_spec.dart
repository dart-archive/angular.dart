import 'dart:io' as io;

import 'package:di/di.dart';
import 'package:di/dynamic_injector.dart';
import 'package:angular/core/parser/parser.dart';
import 'package:angular/tools/parser_getter_setter/generator.dart';

main(arguments) {
  Module module = new Module()..bind(Parser, toImplementation: DynamicParser);
  module.bind(ParserBackend, toImplementation: DartGetterSetterGen);
  Injector injector = new DynamicInjector(modules: [module],
      allowImplicitInjection: true);

  // List generated using:
  // node node_modules/karma/bin/karma run | grep -Eo ":XNAY:.*:XNAY:" | sed -e 's/:XNAY://g' | sed -e "s/^/'/" | sed -e "s/$/',/" | sort | uniq > missing_expressions
  injector.get(ParserGetterSetter).generateParser([
      "foo == 'bar' ||\nbaz",
      "nonmap['hello']",
      "nonmap['hello']=3",
      "this['a'].b",
      "const",
      "null",
      "[1, 2].length",

      "doesNotExist",
      "doesNotExist()",
      "doesNotExist(1)",
      "doesNotExist(1, 2)",
      "a.doesNotExist()",
      "a.doesNotExist(1)",
      "a.doesNotExist(1, 2)",

      "a.b.c",
      "x.b.c",
      "e1.b",
      "o.f()",
      "1", "-1", "+1",
      "true?1",
      "!true",
      "3*4/2%5", "3+6-2",
      "2<3", "2>3", "2<=2", "2>=2",
      "2==3", "2!=3",
      "true&&true", "true&&false",
      "true||true", "true||false", "false||false",
      "'str ' + 4", "4 + ' str'", "4 + 4", "4 + 4 + ' str'",
      "'str ' + 4 + 4",
      "a", "b.c" , "x.y.z",
      'ident.id(6)', 'ident.doubleId(4,5)',
      "a.b.c.d.e.f.g.h.i.j.k.l.m.n",
      'b', 'a.x', 'a.b.c.d',
      "(1+2)*3",
      "a=12", "arr[c=1]", "x.y.z=123;",
      "a=123; b=234",
      "constN()",
      "add(1,2)",
      "getter()()",
      "obj.elementAt(0)",
      "[]",
      "[1, 2]",
      "[1][0]",
      "[[1]][0][0]",
      "[].length",
      "{}",
      "{a:'b'}",
      "{'a':'b'}",
      "{\"a\":'b'}",
      "{false:'WC', true:'CC'}[false]",
      ')',
      '[{}]',
      '0&&2',
      '1%2',
      '1 + 2.5',
      '1+undefined',
      '4()',
      '5=4',
      '6[3]',
      '{a',
      'a[1]=2',
      'a=1;b=3;a+b',
      'a.b',
      'a(b',
      '\'a\' + \'b c\'',
      'a().name',
      'a[x()]()',
      'boo',
      'getNoSuchMethod',
      '[].count(',
      'false',
      'false && run()',
      '!false || true',
      'foo()',
      '\$id',
      'items[1] = "abc"',
      'items[1].name',
      'list[3] = 2',
      'map["square"] = 6',
      'method',
      'method()',
      'notAFn()',
      'notmixed',
      'obj[0].name=1',
      'obj.field = 1',
      'obj.field.key = 4',
      'obj.integer = "hello"',
      'obj.map.mapKey = 3',
      'obj.nested.field = 1',
      'obj.overload = 7',
      'obj.setter = 2',
      'str',
      'str="bob"',
      'suffix = "!"',
      'taxRate / 100 * subTotal',
      'true',
      'true || run()',
      'undefined',
      'null < 0',
      'null * 3',
      'null + 6',
      '5 + null',
      'null - 4',
      '3 - null',
      'null + null',
      'null - null',

      ';;1;;',
      '1==1',
      '!(11 == 10)',
      '1 + -2.5',
      '[{a',
      'array[5=4]',
      '\$root',
      'subTotal * taxRate / 100',
      '!!true',

      '1!=2',
      '1+2*3/4',
      '\$parent',
      '{true',

      '0--1+1.5',
      '1<2',
      '1<=1',

      '1>2',
      '{a:\'-\'}',
      '{a:a}',
      '[{a:[]}, {b:1}]',
      '{true:"a", false:"b"}[!!true]',

      '2>=1',
      'true==2<3',
      '6[3]=2',

      'map.dot = 7',
      'map.null',
      'exists(doesNotExist())',
      'doesNotExists(exists())',
      'a[0]()',
      '{}()',
      'items[1]',
      "-0--1++2*-3/-4",
      "1/2*3",
      "0||2",
      "0||1&&2",
      'undefined+1',
      "12/6/2",
      "a=undefined",
      'add(a,b)',
      'notAProperty',
      "'Foo'|uppercase",
      "'f' + ('o'|uppercase) + 'o'",
      "1|increment:2",
      "'abcd'|substring:1:offset",
      "'abcd'|substring:1:3|uppercase",
      "3*4~/2%5",
      "7==3+4?10:20",
      "false?10:20",
      "5?10:20",
      "null?10:20",
      "true||false?10:20",
      "true&&false?10:20",
      "true?a=10:a=20",
      "b=true?a=false?11:c=12:a=13",
      '0?0:2',
      '1?0:2',
      '0?0?0:0:2',
      '1?0?0:0:2',
      '0?1?0:0:2',
      '0?0?1:0:2',
      '0?0?0:2:3',
      '1?1?0:0:2',
      '1?1?1:0:2',
      '1?1?1:2:3',
      '0?0:0?0:2',
      '1?0:0?0:2',
      '0?1:0?0:2',
      '0?0:1?0:2',
      '0?0:0?2:3',
      '1?1:0?0:2',
      '1?1:1?0:2',
      '1?1:1?2:3',
      '0&&1?0:1',
      '1||0?0:0',
      '0?0&&1:2',
      '0?1&&1:2',
      '0?0||0:1',
      '0?0||1:2',
      '1?0&&1:2',
      '1?1&&1:2',
      '1?0||0:1',
      '1?0||1:2',
      '0?1:0&&1',
      '0?2:1&&1',
      '0?1:0||0',
      '0?2:0||1',
      '1?1:0&&1',
      '1?2:1&&1',
      '1?1:0||0',
      '1?2:0||1',
      'returnTrue() ? returnString() : returnInt()',
      'returnFalse() ? returnString() : returnInt()',
      'identity(returnFalse() ? returnString() : returnInt())',
      "taxRate ~/ 100 * subTotal",
      "'fOo'|uppercase|lowercase",
      "n = (name|lowercase)",
      "n",
      "1|nonexistent",
      "publicField",
      "_privateField",
      "'World'|hello",
      "1;'World'|hello",
      "'World'|hello;1",

      "assert",
      "break",
      "case",
      "catch",
      "class",
      "const",
      "continue",
      "default",
      "do",
      "else",
      "enum",
      "extends",
      "final",
      "finally",
      "for",
      "if",
      "in",
      "is",
      "new",
      "rethrow",
      "return",
      "super",
      "switch",
      "this",
      "throw",
      "try",
      "var",
      "void",
      "while",
      "with",

      "assert = 42",
      "break = 42",
      "case = 42",
      "catch = 42",
      "class = 42",
      "const = 42",
      "continue = 42",
      "default = 42",
      "do = 42",
      "else = 42",
      "enum = 42",
      "extends = 42",
      "false = 42",
      "final = 42",
      "finally = 42",
      "for = 42",
      "if = 42",
      "in = 42",
      "is = 42",
      "new = 42",
      "null = 42",
      "rethrow = 42",
      "return = 42",
      "super = 42",
      "switch = 42",
      "this = 42",
      "throw = 42",
      "true = 42",
      "try = 42",
      "var = 42",
      "void = 42",
      "while = 42",
      "with = 42",

      "assert()",
      "break()",
      "case()",
      "catch()",
      "class()",
      "const()",
      "continue()",
      "default()",
      "do()",
      "else()",
      "enum()",
      "extends()",
      "final()",
      "finally()",
      "for()",
      "if()",
      "in()",
      "is()",
      "new()",
      "rethrow()",
      "return()",
      "super()",
      "switch()",
      "this()",
      "throw()",
      "try()",
      "var()",
      "void()",
      "while()",
      "with()",

      "o.assert",
      "o.break",
      "o.case",
      "o.catch",
      "o.class",
      "o.const",
      "o.continue",
      "o.default",
      "o.do",
      "o.else",
      "o.enum",
      "o.extends",
      "o.false",
      "o.final",
      "o.finally",
      "o.for",
      "o.if",
      "o.in",
      "o.is",
      "o.new",
      "o.null",
      "o.rethrow",
      "o.return",
      "o.super",
      "o.switch",
      "o.this",
      "o.throw",
      "o.true",
      "o.try",
      "o.var",
      "o.void",
      "o.while",
      "o.with",

      "o.assert = 42",
      "o.break = 42",
      "o.case = 42",
      "o.catch = 42",
      "o.class = 42",
      "o.const = 42",
      "o.continue = 42",
      "o.default = 42",
      "o.do = 42",
      "o.else = 42",
      "o.enum = 42",
      "o.extends = 42",
      "o.false = 42",
      "o.final = 42",
      "o.finally = 42",
      "o.for = 42",
      "o.if = 42",
      "o.in = 42",
      "o.is = 42",
      "o.new = 42",
      "o.null = 42",
      "o.rethrow = 42",
      "o.return = 42",
      "o.super = 42",
      "o.switch = 42",
      "o.this = 42",
      "o.throw = 42",
      "o.true = 42",
      "o.try = 42",
      "o.var = 42",
      "o.void = 42",
      "o.while = 42",
      "o.with = 42",

      "o.assert()",
      "o.break()",
      "o.case()",
      "o.catch()",
      "o.class()",
      "o.const()",
      "o.continue()",
      "o.default()",
      "o.do()",
      "o.else()",
      "o.enum()",
      "o.extends()",
      "o.false()",
      "o.final()",
      "o.finally()",
      "o.for()",
      "o.if()",
      "o.in()",
      "o.is()",
      "o.new()",
      "o.null()",
      "o.rethrow()",
      "o.return()",
      "o.super()",
      "o.switch()",
      "o.this()",
      "o.throw()",
      "o.true()",
      "o.try()",
      "o.var()",
      "o.void()",
      "o.while()",
      "o.with()",

      '"Foo"|(',
      '"Foo"|1234',
      '"Foo"|"uppercase"',
      'x.(',
      'x. 1234',
      'x."foo"',
      '{(:0}',
      '{1234:0}',

      "sub1(1)",
      "sub1(3, b: 2)",
      "sub2()",
      "sub2(a: 3)",
      "sub2(a: 3, b: 2)",
      "sub2(b: 4)",

      "o.sub1(1)",
      "o.sub1(3, b: 2)",
      "o.sub2()",
      "o.sub2(a: 3)",
      "o.sub2(a: 3, b: 2)",
      "o.sub2(b: 4)",

      "(sub1)(1)",
      "(sub1)(3, b: 2)",
      "(sub2)()",
      "(sub2)(a: 3)",
      "(sub2)(a: 3, b: 2)",
      "(sub2)(b: 4)",

      'foo(a: 0, a: 1)',
      'foo(a: 0, b: 1, a: 2)',
      'foo(0, a: 1, a: 2)',
      'foo(0, a: 1, b: 2, a: 3)',

      'foo(if: 0)',
      'foo(a: 0, class: 0)',

      'foo(a: 0)',
      'foo(a: 0, b: 1)',
      'foo(b: 1, a: 0)',
      'foo(0)',
      'foo(0, a: 0)',
      'foo(0, a: 0, b: 1)',
      'foo(0, b: 1, a: 0)',

      'o.foo(a: 0)',
      'o.foo(a: 0, b: 1)',
      'o.foo(b: 1, a: 0)',
      'o.foo(0)',
      'o.foo(0, a: 0)',
      'o.foo(0, a: 0, b: 1)',
      'o.foo(0, b: 1, a: 0)',

      '(foo)(a: 0)',
      '(foo)(a: 0, b: 1)',
      '(foo)(b: 1, a: 0)',
      '(foo)(0)',
      '(foo)(0, a: 0)',
      '(foo)(0, a: 0, b: 1)',
      '(foo)(0, b: 1, a: 0)',
  ], io.stdout);
}
