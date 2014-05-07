library filter_spec;

import '../_specs.dart';

// Const keys to keep the compiler fast
var _nameToSymbol = const {
  'name': const Symbol('name'),
  'current': const Symbol('current'),
  'first': const Symbol('first'),
  'last': const Symbol('last'),
  'done': const Symbol('done'),
  'key': const Symbol('key'),
  'nonkey': const Symbol('nonkey')
};

// Helper to simulate some real objects.  Purposefully doesn't implement Map.
class DynamicObject {
  final Map<Symbol, dynamic> _map = {};
  DynamicObject([Map init]) {
    init.forEach((key, value) {
      var symbol = _nameToSymbol[key];
      if (symbol == null) { throw "Missing nameToSymbol[$key]"; }
      _map[symbol] = value;
    });
  }
  toString() => "$_map";
  operator ==(DynamicObject other) {
    return (_map.length == other._map.length &&
            _map.keys.toSet().difference(other._map.keys.toSet()).length == 0 &&
            _map.keys.every((key) => _map[key] == other._map[key]));
  }
  int get hashCode => 0;
  noSuchMethod(Invocation invocation) {
    Symbol name = invocation.memberName;
    if (invocation.isGetter) {
      return _map[name];
    } else if (invocation.isSetter) {
      return _map[name] = invocation.positionalArguments[0];
    } else if (invocation.isMethod) {
      return Function.apply(_map[name],
          invocation.positionalArguments, invocation.namedArguments);
    } else {
      throw "DynamicObject: Unexpected invocation.";
    }
  }
}

main() {
  D([Map init]) => new DynamicObject(init);

  describe('filter formatter', () {
    var filter;

    beforeEach((Injector injector, FormatterMap filterMap) {
      filter = injector.get(filterMap[new Formatter(name: 'filter')]);
    });

    it('should formatter by string', () {
      List items = ['MIsKO',
                    {'name': 'shyam'},
                    ['adam'],
                    [],
                    1234,
                    D({'name': 'shyam'})];
      expect(filter.call(items, null).length).toBe(6);
      expect(filter.call(items, '').length).toBe(4);

      expect(filter.call(items, 'iSk').length).toBe(1);
      expect(filter.call(items, 'isk')[0]).toBe('MIsKO');

      expect(filter.call(items, 'yam').length).toBe(1);
      expect(filter.call(items, 'yam')[0]).toEqual(items[1]);

      expect(filter.call(items, 'da').length).toBe(1);
      expect(filter.call(items, 'da')[0]).toEqual(items[2]);

      expect(filter.call(items, 34).length).toBe(0);
      expect(filter.call(items, 1234)).toEqual([1234]);

      expect(filter.call(items, '34').length).toBe(1);
      expect(filter.call(items, '34')[0]).toBe(1234);

      expect(filter.call(items, "I don't exist").length).toBe(0);
    });

    it('should formatter bool items', () {
      List items = ['truefalse', true, false, null];
      // true
      expect(filter.call(items, true)).toEqual([true]);
      expect(filter.call(items, 'true')).toEqual(['truefalse', true]);
      expect(filter.call(items, 'TrUe')).toEqual(['truefalse', true]);
      expect(filter.call(items, 'yes')).toEqual([true]);
      expect(filter.call(items, 'on')).toEqual([true]);
      // false
      expect(filter.call(items, false)).toEqual([false]);
      expect(filter.call(items, 'FaLSe')).toEqual(['truefalse', false]);
      expect(filter.call(items, 'no')).toEqual([false]);
      expect(filter.call(items, 'off')).toEqual([false]);
    });

    it(r'should not read $ properties', () {
      List items = [{r'$name': 'misko'}];
      expect(filter(items, 'misko').length).toBe(0);
    });

    it('should formatter on specific property', () {
      List items = [{'name': 'a',   'ignore': 'a'},
                    {'name': 'abc', 'ignore': 'a'},
                  D({'name': 'abd'})];
      expect(filter(items, {}).length).toBe(3);

      expect(filter(items, {'name': 'a'}).length).toBe(3);

      expect(filter(items, {'name': 'ab'}).length).toBe(2);
      expect(filter(items, {'name': 'ab'})[0]['name']).toBe('abc');
      expect(filter(items, {'name': 'ab'})[1].name).toBe('abd');

      expect(filter(items, {'name': 'c'}).length).toBe(1);
      expect(filter(items, {'name': 'c'})[0]['name']).toBe('abc');
    });

    it('should take function as predicate', () {
      List items = [{'name': 'a'},
                    {'name': 'abc', 'done': true},
                  D({'name': 'abc', 'done': true})];
      fn(i) => (i is Map) ? i['done']: i.done;
      expect(filter(items, fn).length).toBe(2);
    });

    it('should take object as predicate', () {
      List items = [{'first': 'misko', 'last': 'hevery'},
                  D({'first': 'adam',  'last': 'abrons'})];

      expect(filter(items, {'first':'',      'last':''}).length).toBe(2);
      expect(filter(items, {'first':'',      'last':'hevery'}).length).toBe(1);
      expect(filter(items, {'first':'adam',  'last':'hevery'}).length).toBe(0);
      expect(filter(items, {'first':'misko', 'last':'hevery'}).length).toBe(1);
      expect(filter(items, {'first':'misko', 'last':'hevery'})[0]).toEqual(items[0]);
    });

    it('should support boolean properties', () {
      List items = [{'name': 'tom',  'current': true},
                  D({'name': 'demi', 'current': false}),
                    {'name': 'sofia'}];

      expect(filter(items, {'current':true}).length).toBe(1);
      expect(filter(items, {'current':true})[0]['name']).toBe('tom');
      expect(filter(items, {'current':false}).length).toBe(1);
      expect(filter(items, {'current':false})[0].name).toBe('demi');
    });

    it('should support negation operator', () {
      List items = ['misko', 'adam'];

      expect(filter(items, '!isk').length).toBe(1);
      expect(filter(items, '!isk')[0]).toEqual(items[1]);
    });

    describe('should support comparator', () {

      it('as equality when true', () {
        List items = ['misko', 'adam', 'adamson'];
        var expr = 'adam';

        expect(filter(items, expr, true)).toEqual([items[1]]);
        expect(filter(items, expr, false)).toEqual([items[1], items[2]]);

        items = [{'key': 'value1',  'nonkey': 1},
                 {'key': 'value2',  'nonkey': 2},
                 {'key': 'value12', 'nonkey': 3},
               D({'key': 'value1',  'nonkey': 4}),
               D({'key': 'Value1',  'nonkey': 5})];
        expr = {'key': 'value1'};
        expect(filter(items, expr, true)).toEqual([items[0], items[3]]);

        items = [{'key':  1, 'nonkey': 1},
                 {'key':  2, 'nonkey': 2},
                 {'key': 12, 'nonkey': 3},
                 {'key':  1, 'nonkey': 4}];
        expr = {'key': 1};
        expect(filter(items, expr, true)).toEqual([items[0], items[3]]);

        expr = 12;
        expect(filter(items, expr, true)).toEqual([items[2]]);
      });

      it('and use the function given to compare values', () {
        List items = [{'key':  1,  'nonkey':  1},
                      {'key':  2,  'nonkey':  2},
                    D({'key': 12, 'nonkey':  3}),
                      {'key':  1,  'nonkey': 14},
                      {'key': 13, 'nonkey': 14}];
        var expr = {'key': 10};
        var comparator = (obj, value) => obj is num && obj > value;
        expect(filter(items, expr, comparator)).toEqual([items[2], items[4]]);

        expr = 10;
        // DynamicObject doesn't match!
        expect(filter(items, expr, comparator)).toEqual([items[3], items[4]]);
      });

    });
  });
}
