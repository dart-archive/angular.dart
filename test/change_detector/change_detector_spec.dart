library change_detector_spec;

import '../_specs.dart';
import 'package:angular/change_detector/change_detector.dart';

// TODO: remove chd prefix once old arch is removed
import 'package:angular/change_detector/change_detector.dart' as chd show
    CollectionAST,
    FunctionApply,
    PureFunctionAST,
    ClosureAST,
    MethodAST,
    ConstantAST
;


// TODO static version
// import 'package:angular/change_detection/dirty_checking_change_detector_static.dart';
import 'package:angular/change_detection/dirty_checking_change_detector_dynamic.dart';
import 'package:angular/change_detector/ast_parser.dart';
import 'dart:math';
import 'dart:collection';

// TODO  remove
import 'package:angular/change_detection/change_detection.dart' show
    FieldGetter,
    MapChangeRecord,
    CollectionChangeRecord,
    CollectionChangeItem,
    MapKeyValue;


void main() {
  ddescribe('Change detector', () {
    ChangeDetector detector;
    Parser parser;
    ASTParser parse;
    Logger log;
    var context;
    var watchGrp;

    beforeEach((Parser _parser, Logger _log, ClosureMap cm) {
      context = {};
      log = _log;
      detector = new ChangeDetector(new DynamicFieldGetterFactory());
      watchGrp = detector.createWatchGroup(context);
      parser = _parser;
      // TODO bind the new ASTParser
      parse = new ASTParser(parser, cm);

    });


    logReactionFn(v, p) => log('$p=>$v');

    // Ported from previous impl (dccd) - make it a describe ?
    describe('Field records: property, map, collections, functions - former dccd', () {
      describe('object field', () {
        it('should detect nothing', () {
          expect(watchGrp.processChanges()).toEqual(0);
        });

        it('should process field changes', () {
          context['user'] = new _User('', '');
          watchGrp.watch(parse('user.first'), logReactionFn);
          watchGrp.watch(parse('user.last'), logReactionFn);
          watchGrp.processChanges();
          log.clear();

          expect(watchGrp.processChanges()).toEqual(0);
          expect(log).toEqual([]);

          context['user']
            ..first = 'misko'
            ..last = 'hevery';
          expect(watchGrp.processChanges()).toEqual(2);
          expect(log).toEqual(['=>misko', '=>hevery']);

          log.clear();
          // Make the strings equal but not identical
          context['user'].first = 'mis';
          context['user'].first += 'ko';
          expect(watchGrp.processChanges()).toEqual(0);
          expect(log).toEqual([]);

          log.clear();
          context['user'].last = 'Hevery';
          expect(watchGrp.processChanges()).toEqual(1);
          expect(log).toEqual(['hevery=>Hevery']);
        });

        it('should ignore NaN != NaN', () {
          context['user'] = new _User()..age = double.NAN;
          watchGrp.watch(parse('user.age'), logReactionFn);
          watchGrp.processChanges();

          log.clear();
          expect(watchGrp.processChanges()).toEqual(0);
          expect(log).toEqual([]);

          context['user'].age = 123;
          expect(watchGrp.processChanges()).toEqual(1);
          expect(log).toEqual(['NaN=>123']);
        });

        it('should treat map field dereference as []', () {
          context['map'] = {'name': 'misko'};
          watchGrp.watch(parse('map.name'), logReactionFn);
          watchGrp.processChanges();

          log.clear();
          context['map']['name'] = 'Misko';
          expect(watchGrp.processChanges()).toEqual(1);
          expect(log).toEqual(['misko=>Misko']);
        });
      });

      describe('insertions / removals', () {

        it('should insert at the end of list', () {
          var watchA = watchGrp.watch(parse('a'), logReactionFn);
          var watchB = watchGrp.watch(parse('b'), logReactionFn);

          context['a'] = 'a1';
          context['b'] = 'b1';
          expect(watchGrp.processChanges()).toEqual(2);
          expect(log).toEqual(['null=>a1', 'null=>b1']);

          log.clear();
          context['a'] = 'a2';
          context['b'] = 'b2';
          watchA.remove();
          expect(watchGrp.processChanges()).toEqual(1);
          expect(log).toEqual(['b1=>b2']);

          log.clear();
          context['a'] = 'a3';
          context['b'] = 'b3';
          watchB.remove();
          expect(watchGrp.processChanges()).toEqual(0);
          expect(log).toEqual([]);
        });
      });

      it('should be possible to remove a watch from within its reaction function', () {
        context['a'] = 'a';
        context['b'] = 'b';
        var watchA;
        watchA = watchGrp.watch(parse('a'), (v, _) {
          log(v);
          watchA.remove();
        });
        watchGrp.watch(parse('b'), (v, _) => log(v));
        expect(() => watchGrp.processChanges()).not.toThrow();
        expect(log).toEqual(['a', 'b']);
      });

      it('should properly disconnect group in case watch is removed in disconected group', () {
        expect(() {
          var child1a = watchGrp.createChild(context);
          var child2 = child1a.createChild(context);
          var child2Watch = child2.watch(parse('f1'), logReactionFn);
          var child1b = watchGrp.createChild(context);
          child1a.remove();
          child2Watch.remove();
          child1b.watch(parse('f2'), logReactionFn);
        }).not.toThrow();
      });

      it('should find random bugs', () {
        List groups;
        List watches = [];
        List steps = [];
        var field = 'someField';
        var random = new Random();

        void step(text) {
          steps.add(text);
        }
        try {
          for (var i = 0; i < 100000; i++) {
            if (i % 50 == 0) {
              watches.clear();
              steps.clear();
              groups = [detector.createWatchGroup(context)];
            }
            switch (random.nextInt(4)) {
              case 0: // new child detector
                if (groups.length > 10) break;
                var index = random.nextInt(groups.length);
                var group = groups[index];
                step('group[$index].newGroup()');
                groups.add(group.createChild(context));
                break;
              case 1: // add watch
                var index = random.nextInt(groups.length);
                var group = groups[index];
                step('group[$index].watch($field)');
                watches.add(group.watch(parse('field'), (_, __) {
                }));
                break;
              case 2: // destroy watch group
                if (groups.length == 1) break;
                var index = random.nextInt(groups.length - 1) + 1;
                var group = groups[index];
                step('group[$index].remove()');
                group.remove();
                groups = groups.where((s) => s.isAttached).toList();
                break;
              case 3: // remove watch on watch group
                if (watches.length == 0) break;
                var index = random.nextInt(watches.length);
                var record = watches.removeAt(index);
                step('watches.removeAt($index).remove()');
                record.remove();
                break;
            }
          }
        } catch (e) {
          print(steps);
          rethrow;
        }
      });

      describe('list watching', () {
        it('should coalesce records added in the same cycle', () {
          context['list'] = [0];

          watchGrp.watch(parse('list', collection: true), (_, __) => null);
          expect(watchGrp.watchedCollections).toEqual(1);
          // Should not add a record when added in the same cycle
          watchGrp.watch(parse('list', collection: true), (_, __) => null);
          watchGrp.watch(parse('list', collection: true), (_, __) => null);
          expect(watchGrp.watchedCollections).toEqual(1);

          watchGrp.processChanges();
          // Should add a record when not added in the same cycle
          watchGrp.watch(parse('list', collection: true), (_, __) => null);
          expect(watchGrp.watchedCollections).toEqual(2);
          // Should not add a record when added in the same cycle
          watchGrp.watch(parse('list', collection: true), (_, __) => null);
          watchGrp.watch(parse('list', collection: true), (_, __) => null);
          expect(watchGrp.watchedCollections).toEqual(2);
        });

        describe('previous state', () {
          it('should store on addition', () {
            var value;
            context['list'] = [];
            watchGrp.watch(parse('list', collection: true), (v, _) => value = v);
            watchGrp.processChanges();

            context['list'].add('a');
            // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
            watchGrp.processChanges();
            expect(value, toEqualCollectionRecord(
                collection: ['a[null -> 0]'],
                additions: ['a[null -> 0]']));

            context['list'].add('b');
            // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
            watchGrp.processChanges();
            expect(value, toEqualCollectionRecord(
                collection: ['a', 'b[null -> 1]'],
                previous: ['a'],
                additions: ['b[null -> 1]']));
          });
        });

        it('should support switching refs - gh 1158', async(() {
          var value;
          context['list'] = [0];
          watchGrp.watch(parse('list', collection: true), (v, _) => value = v);
          watchGrp.processChanges();

          context['list'] = [1, 0];
          // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
          watchGrp.processChanges();
          expect(value, toEqualCollectionRecord(
              collection: ['1[null -> 0]', '0[0 -> 1]'],
              previous: ['0[0 -> 1]'],
              additions: ['1[null -> 0]'],
              moves: ['0[0 -> 1]']));

          context['list'] = [2, 1, 0];
          // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
          watchGrp.processChanges();
          expect(value, toEqualCollectionRecord(
              collection: ['2[null -> 0]', '1[0 -> 1]', '0[1 -> 2]'],
              previous: ['1[0 -> 1]', '0[1 -> 2]'],
              additions: ['2[null -> 0]'],
              moves: ['1[0 -> 1]', '0[1 -> 2]']));
        }));

        it('should handle swapping elements correctly', () {
          var value;
          context['list'] = [1, 2];
          watchGrp.watch(parse('list', collection: true), (v, _) => value = v);
          watchGrp.processChanges();

          context['list'].setAll(0, context['list'].reversed.toList());
          // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
          watchGrp.processChanges();
          expect(value, toEqualCollectionRecord(
              collection: ['2[1 -> 0]', '1[0 -> 1]'],
              previous: ['1[0 -> 1]', '2[1 -> 0]'],
              moves: ['2[1 -> 0]', '1[0 -> 1]']));
        });

        it('should handle swapping elements correctly - gh1097', () {
          // This test would have failed in non-checked mode only
          var value;
          context['list'] = ['a', 'b', 'c'];
          watchGrp.watch(parse('list', collection: true), (v, _) => value = v);
          watchGrp.processChanges();

          context['list']
            ..clear()
            ..addAll(['b', 'a', 'c']);
          // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
          watchGrp.processChanges();
          expect(value, toEqualCollectionRecord(
              collection: ['b[1 -> 0]', 'a[0 -> 1]', 'c'],
              previous: ['a[0 -> 1]', 'b[1 -> 0]', 'c'],
              moves: ['b[1 -> 0]', 'a[0 -> 1]']));

          context['list']
            ..clear()
            ..addAll(['b', 'c', 'a']);
          // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
          watchGrp.processChanges();
          expect(value, toEqualCollectionRecord(
              collection: ['b', 'c[2 -> 1]', 'a[1 -> 2]'],
              previous: ['b', 'a[1 -> 2]', 'c[2 -> 1]'],
              moves: ['c[2 -> 1]', 'a[1 -> 2]']));
        });
      });

      it('should detect changes in list', () {
        var value;
        context['list'] = [];
        watchGrp.watch(parse('list', collection: true), (v, _) => value = v);
        watchGrp.processChanges();

        context['list'].add('a');
        // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
        watchGrp.processChanges();
        expect(value, toEqualCollectionRecord(
            collection: ['a[null -> 0]'],
            additions: ['a[null -> 0]']));

        context['list'].add('b');
        // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
        watchGrp.processChanges();
        expect(value, toEqualCollectionRecord(
            collection: ['a', 'b[null -> 1]'],
            previous: ['a'],
            additions: ['b[null -> 1]']));

        context['list'].add('c');
        context['list'].add('d');
        // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
        watchGrp.processChanges();
        expect(value, toEqualCollectionRecord(
            collection: ['a', 'b', 'c[null -> 2]', 'd[null -> 3]'],
            previous: ['a', 'b'],
            additions: ['c[null -> 2]', 'd[null -> 3]']));

        context['list'].remove('c');
        // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
        watchGrp.processChanges();
        expect(value, toEqualCollectionRecord(
            collection: ['a', 'b', 'd[3 -> 2]'],
            previous: ['a', 'b', 'c[2 -> null]', 'd[3 -> 2]'],
            moves: ['d[3 -> 2]'],
            removals: ['c[2 -> null]']));

        context['list'].clear();
        context['list'].addAll(['d', 'c', 'b', 'a']);
        // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
        watchGrp.processChanges();
        expect(value, toEqualCollectionRecord(
            collection: ['d[2 -> 0]', 'c[null -> 1]', 'b[1 -> 2]', 'a[0 -> 3]'],
            previous: ['a[0 -> 3]', 'b[1 -> 2]', 'd[2 -> 0]'],
            additions: ['c[null -> 1]'],
            moves: ['d[2 -> 0]', 'b[1 -> 2]', 'a[0 -> 3]']));
      });

      it('should test string by value rather than by reference', () {
        context['list'] = ['a', 'boo'];
        watchGrp.watch(parse('list', collection: true), logReactionFn);
        watchGrp.processChanges();

        context['list'][1] = 'b' + 'oo';
        expect(watchGrp.processChanges()).toEqual(0);
      });

      it('should ignore [NaN] != [NaN]', () {
        context['list'] = [double.NAN];
        watchGrp.watch(parse('list', collection: true), logReactionFn);
        watchGrp.processChanges();

        expect(watchGrp.processChanges()).toEqual(0);
      });

      it('should detect [NaN] moves', () {
        var value;
        context['list'] = [double.NAN, double.NAN];
        watchGrp.watch(parse('list', collection: true), (v, _) => value = v);
        watchGrp.processChanges();

        context['list']
          ..clear()
          ..addAll(['foo', double.NAN, double.NAN]);
        // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
        watchGrp.processChanges();
        expect(value, toEqualCollectionRecord(
            collection: ['foo[null -> 0]', 'NaN[0 -> 1]', 'NaN[1 -> 2]'],
            previous: ['NaN[0 -> 1]', 'NaN[1 -> 2]'],
            additions: ['foo[null -> 0]'],
            moves: ['NaN[0 -> 1]', 'NaN[1 -> 2]']));
      });

      it('should remove and add same item', () {
        var value;
        context['list'] = ['a', 'b', 'c'];
        watchGrp.watch(parse('list', collection: true), (v, _) => value = v);
        watchGrp.processChanges();

        context['list'].remove('b');
        // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
        watchGrp.processChanges();
        expect(value, toEqualCollectionRecord(
            collection: ['a', 'c[2 -> 1]'],
            previous: ['a', 'b[1 -> null]', 'c[2 -> 1]'],
            moves: ['c[2 -> 1]'],
            removals: ['b[1 -> null]']));

        context['list'].insert(1, 'b');
        // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
        watchGrp.processChanges();
        expect(value, toEqualCollectionRecord(
            collection: ['a', 'b[null -> 1]', 'c[1 -> 2]'],
            previous: ['a', 'c[1 -> 2]'],
            additions: ['b[null -> 1]'],
            moves: ['c[1 -> 2]']));
      });

      it('should support duplicates', () {
        var value;
        context['list'] = ['a', 'a', 'a', 'b', 'b'];
        watchGrp.watch(parse('list', collection: true), (v, _) => value = v);
        watchGrp.processChanges();

        context['list'].removeAt(0);
        // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
        watchGrp.processChanges();
        expect(value, toEqualCollectionRecord(
            collection: ['a', 'a', 'b[3 -> 2]', 'b[4 -> 3]'],
            previous: ['a', 'a', 'a[2 -> null]', 'b[3 -> 2]', 'b[4 -> 3]'],
            moves: ['b[3 -> 2]', 'b[4 -> 3]'],
            removals: ['a[2 -> null]']));
      });


      it('should support insertions/moves', () {
        var value;
        context['list'] = ['a', 'a', 'b', 'b'];
        watchGrp.watch(parse('list', collection: true), (v, _) => value = v);
        watchGrp.processChanges();

        context['list'].insert(0, 'b');
        // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
        watchGrp.processChanges();
        expect(value, toEqualCollectionRecord(
            collection: ['b[2 -> 0]', 'a[0 -> 1]', 'a[1 -> 2]', 'b', 'b[null -> 4]'],
            previous: ['a[0 -> 1]', 'a[1 -> 2]', 'b[2 -> 0]', 'b'],
            additions: ['b[null -> 4]'],
            moves: ['b[2 -> 0]', 'a[0 -> 1]', 'a[1 -> 2]']));
      });

      it('should support UnmodifiableListView', () {
        var hiddenList = [1];
        var value;
        context['list'] = new UnmodifiableListView(hiddenList);
        watchGrp.watch(parse('list', collection: true), (v, _) => value = v);

        // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
        watchGrp.processChanges();
        expect(value, toEqualCollectionRecord(
            collection: ['1[null -> 0]'],
            additions: ['1[null -> 0]']));

        // assert no changes detected
        expect(watchGrp.processChanges()).toEqual(0);

        // change the hiddenList normally this should trigger change detection
        // but because we are wrapped in UnmodifiableListView we see nothing.
        hiddenList[0] = 2;
        expect(watchGrp.processChanges()).toEqual(0);
      });

      it('should bug', () {
        var value;
        context['list'] = [1, 2, 3, 4];
        watchGrp.watch(parse('list', collection: true), (v, _) => value = v);

        // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
        watchGrp.processChanges();
        expect(value, toEqualCollectionRecord(
            collection: ['1[null -> 0]', '2[null -> 1]', '3[null -> 2]', '4[null -> 3]'],
            additions: ['1[null -> 0]', '2[null -> 1]', '3[null -> 2]', '4[null -> 3]']));

        context['list'].removeRange(0, 1);
        // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
        watchGrp.processChanges();
        expect(value, toEqualCollectionRecord(
            collection: ['2[1 -> 0]', '3[2 -> 1]', '4[3 -> 2]'],
            previous: ['1[0 -> null]', '2[1 -> 0]', '3[2 -> 1]', '4[3 -> 2]'],
            moves: ['2[1 -> 0]', '3[2 -> 1]', '4[3 -> 2]'],
            removals: ['1[0 -> null]']));

        context['list'].insert(0, 1);
        // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
        watchGrp.processChanges();
        expect(value, toEqualCollectionRecord(
            collection: ['1[null -> 0]', '2[0 -> 1]', '3[1 -> 2]', '4[2 -> 3]'],
            previous: ['2[0 -> 1]', '3[1 -> 2]', '4[2 -> 3]'],
            additions: ['1[null -> 0]'],
            moves: ['2[0 -> 1]', '3[1 -> 2]', '4[2 -> 3]']));
      });

      it('should properly support objects with equality', () {
        var value;
        context['list'] = [new _FooBar('a', 'a'), new _FooBar('a', 'a')];
        watchGrp.watch(parse('list', collection: true), (v, _) => value = v);

        // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
        watchGrp.processChanges();
        expect(value, toEqualCollectionRecord(
            collection: ['(0)a-a[null -> 0]', '(1)a-a[null -> 1]'],
            additions: ['(0)a-a[null -> 0]', '(1)a-a[null -> 1]']));

        context['list'].removeRange(0, 1);
        // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
        watchGrp.processChanges();
        expect(value, toEqualCollectionRecord(
            collection: ['(1)a-a[1 -> 0]'],
            previous: ['(0)a-a[0 -> null]', '(1)a-a[1 -> 0]'],
            moves: ['(1)a-a[1 -> 0]'],
            removals: ['(0)a-a[0 -> null]']));

        context['list'].insert(0, new _FooBar('a', 'a'));
        // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
        watchGrp.processChanges();
        expect(value, toEqualCollectionRecord(
            collection: ['(2)a-a[null -> 0]', '(1)a-a[0 -> 1]'],
            previous: ['(1)a-a[0 -> 1]'],
            additions: ['(2)a-a[null -> 0]'],
            moves: ['(1)a-a[0 -> 1]']));
      });

      it('should not report unnecessary moves', () {
        var value;
        context['list'] = ['a', 'b', 'c'];
        watchGrp.watch(parse('list', collection: true), (v, _) => value = v);
        watchGrp.processChanges();

        context['list']
          ..clear()
          ..addAll(['b', 'a', 'c']);
        // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
        watchGrp.processChanges();
        expect(value, toEqualCollectionRecord(
            collection: ['b[1 -> 0]', 'a[0 -> 1]', 'c'],
            previous: ['a[0 -> 1]', 'b[1 -> 0]', 'c'],
            moves: ['b[1 -> 0]', 'a[0 -> 1]']));
      });

      describe('map watching', () {
        it('should coalesce records added in the same cycle', () {
          context['map'] = {'foo': 'bar'};

          watchGrp.watch(parse('map', collection: true), (_, __) => null);
          expect(watchGrp.watchedCollections).toEqual(1);
          // Should not add a record when added in the same cycle
          watchGrp.watch(parse('map', collection: true), (_, __) => null);
          watchGrp.watch(parse('map', collection: true), (_, __) => null);
          expect(watchGrp.watchedCollections).toEqual(1);

          watchGrp.processChanges();
          // Should add a record when not added in the same cycle
          watchGrp.watch(parse('map', collection: true), (_, __) => null);
          expect(watchGrp.watchedCollections).toEqual(2);
          // Should not add a record when added in the same cycle
          watchGrp.watch(parse('map', collection: true), (_, __) => null);
          watchGrp.watch(parse('map', collection: true), (_, __) => null);
          expect(watchGrp.watchedCollections).toEqual(2);
        });

        describe('previous state', () {
          it('should store on insertion', () {
            var value;
            context['map'] = {};
            watchGrp.watch(parse('map', collection: true), (v, _) => value = v);
            watchGrp.processChanges();

            context['map']['a'] = 1;
            // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
            watchGrp.processChanges();
            expect(value, toEqualMapRecord(
                map: ['a[null -> 1]'],
                additions: ['a[null -> 1]']));

            context['map']['b'] = 2;
            // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
            watchGrp.processChanges();
            expect(value, toEqualMapRecord(
                map: ['a', 'b[null -> 2]'],
                previous: ['a'],
                additions: ['b[null -> 2]']));
          });

          it('should handle changing key/values correctly', () {
            var value;
            context['map'] = {1: 10, 2: 20};
            watchGrp.watch(parse('map', collection: true), (v, _) => value = v);
            watchGrp.processChanges();

            context['map'][1] = 20;
            context['map'][2] = 10;
            // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
            watchGrp.processChanges();
            expect(value, toEqualMapRecord(
                map: ['1[10 -> 20]', '2[20 -> 10]'],
                previous: ['1[10 -> 20]', '2[20 -> 10]'],
                changes: ['1[10 -> 20]', '2[20 -> 10]']));
          });
        });

        it('should do basic map watching', () {
          var value;
          context['map'] = {};
          watchGrp.watch(parse('map', collection: true), (v, _) => value = v);
          watchGrp.processChanges();

          context['map']['a'] = 'A';
          // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
          watchGrp.processChanges();
          expect(value, toEqualMapRecord(
              map: ['a[null -> A]'],
              additions: ['a[null -> A]']));

          context['map']['b'] = 'B';
          // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
          watchGrp.processChanges();
          expect(value, toEqualMapRecord(
              map: ['a', 'b[null -> B]'],
              previous: ['a'],
              additions: ['b[null -> B]']));

          context['map']['b'] = 'BB';
          context['map']['d'] = 'D';
          // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
          watchGrp.processChanges();
          expect(value, toEqualMapRecord(
              map: ['a', 'b[B -> BB]', 'd[null -> D]'],
              previous: ['a', 'b[B -> BB]'],
              additions: ['d[null -> D]'],
              changes: ['b[B -> BB]']));

          context['map'].remove('b');
          // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
          watchGrp.processChanges();
          expect(value, toEqualMapRecord(
              map: ['a', 'd'],
              previous: ['a', 'b[BB -> null]', 'd'],
              removals: ['b[BB -> null]']));

          context['map'].clear();
          // TODO expect(watchGrp.processChanges()).toBeGreaterThan(0); when guinness >= 0.1.11
          watchGrp.processChanges();
          expect(value, toEqualMapRecord(
              map: [],
              previous: ['a[A -> null]', 'd[D -> null]'],
              removals: ['a[A -> null]', 'd[D -> null]']));
        });

        it('should test string by value rather than by reference', () {
          context['map'] = {'foo': 'bar'};
          watchGrp.watch(parse('map'), logReactionFn);
          watchGrp.processChanges();

          context['map']['f' + 'oo'] = 'b' + 'ar';

          expect(watchGrp.processChanges()).toEqual(0);
        });

        it('should not see a NaN value as a change', () {
          context['map'] = {'foo': double.NAN};
          watchGrp.watch(parse('map'), logReactionFn);
          watchGrp.processChanges();

          expect(watchGrp.processChanges()).toEqual(0);
        });
      });

      describe('function watching', () {
        it('should detect no changes when watching a function', () {
          context['user'] = new _User('marko', 'vuksanovic', 15);

          watchGrp.watch(parse('user.isUnderAge'), logReactionFn);
          expect(watchGrp.processChanges()).toEqual(1);

          context['user'].age = 17;
          expect(watchGrp.processChanges()).toEqual(0);

          context['user'].age = 30;
          expect(watchGrp.processChanges()).toEqual(0);
        });

        it('should detect change when watching a property function', () {
          context['user'] = new _User('marko', 'vuksanovic', 15);
          watchGrp.watch(parse('user.isUnderAgeAsVariable'), logReactionFn);
          expect(watchGrp.processChanges()).toEqual(1);
          expect(watchGrp.processChanges()).toEqual(0);
          context['user'].isUnderAgeAsVariable = () => false;
          expect(watchGrp.processChanges()).toEqual(1);
        });
      });
    });

    describe('Eval records, coalescence - former watch group', () {
      eval(String expression, [evalContext]) {
        List log = [];
        var group = detector.createWatchGroup(evalContext == null ? context : evalContext);
        var watch = group.watch(parse(expression), (v, _) => log.add(v));
        group.processChanges();
        group.remove();
        if (log.isEmpty) {
          throw new StateError('Expression <$expression> was not evaluated');
        } else if (log.length > 1) {
          throw new StateError('Expression <$expression> produced too many values: $log');
        } else {
          return log.first;
        }
       }

       expectOrder(list) {
         watchGrp.processChanges(); // Clear the initial queue
         log.clear();
         watchGrp.processChanges();
         expect(log).toEqual(list);
       }

      // TODO to String
//      it('should have a toString for debugging', () {
//        watchGrp.watch(parse('a'), (v, p) {});
//        watchGrp.newGroup({});
//        expect("$watchGrp").toEqual(
//            'WATCHES: MARKER[null], MARKER[null]\n'
//            'WatchGroup[](watches: MARKER[null])\n'
//            '  WatchGroup[.0](watches: MARKER[null])'
//        );
//      });

      describe('watch lifecycle', () {
        it('should prevent reaction fn on removed', () {
          context['a'] = 'hello';

          var watch ;
          watchGrp.watch(parse('a'), (v, _) {
            log('removed');
            watch.remove();
          });
          watch = watchGrp.watch(parse('a'), (v, _) => log(v));
          watchGrp.processChanges();
          expect(log).toEqual(['removed']);
        });
      });

      // TODO: not all tests seems to be related to "property chaining"
      describe('property chaining', () {
        it('should read property', () {
          context['a'] = 'hello';

          // should fire on initial adding
          expect(watchGrp.watchedFields).toEqual(0);
          var watch = watchGrp.watch(parse('a'), (v, _) => log(v));
          expect(watch.expression).toEqual('a');
          expect(watchGrp.watchedFields).toEqual(1);
          watchGrp.processChanges();
          expect(log).toEqual(['hello']);

          // make sure no new changes are logged on extra detectChanges
          watchGrp.processChanges();
          expect(log).toEqual(['hello']);

          // Should detect value change
          context['a'] = 'bye';
          watchGrp.processChanges();
          expect(log).toEqual(['hello', 'bye']);

          // should cleanup after itself
          watch.remove();
          expect(watchGrp.watchedFields).toEqual(0);
          context['a'] = 'cant see me';
          watchGrp.processChanges();
          expect(log).toEqual(['hello', 'bye']);
        });

        describe('sequence mutations and ref changes', () {
          it('should handle a simultaneous map mutation and reference change', () {
            context['a'] = context['b'] = {1: 10, 2: 20};
            watchGrp.watch(new chd.CollectionAST(parse('a')), (v, _) => log(v));
            watchGrp.watch(new chd.CollectionAST(parse('b')), (v, _) => log(v));
            watchGrp.processChanges();

            expect(log.length).toEqual(2);
            expect(log[0], toEqualMapRecord(
                map: ['1[null -> 10]', '2[null -> 20]'],
                additions: ['1[null -> 10]', '2[null -> 20]']));
            expect(log[1], toEqualMapRecord(
                map: ['1[null -> 10]', '2[null -> 20]'],
                additions: ['1[null -> 10]', '2[null -> 20]']));
            log.clear();

            // context['a'] is set to a copy with an addition.
            context['a'] = new Map.from(context['a'])..[3] = 30;
            // context['b'] still has the original collection.  We'll mutate it.
            context['b'].remove(1);

            expect(watchGrp.processChanges()).toEqual(2);
            expect(log[0], toEqualMapRecord(
                    map: ['1', '2', '3[null -> 30]'],
                    previous: ['1', '2'],
                    additions: ['3[null -> 30]']));
            expect(log[1], toEqualMapRecord(
                    map: ['2'],
                    previous: ['1[10 -> null]', '2'],
                    removals: ['1[10 -> null]']));
          });

          it('should handle a simultaneous list mutation and reference change', () {
            context['a'] = context['b'] = [0, 1];
            var watchA = watchGrp.watch(new chd.CollectionAST(parse('a')), (v, _) => log(v));
            var watchB = watchGrp.watch(new chd.CollectionAST(parse('b')), (v, p) => log(v));

            watchGrp.processChanges();

            expect(log.length).toEqual(2);
            expect(log[0], toEqualCollectionRecord(
                collection: ['0[null -> 0]', '1[null -> 1]'],
                additions: ['0[null -> 0]', '1[null -> 1]']));
            expect(log[1], toEqualCollectionRecord(
                collection: ['0[null -> 0]', '1[null -> 1]'],
                additions: ['0[null -> 0]', '1[null -> 1]']));
            log.clear();

            // context['a'] is set to a copy with an addition.
            context['a'] = context['a'].toList()..add(2);
            // context['b'] still has the original collection.  We'll mutate it.
            context['b'].remove(0);

            watchGrp.processChanges();
            expect(log.length).toEqual(2);
            expect(log[0], toEqualCollectionRecord(
                collection: ['0', '1', '2[null -> 2]'],
                previous: ['0', '1'],
                additions: ['2[null -> 2]']));
            expect(log[1], toEqualCollectionRecord(
                collection: ['1[1 -> 0]'],
                previous: ['0[0 -> null]', '1[1 -> 0]'],
                moves: ['1[1 -> 0]'],
                removals: ['0[0 -> null]']));
          });

          it('should work correctly with UnmodifiableListView', () {
            context['a'] = new UnmodifiableListView([0, 1]);
            var watchA = watchGrp.watch(new chd.CollectionAST(parse('a')), (v, _) => log(v));

            watchGrp.processChanges();
            expect(log.length).toEqual(1);
            expect(log[0], toEqualCollectionRecord(
                collection: ['0[null -> 0]', '1[null -> 1]'],
                additions: ['0[null -> 0]', '1[null -> 1]']));
            log.clear();

            context['a'] = new UnmodifiableListView([1, 0]);

            watchGrp.processChanges();
            expect(log.length).toEqual(1);
            expect(log[0], toEqualCollectionRecord(
                collection: ['1[1 -> 0]', '0[0 -> 1]'],
                previous: ['0[0 -> 1]', '1[1 -> 0]'],
                moves: ['1[1 -> 0]', '0[0 -> 1]']));
          });
        });

        it('should read property chain', () {
          context['a'] = {'b': 'hello'};

          // should fire on initial adding
          expect(watchGrp.watchedFields).toEqual(0);
          expect(watchGrp.totalCount).toEqual(0);
          var watch = watchGrp.watch(parse('a.b'), (v, _) => log(v));
          expect(watch.expression).toEqual('a.b');
          expect(watchGrp.watchedFields).toEqual(2);
          expect(watchGrp.totalCount).toEqual(3);
          watchGrp.processChanges();
          expect(log).toEqual(['hello']);

          // make sore no new changes are logged on extra detectChanges
          watchGrp.processChanges();
          expect(log).toEqual(['hello']);

          // make sure no changes or logged when intermediary object changes
          context['a'] = {'b': 'hello'};
          watchGrp.processChanges();
          expect(log).toEqual(['hello']);

          // Should detect value change
          context['a'] = {'b': 'hello2'};
          watchGrp.processChanges();
          expect(log).toEqual(['hello', 'hello2']);

          // Should detect value change
          context['a']['b'] = 'bye';
          watchGrp.processChanges();
          expect(log).toEqual(['hello', 'hello2', 'bye']);

          // should cleanup after itself
          watch.remove();
          expect(watchGrp.watchedFields).toEqual(0);
          context['a']['b'] = 'cant see me';
          watchGrp.processChanges();
          expect(log).toEqual(['hello', 'hello2', 'bye']);
        });

        it('should coalesce records', () {
          var user1 = {'first': 'misko', 'last': 'hevery'};
          var user2 = {'first': 'misko', 'last': 'Hevery'};

          context['user'] = user1;

          // should fire on initial adding
          expect(watchGrp.watchedFields).toEqual(0);
          var watch = watchGrp.watch(parse('user'), (v, _) => log(v));
          var watchFirst = watchGrp.watch(parse('user.first'), (v, _) => log(v));
          var watchLast = watchGrp.watch(parse('user.last'), (v, _) => log(v));
          expect(watchGrp.watchedFields).toEqual(3);

          watchGrp.processChanges();
          expect(log).toEqual([user1, 'misko', 'hevery']);
          log.clear();

          context['user'] = user2;
          watchGrp.processChanges();
          expect(log).toEqual([user2, 'Hevery']);

          watch.remove();
          expect(watchGrp.watchedFields).toEqual(3);

          watchFirst.remove();
          expect(watchGrp.watchedFields).toEqual(2);

          watchLast.remove();
          expect(watchGrp.watchedFields).toEqual(0);

          expect(() => watch.remove()).toThrow('Already deleted!');
        });

        it('should eval pure FunctionApply', () {
          context['a'] = {'val': 1};

          chd.FunctionApply fn = new _LoggingFunctionApply(log);
          var watch = watchGrp.watch(
              new chd.PureFunctionAST('add', fn, [parse('a.val')]),
              (v, _) => log(v)
          );

          // "a" & "a.val"
          expect(watchGrp.watchedFields).toEqual(2);
          // "add"
          expect(watchGrp.watchedEvals).toEqual(1);

          watchGrp.processChanges();
          expect(log).toEqual([[1], null]);
          log.clear();

          context['a'] = {'val': 2};
          watchGrp.processChanges();
          expect(log).toEqual([[2]]);
        });

        it('should eval pure function', () {
          context['a'] = {'val': 1};
          context['b'] = {'val': 2};

          var watch = watchGrp.watch(
             new chd.PureFunctionAST(
                 'add',
                 (a, b) { log('+'); return a+b; },
                 [parse('a.val'), parse('b.val')]
             ),
             (v, _) => log(v)
          );

          // "a", "a.val", "b", "b.val"
          expect(watchGrp.watchedFields).toEqual(4);
          // add
          expect(watchGrp.watchedEvals).toEqual(1);
          watchGrp.processChanges();
          expect(log).toEqual(['+', 3]);

          // extra checks should not trigger functions
          log.clear();
          watchGrp.processChanges();
          watchGrp.processChanges();
          expect(log).toEqual([]);

          // multiple arg changes should only trigger function once.
          log.clear();
          context['a']['val'] = 3;
          context['b']['val'] = 4;
          watchGrp.processChanges();
          expect(log).toEqual(['+', 7]);

          log.clear();
          watch.remove();
          expect(watchGrp.watchedFields).toEqual(0);
          expect(watchGrp.watchedEvals).toEqual(0);
          context['a']['val'] = 0;
          context['b']['val'] = 0;
          watchGrp.processChanges();
          expect(log).toEqual([]);
        });

        it('should eval closure', () {
          context['a'] = {'val': 1};
          context['b'] = {'val': 2};
          var innerState = 1;

          var watch = watchGrp.watch(
              new chd.ClosureAST(
                  'sum',
                  (a, b) { log('+'); return innerState+a+b; },
                  [parse('a.val'), parse('b.val')]
              ),
              (v, _) => log(v)
          );

          // "a", "a.val", "b", "b.val"
          expect(watchGrp.watchedFields).toEqual(4);
          // add
          expect(watchGrp.watchedEvals).toEqual(1);
          watchGrp.processChanges();
          expect(log).toEqual(['+', 4]);

          // extra checks should trigger closures
          log.clear();
          watchGrp.processChanges();
          watchGrp.processChanges();
          expect(log).toEqual(['+', '+']);

          // multiple arg changes should only trigger function once.
          log.clear();
          context['a']['val'] = 3;
          context['b']['val'] = 4;
          watchGrp.processChanges();
          expect(log).toEqual(['+', 8]);

          // inner state change should only trigger function once.
          log.clear();
          innerState = 2;
          watchGrp.processChanges();
          expect(log).toEqual(['+', 9]);

          log.clear();
          watch.remove();
          expect(watchGrp.watchedFields).toEqual(0);
          expect(watchGrp.watchedEvals).toEqual(0);
          context['a']['val'] = 0;
          context['b']['val'] = 0;
          watchGrp.processChanges();
          expect(log).toEqual([]);
        });

        it('should eval closure', () {
          var obj;
          obj = {
              'methodA': (arg1) {
                log('methodA($arg1) => ${obj['valA']}');
                return obj['valA'];
              },
              'valA': 'A'
          };
          context['obj'] = obj;
          context['arg0'] = 1;

          var watch = watchGrp.watch(
              new chd.MethodAST(parse('obj'), 'methodA', [parse('arg0')]), (v, _) => log(v));

          // "obj", "arg0"
          expect(watchGrp.watchedFields).toEqual(2);
          // "methodA()"
          expect(watchGrp.watchedEvals).toEqual(1);
          watchGrp.processChanges();
          expect(log).toEqual(['methodA(1) => A', 'A']);

          log.clear();
          watchGrp.processChanges();
          watchGrp.processChanges();
          expect(log).toEqual(['methodA(1) => A', 'methodA(1) => A']);

          log.clear();
          obj['valA'] = 'B';
          context['arg0'] = 2;
          watchGrp.processChanges();
          expect(log).toEqual(['methodA(2) => B', 'B']);

          log.clear();
          watch.remove();
          expect(watchGrp.watchedFields).toEqual(0);
          expect(watchGrp.watchedEvals).toEqual(0);
          obj['valA'] = 'C';
          context['arg0'] = 3;
          watchGrp.processChanges();
          expect(log).toEqual([]);
        });


        it('should eval chained pure function', () {
          context['a'] = {'val': 1};
          context['b'] = {'val': 2};
          context['c'] = {'val': 3};

          var aPlusB = new chd.PureFunctionAST(
              'add1',
              (a, b) { log('$a+$b'); return a + b; },
              [parse('a.val'), parse('b.val')]);

          var aPlusBPlusC = new chd.PureFunctionAST(
              'add2',
              (b, c) { log('$b+$c'); return b + c; },
              [aPlusB, parse('c.val')]);

          var watch = watchGrp.watch(aPlusBPlusC, (v, _) => log(v));

          // "a", "a.val", "b", "b.val", "c", "c.val"
          expect(watchGrp.watchedFields).toEqual(6);
          // "add1", "add2"
          expect(watchGrp.watchedEvals).toEqual(2);

          watchGrp.processChanges();
          expect(log).toEqual(['1+2', '3+3', 6]);

          // extra checks should not trigger functions
          log.clear();
          watchGrp.processChanges();
          watchGrp.processChanges();
          expect(log).toEqual([]);

          // multiple arg changes should only trigger function once.
          log.clear();
          context['a']['val'] = 3;
          context['b']['val'] = 4;
          context['c']['val'] = 5;
          watchGrp.processChanges();
          expect(log).toEqual(['3+4', '7+5', 12]);

          log.clear();
          context['a']['val'] = 9;
          watchGrp.processChanges();
          expect(log).toEqual(['9+4', '13+5', 18]);

          log.clear();
          context['c']['val'] = 9;
          watchGrp.processChanges();
          expect(log).toEqual(['13+9', 22]);

          log.clear();
          watch.remove();
          expect(watchGrp.watchedFields).toEqual(0);
          expect(watchGrp.watchedEvals).toEqual(0);
          context['a']['val'] = 0;
          context['b']['val'] = 0;
          watchGrp.processChanges();
          expect(log).toEqual([]);
        });

        it('should eval method', () {
          var obj = new _MyClass(log);
          obj.valA = 'A';
          context['obj'] = obj;
          context['arg0'] = 1;

          var watch = watchGrp.watch(
              new chd.MethodAST(parse('obj'), 'methodA', [parse('arg0')]), (v, _) => log(v));

          // "obj", "arg0"
          expect(watchGrp.watchedFields).toEqual(2);
          // "methodA()"
          expect(watchGrp.watchedEvals).toEqual(1);
          watchGrp.processChanges();
          expect(log).toEqual(['methodA(1) => A', 'A']);

          log.clear();

          watchGrp.processChanges();
          watchGrp.processChanges();
          expect(log).toEqual(['methodA(1) => A', 'methodA(1) => A']);

          log.clear();
          obj.valA = 'B';
          context['arg0'] = 2;
          watchGrp.processChanges();
          expect(log).toEqual(['methodA(2) => B', 'B']);

          log.clear();
          watch.remove();
          expect(watchGrp.watchedFields).toEqual(0);
          expect(watchGrp.watchedEvals).toEqual(0);
          obj.valA = 'C';
          context['arg0'] = 3;
          watchGrp.processChanges();
          expect(log).toEqual([]);
        });

        it('should eval method chain', () {
          var obj1 = new _MyClass(log);
          var obj2 = new _MyClass(log);
          obj1.valA = obj2;
          obj2.valA = 'A';
          context['obj'] = obj1;
          context['arg0'] = 0;
          context['arg1'] = 1;

          // obj.methodA(arg0)
          var ast = new chd.MethodAST(parse('obj'), 'methodA', [parse('arg0')]);
          ast = new chd.MethodAST(ast, 'methodA', [parse('arg1')]);
          var watch = watchGrp.watch(ast, (v, _) => log(v));

          // "obj", "arg0", "arg1";
          expect(watchGrp.watchedFields).toEqual(3);
          // "methodA()", "methodA()"
          expect(watchGrp.watchedEvals).toEqual(2);
          watchGrp.processChanges();
          expect(log).toEqual(['methodA(0) => MyClass', 'methodA(1) => A', 'A']);

          log.clear();
          watchGrp.processChanges();
          watchGrp.processChanges();
          expect(log).toEqual(['methodA(0) => MyClass', 'methodA(1) => A',
                               'methodA(0) => MyClass', 'methodA(1) => A']);

          log.clear();
          obj2.valA = 'B';
          context['arg0'] = 10;
          context['arg1'] = 11;
          watchGrp.processChanges();
          expect(log).toEqual(['methodA(10) => MyClass', 'methodA(11) => B', 'B']);

          log.clear();
          watch.remove();
          expect(watchGrp.watchedFields).toEqual(0);
          expect(watchGrp.watchedEvals).toEqual(0);
          obj2.valA = 'C';
          context['arg0'] = 20;
          context['arg1'] = 21;
          watchGrp.processChanges();
          expect(log).toEqual([]);
        });

        it('should not return null when evaling method first time', () {
          context['text'] ='abc';
          var ast = new chd.MethodAST(parse('text'), 'toUpperCase', []);
          var watch = watchGrp.watch(ast, (v, _) => log(v));

          watchGrp.processChanges();
          expect(log).toEqual(['ABC']);
        });

        it('should not eval a function if registered during reaction', () {
          context['text'] ='abc';

          var ast = new chd.MethodAST(parse('text'), 'toLowerCase', []);
          var watch = watchGrp.watch(ast, (v, _) {
            var ast = new chd.MethodAST(parse('text'), 'toUpperCase', []);
            watchGrp.watch(ast, (v, _) {
              log(v);
            });
          });

          watchGrp.processChanges();
          watchGrp.processChanges();
          expect(log).toEqual(['ABC']);
        });


        it('should eval function eagerly when registered during reaction', () {
          context['obj'] = {'fn': (arg) { log('fn($arg)'); return arg; }};
          context['arg1'] = 'OUT';
          context['arg2'] = 'IN';
          var ast = new chd.MethodAST(parse('obj'), 'fn', [parse('arg1')]);
          var watch = watchGrp.watch(ast, (v, _) {
            var ast = new chd.MethodAST(parse('obj'), 'fn', [parse('arg2')]);
            watchGrp.watch(ast, (v, _) {
              log('reaction: $v');
            });
          });

          expect(log).toEqual([]);
          watchGrp.processChanges();
          expect(log).toEqual(['fn(OUT)', 'fn(IN)', 'reaction: IN']);
          log.clear();
          watchGrp.processChanges();
          expect(log).toEqual(['fn(OUT)', 'fn(IN)']);
        });

        it('should ignore NaN != NaN', () {
          watchGrp.watch(new chd.ClosureAST('NaN', () => double.NAN, []), (_, __) => log('NaN'));

          watchGrp.processChanges();
          expect(log).toEqual(['NaN']);

          log.clear();
          watchGrp.processChanges();
          expect(log).toEqual([]);
        }) ;

        it('should test string by value', () {
          watchGrp.watch(new chd.ClosureAST('String', () => 'value', []), (v, _) => log(v));

          watchGrp.processChanges();
          expect(log).toEqual(['value']);

          log.clear();
          watchGrp.processChanges();
          expect(log).toEqual([]);
        });

        it('should read constant', () {
          var watch = watchGrp.watch(new chd.ConstantAST(123), (v, _) => log(v));
          expect(watch.expression).toEqual('123');
          expect(watchGrp.watchedFields).toEqual(0);
          log.clear();
          watchGrp.processChanges();
          expect(log).toEqual([123]);

          // make sore no new changes are logged on extra detectChanges
          log.clear();
          watchGrp.processChanges();
          expect(log).toEqual([]);
        });

        it('should wrap iterable in ObservableList', () {
          context['list'] = [];
          var watch = watchGrp.watch(new chd.CollectionAST(parse('list')), (v, _) => log(v));

          expect(watchGrp.watchedFields).toEqual(1);
          expect(watchGrp.watchedCollections).toEqual(1);
          expect(watchGrp.watchedEvals).toEqual(0);

          watchGrp.processChanges();
          expect(log.length).toEqual(1);
          expect(log[0], toEqualCollectionRecord());

          log.clear();
          context['list'] = [1];
          watchGrp.processChanges();
          expect(log.length).toEqual(1);
          expect(log[0], toEqualCollectionRecord(
              collection: ['1[null -> 0]'],
              additions: ['1[null -> 0]']));

          log.clear();
          watch.remove();
          expect(watchGrp.watchedFields).toEqual(0);
          expect(watchGrp.watchedCollections).toEqual(0);
          expect(watchGrp.watchedEvals).toEqual(0);
        });

        it('should watch literal arrays made of expressions', () {
          context['a'] = 1;
          var ast = new chd.CollectionAST(
            new chd.PureFunctionAST('[a]', new ArrayFn(), [parse('a')])
          );
          var watch = watchGrp.watch(ast, (v, _) => log(v));
          watchGrp.processChanges();
          expect(log[0], toEqualCollectionRecord(
              collection: ['1[null -> 0]'],
              additions: ['1[null -> 0]']));

          log.clear();
          context['a'] = 2;
          watchGrp.processChanges();
          expect(log[0], toEqualCollectionRecord(
              collection: ['2[null -> 0]'],
              previous: ['1[0 -> null]'],
              additions: ['2[null -> 0]'],
              removals: ['1[0 -> null]']));
        });

        it('should watch pure function whose result goes to pure function', () {
          context['a'] = 1;
          var ast = new chd.PureFunctionAST(
              '-',
              (v) => -v,
              [new chd.PureFunctionAST('++', (v) => v + 1, [parse('a')])]
          );
          var watch = watchGrp.watch(ast, (v, _) => log(v));
          expect(watchGrp.processChanges()).not.toBe(null);
          expect(log).toEqual([-2]);

          log.clear();
          context['a'] = 2;
          expect(watchGrp.processChanges()).not.toBe(null);
          expect(log).toEqual([-3]);
        });
      });

      describe('evaluation', () {
        it('should support simple literals', () {
          expect(eval('42')).toBe(42);
          expect(eval('87')).toBe(87);
        });

        it('should support context access', () {
          context['x'] = 42;
          expect(eval('x')).toBe(42);
          context['y'] = 87;
          expect(eval('y')).toBe(87);
        });

        it('should support custom context', () {
          expect(eval('x', {'x': 42})).toBe(42);
          expect(eval('x', {'x': 87})).toBe(87);
        });

        it('should support named arguments for scope calls', () {
          var context = new _TestData();
          expect(eval("sub1(1)", context)).toEqual(1);
          expect(eval("sub1(3, b: 2)", context)).toEqual(1);

          expect(eval("sub2()", context)).toEqual(0);
          expect(eval("sub2(a: 3)", context)).toEqual(3);
          expect(eval("sub2(a: 3, b: 2)", context)).toEqual(1);
          expect(eval("sub2(b: 4)", context)).toEqual(-4);
        });

        it('should support named arguments for scope calls (map)', () {
          context["sub1"] = (a, {b: 0}) => a - b;
          expect(eval("sub1(1)")).toEqual(1);
          expect(eval("sub1(3, b: 2)")).toEqual(1);

          context["sub2"] = ({a: 0, b: 0}) => a - b;
          expect(eval("sub2()")).toEqual(0);
          expect(eval("sub2(a: 3)")).toEqual(3);
          expect(eval("sub2(a: 3, b: 2)")).toEqual(1);
          expect(eval("sub2(b: 4)")).toEqual(-4);
        });

        it('should support named arguments for member calls', () {
          context['o'] = new _TestData();
          expect(eval("o.sub1(1)")).toEqual(1);
          expect(eval("o.sub1(3, b: 2)")).toEqual(1);

          expect(eval("o.sub2()")).toEqual(0);
          expect(eval("o.sub2(a: 3)")).toEqual(3);
          expect(eval("o.sub2(a: 3, b: 2)")).toEqual(1);
          expect(eval("o.sub2(b: 4)")).toEqual(-4);
        });

        it('should support named arguments for member calls (map)', () {
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
      });

      describe('child group', () {
        it('should remove all watches in group and group\'s children', () {
          var child1a = watchGrp.createChild(context);
          var child1b = watchGrp.createChild(context);
          var child2 = child1a.createChild(context);
          var ast = parse('a');
          watchGrp.watch(ast, (_, __) => log('0a'));
          child1a.watch(ast, (_, __) => log('1a'));
          child1b.watch(ast, (_, __) => log('1b'));
          watchGrp.watch(ast, (_, __) => log('0A'));
          child1a.watch(ast, (_, __) => log('1A'));
          child2.watch(ast, (_, __) => log('2A'));

          context['a'] = 1;
          watchGrp.processChanges();
          expect(log).toEqual(['0a', '0A', '1a', '1A', '2A', '1b']);

          log.clear();
          context['a'] = 2;
          child1a.remove(); // also remove child2
          watchGrp.processChanges();
          expect(log).toEqual(['0a', '0A', '1b']);
        });

        it('should add watches within its own group', () {
          var child = watchGrp.createChild(context);
          var watchA = watchGrp.watch(parse('a'), (_, __) => log('a'));
          var watchB = child.watch(parse('b'), (_, __) => log('b'));

          context['a'] = 1;
          context['b'] = 1;
          expect(watchGrp.processChanges()).toEqual(2);
          expect(log).toEqual(['a', 'b']);

          log.clear();
          context['a'] = 2;
          context['b'] = 2;
          watchA.remove();
          expect(watchGrp.processChanges()).toEqual(1);
          expect(log).toEqual(['b']);

          log.clear();
          context['a'] = 3;
          context['b'] = 3;
          watchB.remove();
          expect(watchGrp.processChanges()).toEqual(0);
          expect(log).toEqual([]);

          log.clear();
          watchB = child.watch(parse('b'), (_, __) => log('b'));
          watchA = watchGrp.watch(parse('a'), (_, __) => log('a'));
          context['a'] = 4;
          context['b'] = 4;
          expect(watchGrp.processChanges()).toEqual(2);
          expect(log).toEqual(['a', 'b']);
        });

        it('should properly add children', () {
          expect(() {
            var a = detector.createWatchGroup(context);
            var b = detector.createWatchGroup(context);
            var aChild = a.createChild(context);
            a.processChanges();
            b.processChanges();
          }).not.toThrow();
        });


        it('should remove all field watches in group and group\'s children', () {
          watchGrp.watch(parse('a'), (_, __) => log('0a'));
          var child1a = watchGrp.createChild(context);
          var child1b = watchGrp.createChild(context);
          var child2 = child1a.createChild(context);
          child1a.watch(parse('a'), (_, __) => log('1a'));
          child1b.watch(parse('a'), (_, __) => log('1b'));
          watchGrp.watch(parse('a'), (_, __) => log('0A'));
          child1a.watch(parse('a'), (_, __) => log('1A'));
          child2.watch(parse('a'), (_, __) => log('2A'));

          // flush initial reaction functions
          expect(watchGrp.processChanges()).toEqual(6);
          // This is a BC wrt the former implementation which was preserving registration order
          // -> expect(log).toEqual(['0a', '1a', '1b', '0A', '1A', '2A']);
          expect(log).toEqual(['0a', '0A', '1a', '1A', '2A', '1b']);
          expect(watchGrp.watchedFields).toEqual(1);
          expect(watchGrp.totalWatchedFields).toEqual(4);

          log.clear();
          context['a'] = 1;
          expect(watchGrp.processChanges()).toEqual(6);
          expect(log).toEqual(['0a', '0A', '1a', '1A', '2A', '1b']); // we go by group order

          log.clear();
          context['a'] = 2;
          child1a.remove(); // should also remove child2
          expect(watchGrp.processChanges()).toEqual(3);
          expect(log).toEqual(['0a', '0A', '1b']);
          expect(watchGrp.watchedFields).toEqual(1);
          expect(watchGrp.totalWatchedFields).toEqual(2);
        });

        it('should remove all method watches in group and group\'s children', () {
          context['my'] = new _MyClass(log);
          var countMethod = new chd.MethodAST(parse('my'), 'count', []);
          watchGrp.watch(countMethod, (_, __) => log('0a'));
          expectOrder(['0a']);

          var child1a = watchGrp.createChild(new PrototypeMap(context));
          var child1b = watchGrp.createChild(new PrototypeMap(context));
          var child2 = child1a.createChild(new PrototypeMap(context));
          var child3 = child2.createChild(new PrototypeMap(context));
          child1a.watch(countMethod, (_, __) => log('1a'));
          expectOrder(['0a', '1a']);
          child1b.watch(countMethod, (_, __) => log('1b'));
          expectOrder(['0a', '1a', '1b']);
          watchGrp.watch(countMethod, (_, __) => log('0A'));
          expectOrder(['0a', '0A', '1a', '1b']);
          child1a.watch(countMethod, (_, __) => log('1A'));
          expectOrder(['0a', '0A', '1a', '1A', '1b']);
          child2.watch(countMethod, (_, __) => log('2A'));
          expectOrder(['0a', '0A', '1a', '1A', '2A', '1b']);
          child3.watch(countMethod, (_, __) => log('3'));
          expectOrder(['0a', '0A', '1a', '1A', '2A', '3', '1b']);

          // flush initial reaction functions
          expect(watchGrp.processChanges()).toEqual(7);
          expectOrder(['0a', '0A', '1a', '1A', '2A', '3', '1b']);

          child1a.remove(); // should also remove child2 and child 3
          expect(watchGrp.processChanges()).toEqual(3);
          expectOrder(['0a', '0A', '1b']);
        });

        it('should add watches within its own group', () {
          context['my'] = new _MyClass(log);
          var countMethod = new chd.MethodAST(parse('my'), 'count', []);
          var ra = watchGrp.watch(countMethod, (_, __) => log('a'));
          var child = watchGrp.createChild(context);
          var cb = child.watch(countMethod, (_, __) => log('b'));

          expectOrder(['a', 'b']);
          expectOrder(['a', 'b']);

          ra.remove();
          expectOrder(['b']);

          cb.remove();
          expectOrder([]);

          cb = child.watch(countMethod, (_, __) => log('b'));
          ra = watchGrp.watch(countMethod, (_, __) => log('a'));;
          expectOrder(['a', 'b']);
        });

        it('should not call reaction function on removed group', () {
          context['name'] = 'misko';
          var child = watchGrp.createChild(context);
          watchGrp.watch(parse('name'), (v, _) {
            log.add('root $v');
            if (v == 'destroy') child.remove();
          });

          child.watch(parse('name'), (v, _) => log.add('child $v'));
          watchGrp.processChanges();
          expect(log).toEqual(['root misko', 'child misko']);
          log.clear();

          context['name'] = 'destroy';
          watchGrp.processChanges();
          expect(log).toEqual(['root destroy']);
        });

        it('should watch children', () {
          var childContext = new PrototypeMap(context);
          context['a'] = 'OK';
          context['b'] = 'BAD';
          childContext['b'] = 'OK';
          watchGrp.watch(parse('a'), (v, _) => log(v));
          watchGrp.createChild(childContext).watch(parse('b'), (v, _) => log(v));

          watchGrp.processChanges();
          expect(log).toEqual(['OK', 'OK']);

          log.clear();
          context['a'] = 'A';
          childContext['b'] = 'B';

          watchGrp.processChanges();
          expect(log).toEqual(['A', 'B']);
        });
      });
    });

    describe('Releasable records', () {
      it('should release records when a watch is removed', () {
        context['td'] = new _TestData();
        context['a'] = 10;
        context['b'] = 5;
        var watch = watchGrp.watch(parse('td.sub1(a, b: b)'), (v, _) => log(v));
        watchGrp.processChanges();
        expect(log).toEqual([5]);
        // td, a & b
        expect(watchGrp.watchedFields).toEqual(3);
        expect(watchGrp.watchedEvals).toEqual(1);

        watch.remove();
        expect(watchGrp.watchedFields).toEqual(0);
        expect(watchGrp.watchedEvals).toEqual(0);
      });

      it('should release records when a group is removed', () {
        context['td'] = new _TestData();
        context['a'] = 10;
        context['b'] = 5;
        var childGroup = watchGrp.createChild(context);
        var watch = childGroup.watch(parse('td.sub1(a, b: b)'), (v, _) => log(v));
        watchGrp.processChanges();
        expect(log).toEqual([5]);
        // td, a & b
        expect(watchGrp.totalWatchedFields).toEqual(3);
        expect(watchGrp.totalWatchedEvals).toEqual(1);

        childGroup.remove();
        expect(watchGrp.totalWatchedFields).toEqual(0);
        expect(watchGrp.totalWatchedEvals).toEqual(0);
      });
    });

    describe('Checked records', () {
      it('should checked constant records only once', () {
        context['log'] = (arg) => log(arg);
        watchGrp.watch(parse('log("foo")'), (_, __) => null);

        // log()
        expect(watchGrp.watchedEvals).toEqual(1);
        // context, "foo" & log()
        expect(watchGrp.totalCheckedRecords).toEqual(3);

        watchGrp.processChanges();

        // log()
        expect(watchGrp.watchedEvals).toEqual(1);
        // log() only, context & "foo" are constant watched only once
        expect(watchGrp.totalCheckedRecords).toEqual(1);
      });
    });

    describe('Unchanged records', () {
      it('should trigger fresh listeners', () {
        context['foo'] = 'bar';
        watchGrp.watch(parse('foo'), (v, _) => log('foo=$v'));
        watchGrp.processChanges();
        expect(log).toEqual(['foo=bar']);

        log.clear();
        watchGrp.watch(parse('foo'), (v, _) => log('foo[fresh]=$v'));
        watchGrp.processChanges();
        expect(log).toEqual(['foo[fresh]=bar']);
      });
    });

  });
}

Matcher toEqualCollectionRecord({collection, previous, additions, moves, removals}) =>
    new CollectionRecordMatcher(collection:collection, previous: previous, additions:additions,
                                moves:moves, removals:removals);

Matcher toEqualMapRecord({map, previous, additions, changes, removals}) =>
    new MapRecordMatcher(map:map, previous: previous, additions:additions, changes:changes,
                         removals:removals);

abstract class _CollectionMatcher<T> extends Matcher {
  List<T> _getList(Function it) {
    var result = <T>[];
    it((item) {
      result.add(item);
    });
    return result;
  }

  bool _compareLists(String tag, List expected, List actual, List diffs) {
    var equals = true;
    Iterator iActual = actual.iterator;
    iActual.moveNext();
    T actualItem = iActual.current;
    if (expected == null) {
      expected = [];
    }
    for (String expectedItem in expected) {
      if (actualItem == null) {
        equals = false;
        diffs.add('$tag too short: $expectedItem');
      } else {
        if ("$actualItem" != expectedItem) {
          equals = false;
          diffs.add('$tag mismatch: $actualItem != $expectedItem');
        }
        iActual.moveNext();
        actualItem = iActual.current;
      }
    }
    if (actualItem != null) {
      diffs.add('$tag too long: $actualItem');
      equals = false;
    }
    return equals;
  }
}

class CollectionRecordMatcher extends _CollectionMatcher<ItemRecord> {
  final List collection;
  final List previous;
  final List additions;
  final List moves;
  final List removals;

  CollectionRecordMatcher({this.collection, this.previous,
                          this.additions, this.moves, this.removals});

  Description describeMismatch(changes, Description mismatchDescription,
                               Map matchState, bool verbose) {
    List diffs = matchState['diffs'];
    if (diffs == null) return mismatchDescription;
    return mismatchDescription..add(diffs.join('\n'));
  }

  Description describe(Description description) {
    add(name, collection) {
      if (collection != null) {
        description.add('$name: ${collection.join(', ')}\n   ');
      }
    }

    add('collection', collection);
    add('previous', previous);
    add('additions', additions);
    add('moves', moves);
    add('removals', removals);
    return description;
  }

  bool matches(CollectionChangeRecord changeRecord, Map matchState) {
    var diffs = matchState['diffs'] = [];
    return checkCollection(changeRecord, diffs) &&
           checkPrevious(changeRecord, diffs) &&
           checkAdditions(changeRecord, diffs) &&
           checkMoves(changeRecord, diffs) &&
           checkRemovals(changeRecord, diffs);
  }

  bool checkCollection(CollectionChangeRecord changeRecord, List diffs) {
    List items = _getList((fn) => changeRecord.forEachItem(fn));
    bool equals = _compareLists("collection", collection, items, diffs);
    int iterableLength = changeRecord.iterable.toList().length;
    if (iterableLength != items.length) {
      diffs.add('collection length mismatched: $iterableLength != ${items.length}');
      equals = false;
    }
    return equals;
  }

  bool checkPrevious(CollectionChangeRecord changeRecord, List diffs) {
    List items = _getList((fn) => changeRecord.forEachPreviousItem(fn));
    return _compareLists("previous", previous, items, diffs);
  }

  bool checkAdditions(CollectionChangeRecord changeRecord, List diffs) {
    List items = _getList((fn) => changeRecord.forEachAddition(fn));
    return _compareLists("additions", additions, items, diffs);
  }

  bool checkMoves(CollectionChangeRecord changeRecord, List diffs) {
    List items = _getList((fn) => changeRecord.forEachMove(fn));
    return _compareLists("moves", moves, items, diffs);
  }

  bool checkRemovals(CollectionChangeRecord changeRecord, List diffs) {
    List items = _getList((fn) => changeRecord.forEachRemoval(fn));
    return _compareLists("removes", removals, items, diffs);
  }
}

class MapRecordMatcher  extends _CollectionMatcher<KeyValueRecord> {
  final List map;
  final List previous;
  final List additions;
  final List changes;
  final List removals;

  MapRecordMatcher({this.map, this.previous, this.additions, this.changes, this.removals});

  Description describeMismatch(changes, Description mismatchDescription, Map matchState,
                               bool verbose) {
    List diffs = matchState['diffs'];
    if (diffs == null) return mismatchDescription;
    return mismatchDescription..add(diffs.join('\n'));
  }

  Description describe(Description description) {
    add(name, map) {
      if (map != null) description.add('$name: ${map.join(', ')}\n   ');
    }

    add('map', map);
    add('previous', previous);
    add('additions', additions);
    add('changes', changes);
    add('removals', removals);
    return description;
  }

  bool matches(MapChangeRecord changeRecord, Map matchState) {
    var diffs = matchState['diffs'] = [];
    return checkMap(changeRecord, diffs) &&
           checkPrevious(changeRecord, diffs) &&
           checkAdditions(changeRecord, diffs) &&
           checkChanges(changeRecord, diffs) &&
           checkRemovals(changeRecord, diffs);
  }

  bool checkMap(MapChangeRecord changeRecord, List diffs) {
    List items = _getList((fn) => changeRecord.forEachItem(fn));
    bool equals = _compareLists("map", map, items, diffs);
    int mapLength = changeRecord.map.length;
    if (mapLength != items.length) {
      diffs.add('map length mismatched: $mapLength != ${items.length}');
      equals = false;
    }
    return equals;
  }

  bool checkPrevious(MapChangeRecord changeRecord, List diffs) {
    List items = _getList((fn) => changeRecord.forEachPreviousItem(fn));
    return _compareLists("previous", previous, items, diffs);
  }

  bool checkAdditions(MapChangeRecord changeRecord, List diffs) {
    List items = _getList((fn) => changeRecord.forEachAddition(fn));
    return _compareLists("additions", additions, items, diffs);
  }

  bool checkChanges(MapChangeRecord changeRecord, List diffs) {
    List items = _getList((fn) => changeRecord.forEachChange(fn));
    return _compareLists("changes", changes, items, diffs);
  }

  bool checkRemovals(MapChangeRecord changeRecord, List diffs) {
    List items = _getList((fn) => changeRecord.forEachRemoval(fn));
    return _compareLists("removals", removals, items, diffs);
  }
}

class _User {
  String first;
  String last;
  num age;
  var isUnderAgeAsVariable;
  List<String> list = ['foo', 'bar', 'baz'];
  Map map = {'foo': 'bar', 'baz': 'cux'};

  _User([this.first, this.last, this.age]) {
    isUnderAgeAsVariable = isUnderAge;
  }

  bool isUnderAge() => age != null ? age < 18 : false;
}

class _FooBar {
  static int fooIds = 0;

  int id;
  String foo, bar;

  _FooBar(this.foo, this.bar) {
    id = fooIds++;
  }

  bool operator==(other) => other is _FooBar && foo == other.foo && bar == other.bar;

  int get hashCode => foo.hashCode ^ bar.hashCode;

  String toString() => '($id)$foo-$bar';
}

class _TestData {
  sub1(a, {b: 0}) => a - b;
  sub2({a: 0, b: 0}) => a - b;
}

class _LoggingFunctionApply extends chd.FunctionApply {
  Logger logger;
  _LoggingFunctionApply(this.logger);
  apply(List args) => logger(args);
}

class _MyClass {
  final Logger logger;
  var valA;
  int _count = 0;

  _MyClass(this.logger);

  dynamic methodA(arg1) {
    logger('methodA($arg1) => $valA');
    return valA;
  }

  int count() => _count++;

  String toString() => 'MyClass';
}


