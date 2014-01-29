library scope_spec;

import '../_specs.dart';
import 'package:angular/change_detection/watch_group.dart';
import 'package:angular/change_detection/change_detection.dart';
import 'package:angular/change_detection/dirty_checking_change_detector.dart';
import 'package:angular/core/scope2.dart';

main() => describe('scope2', () {
  Scope2 scope;
  Map context;

  beforeEach(module((Module module) {
    context = {};
    module.value(GetterCache, new GetterCache({}));
    module.type(ChangeDetector, implementedBy: DirtyCheckingChangeDetector);
    module.value(Object, context);
    module.type(WatchGroup, implementedBy: RootWatchGroup);
    module.type(Scope2);
    module.type(_MultiplyFilter);
    module.type(_ListHeadFilter);
    module.type(_ListTailFilter);
    module.type(_SortFilter);
  }));
  beforeEach(inject((Scope2 s) {
    scope = s;
  }));

  describe('AST Bridge', () {
    it('should watch field', inject((Logger logger) {
      context['field'] = 'Worked!';
      scope.watch('field', (value, previous, context) => logger([value, previous, context]));
      expect(logger).toEqual([]);
      scope.digest();
      expect(logger).toEqual([['Worked!', null, context]]);
      scope.digest();
      expect(logger).toEqual([['Worked!', null, context]]);
    }));

    it('should watch field path', inject((Logger logger) {
      context['a'] = {'b': 'AB'};
      scope.watch('a.b', (value, previous, context) => logger(value));
      scope.digest();
      expect(logger).toEqual(['AB']);
      context['a']['b'] = '123';
      scope.digest();
      expect(logger).toEqual(['AB', '123']);
      context['a'] = {'b': 'XYZ'};
      scope.digest();
      expect(logger).toEqual(['AB', '123', 'XYZ']);
    }));

    it('should watch math operations', inject((Logger logger) {
      context['a'] = 1;
      context['b'] = 2;
      scope.watch('a + b + 1', (value, previous, context) => logger(value));
      scope.digest();
      expect(logger).toEqual([4]);
      context['a'] = 3;
      scope.digest();
      expect(logger).toEqual([4, 6]);
      context['b'] = 5;
      scope.digest();
      expect(logger).toEqual([4, 6, 9]);
    }));


    it('should watch literals', inject((Logger logger) {
      context['a'] = 1;
      scope.watch('1', (value, previous, context) => logger(value));
      scope.watch('"str"', (value, previous, context) => logger(value));
      scope.watch('[a, 2, 3]', (value, previous, context) => logger(value));
      scope.watch('{a:a, b:2}', (value, previous, context) => logger(value));
      scope.digest();
      expect(logger).toEqual([1, 'str', [1, 2, 3], {'a': 1, 'b': 2}]);
      logger.clear();
      context['a'] = 3;
      scope.digest();
      // Even though we changed the 'a' field none of the watches fire because
      // the underlying array/map identity does not change. We just update the
      // properties on the same array/map.
      expect(logger).toEqual([]);
    }));

    it('should invoke closures', inject((Logger logger) {
      context['fn'] = () {
        logger('fn');
        return 1;
      };
      context['a'] = {'fn': () {
        logger('a.fn');
        return 2;
      }};
      scope.watch('fn()', (value, previous, context) => logger('=> $value'));
      scope.watch('a.fn()', (value, previous, context) => logger('-> $value'));
      scope.digest();
      expect(logger).toEqual(['fn', 'a.fn', '=> 1', '-> 2']);
      logger.clear();
      scope.digest();
      expect(logger).toEqual(['fn', 'a.fn']);
    }));

    it('should perform conditionals', inject((Logger logger) {
      context['a'] = 1;
      context['b'] = 2;
      context['c'] = 3;
      scope.watch('a?b:c', (value, previous, context) => logger(value));
      scope.digest();
      expect(logger).toEqual([2]);
      logger.clear();
      context['a'] = 0;
      scope.digest();
      expect(logger).toEqual([3]);
    }));


    xit('should call function', inject((Logger logger) {
      context['a'] = () {
        return () { return 123; };
      };
      scope.watch('a()()', (value, previous, context) => logger(value));
      scope.digest();
      expect(logger).toEqual([123]);
      logger.clear();
      scope.digest();
      expect(logger).toEqual([]);
    }));

    it('should access bracket', inject((Logger logger) {
      context['a'] = {'b': 123};
      scope.watch('a["b"]', (value, previous, context) => logger(value));
      scope.digest();
      expect(logger).toEqual([123]);
      logger.clear();
      scope.digest();
      expect(logger).toEqual([]);
    }));


    it('should prefix', inject((Logger logger) {
      context['a'] = true;
      scope.watch('!a', (value, previous, context) => logger(value));
      scope.digest();
      expect(logger).toEqual([false]);
      logger.clear();
      context['a'] = false;
      scope.digest();
      expect(logger).toEqual([true]);
    }));

    it('should support filters', inject((Logger logger) {
      context['a'] = 123;
      context['b'] = 2;
      scope.watch('a | multiply:b', (value, previous, context) => logger(value));
      scope.digest();
      expect(logger).toEqual([246]);
      logger.clear();
      scope.digest();
      expect(logger).toEqual([]);
      logger.clear();
    }));

    it('should support arrays in filters', inject((Logger logger) {
      context['a'] = [1];
      scope.watch('a | sort | listHead:"A" | listTail:"B"', (value, previous, context) => logger(value));
      scope.digest();
      expect(logger).toEqual(['sort', 'listHead', 'listTail', ['A', 1, 'B']]);
      logger.clear();

      scope.digest();
      expect(logger).toEqual([]);
      logger.clear();

      context['a'].add(2);
      scope.digest();
      expect(logger).toEqual(['sort', 'listHead', 'listTail', ['A', 1, 2, 'B']]);
      logger.clear();

      // We change the order, but sort should change it to same one and it should not
      // call subsequent filters.
      context['a'] = [2, 1];
      scope.digest();
      expect(logger).toEqual(['sort']);
      logger.clear();
    }));
  });

});

@NgFilter(name: 'multiply')
class _MultiplyFilter {
  call(a, b) => a * b;
}

@NgFilter(name: 'listHead')
class _ListHeadFilter {
  Logger logger;
  _ListHeadFilter(Logger this.logger);
  call(list, head) {
    logger('listHead');
    return [head]..addAll(list);
  }
}


@NgFilter(name: 'listTail')
class _ListTailFilter {
  Logger logger;
  _ListTailFilter(Logger this.logger);
  call(list, tail) {
    logger('listTail');
    return new List.from(list)..add(tail);
  }
}

@NgFilter(name: 'sort')
class _SortFilter {
  Logger logger;
  _SortFilter(Logger this.logger);
  call(list) {
    logger('sort');
    return new List.from(list)..sort();
  }
}
