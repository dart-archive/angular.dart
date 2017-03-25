library utils_spec;

import '_specs.dart';
import 'package:angular/utils.dart';
import 'dart:collection';

class _LinkedListEntry extends LinkedListEntry {
  String val;
  _LinkedListEntry(this.val);
  String toString() => val;
}

main() {
  describe('relaxFnApply', () {
    it('should work with 6 arguments', () {
      var sixArgs = [1, 1, 2, 3, 5, 8];
      expect(relaxFnApply(() => "none", sixArgs)).toEqual("none");
      expect(relaxFnApply((a) => a, sixArgs)).toEqual(1);
      expect(relaxFnApply((a, b) => a + b, sixArgs)).toEqual(2);
      expect(relaxFnApply((a, b, c) => a + b + c, sixArgs)).toEqual(4);
      expect(relaxFnApply((a, b, c, d) => a + b + c + d, sixArgs)).toEqual(7);
      expect(relaxFnApply((a, b, c, d, e) => a + b + c + d + e, sixArgs)).toEqual(12);
    });

    it('should work with 0 arguments', () {
      var noArgs = [];
      expect(relaxFnApply(() => "none", noArgs)).toEqual("none");
      expect(relaxFnApply(([a]) => a, noArgs)).toEqual(null);
      expect(relaxFnApply(([a, b]) => b, noArgs)).toEqual(null);
      expect(relaxFnApply(([a, b, c]) => c, noArgs)).toEqual(null);
      expect(relaxFnApply(([a, b, c, d]) => d, noArgs)).toEqual(null);
      expect(relaxFnApply(([a, b, c, d, e]) => e, noArgs)).toEqual(null);
    });

    it('should fail with not enough arguments', () {
      expect(() {
        relaxFnApply((required, alsoRequired) => "happy", [1]);
      }).toThrowWith(message: 'Unknown function type, expecting 0 to 5 args.');
    });
  });

  describe('camelCase', () {
    it('should ignore non camelCase', () {
      expect(camelCase('regular')).toEqual('regular');
    });

    it('should convert snake-case', () {
      expect(camelCase('snake-case')).toEqual('snakeCase');
    });

    it('should lowercase strings', () {
      expect(camelCase('Caps-first')).toEqual('capsFirst');
    });

    it('should work on empty string', () {
      expect(camelCase('')).toEqual('');
    });
  });

  vals(list) => list.map((e) => e.val);

  describe("LinkedListEntryGroup", () {
    var a, b, c;

    beforeEach(() {
      a = new _LinkedListEntry("a");
      b = new _LinkedListEntry("b");
      c = new _LinkedListEntry("c");
    });

    describe("unlink", () {
      it("should unlink all the items in the sub list", () {
        final list = new LinkedList()..addAll([a, b, c]);
        final group1 = new LinkedListEntryGroup()..add(a)..add(b);
        final group2 = new LinkedListEntryGroup()..add(c);

        group1.unlink();

        expect(vals(list)).toEqual(["c"]);
      });

      it("should ignore empty sublists", () {
        final sub = new LinkedListEntryGroup();
        expect(() => sub.unlink()).not.toThrow();
      });
    });

    describe("move after", () {
      it("should ignore empty sublists", () {
        final list = new LinkedList()..addAll([a]);
        final group1 = new LinkedListEntryGroup()..add(a);
        final group2 = new LinkedListEntryGroup();

        group2.moveAfter(group1);

        expect(vals(list)).toEqual(["a"]);
      });

      it("should move nodes to the beginning of the list when given null", () {
        final list = new LinkedList()..addAll([a, b, c]);
        final group1 = new LinkedListEntryGroup()..add(a);
        final group2 = new LinkedListEntryGroup()..add(b)..add(c);

        group2.moveAfter(null);

        expect(vals(list)).toEqual(["b", "c", "a"]);
      });

      it("should move nodes to the beginning of the list", () {
        final list = new LinkedList()..addAll([a, b, c]);
        final group1 = new LinkedListEntryGroup()..add(a)..add(b);
        final group2 = new LinkedListEntryGroup()..add(c);

        group1.moveAfter(group2);

        expect(vals(list)).toEqual(["c", "a", "b"]);
      });

      it("should move nodes in the midde of the list", () {
        final list = new LinkedList()..addAll([a, b, c]);
        final group1 = new LinkedListEntryGroup()..add(a);
        final group2 = new LinkedListEntryGroup()..add(b);
        final sub3 = new LinkedListEntryGroup()..add(c);

        group2.moveAfter(sub3);

        expect(vals(list)).toEqual(["a", "c", "b"]);
      });
    });
  });
}