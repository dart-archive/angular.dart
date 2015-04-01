library context_locals_spec;

import '../_specs.dart';
import 'package:angular/change_detection/watch_group.dart';

class RootContext {
  String a, b, c;
  RootContext(this.a, this.b, this.c);
}

void main() {
  describe('Context Locals', () {
    RootContext rootCtx;
    beforeEach(() {
      rootCtx = new RootContext('#a', '#b', '#c');
    });

    it('should allow retrieving the parent context', () {
      var localCtx = new ContextLocals(rootCtx);
      expect(localCtx.parentContext).toBe(rootCtx);
    });

    it('should allow testing for supported locals', () {
      var localCtx = new ContextLocals(rootCtx, {'foo': 'bar'});
      expect(localCtx.hasProperty('foo')).toBeTruthy();
      expect(localCtx.hasProperty('far')).toBeFalsy();
      expect(localCtx['foo']).toBe('bar');
    });

    it('should not allow modifying the root context', () {
      var localCtx = new ContextLocals(rootCtx, {'a': '@a'});
      expect(localCtx['a']).toBe('@a');
      localCtx['a'] = '@foo';
      expect(localCtx['a']).toBe('@foo');
      expect(rootCtx.a).toBe('#a');
    });

    it('should write to the local context', () {
      var localCtx = new ContextLocals(rootCtx, {'a': 0});
      var childCtx = new ContextLocals(localCtx);
      expect(childCtx.hasProperty('a')).toBeFalsy();
      childCtx['a'] = '@a';
      childCtx['b'] = '@b';
      expect(localCtx['a']).toBe(0);
      expect(childCtx['a']).toBe('@a');
      expect(childCtx['b']).toBe('@b');
      expect(localCtx.hasProperty('b')).toBeFalsy();
    });
  });
}
