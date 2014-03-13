library jasmine_syntax_spec;

import 'jasmine_syntax.dart';
import 'package:unittest/unittest.dart' as unit;

main() {
  describe('jasmine syntax', () {
    describe('beforeEach priority', () {
      var log = [];
      beforeEach(() {
        log.add("first p0");
      });

      beforeEach(() {
        log.add("p0");
      }, priority: 0);

      beforeEach(() {
        log.add("p1");
      }, priority: 1);

      it('should call beforeEach in the correct order', () {
        unit.expect(log.join(';'), unit.equals('p1;first p0;p0'));
      });
    });

    describe('beforeEach priority with nested describes', () {
      var log;
      beforeEach(() {
        log = [];
      }, priority: 2);

      beforeEach(() {
        log.add("p0Outer");
      }, priority: 0);

      beforeEach(() {
        log.add("p1Outer");
      }, priority: 1);

      it('should call beforeEach in the correct order', () {
        unit.expect(log.join(';'), unit.equals('p1Outer;p0Outer'));
      });

      describe('inner', () {
        beforeEach(() {
          log.add("p0Inner");
        }, priority: 0);

        beforeEach(() {
          log.add("p1Inner");
        }, priority: 1);


        it('should call beforeEach in the correct order', () {
          unit.expect(log.join(';'), unit.equals('p1Outer;p1Inner;p0Outer;p0Inner'));
        });
      });


    });
  });
}
