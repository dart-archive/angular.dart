library pending_async_spec;

import '../_specs.dart';

void main() {
  describe('pending_async', () {
    PendingAsync pendingAsync;
    Logger log;
    callbackLog(msg) => () { log(msg); };

    beforeEachModule((Module module) {
      module.bind(ExceptionHandler, toValue: new LoggingExceptionHandler());
    });

    beforeEach((Logger _log) {
      log = _log;
      pendingAsync = new PendingAsync();
    });

    it('should start with a pending count of 0', () {
      expect(pendingAsync.numPending).toEqual(0);
    });

    it('should increase and return new pending count', () {
      expect(pendingAsync.increaseCount(1)).toEqual(1);
      expect(pendingAsync.increaseCount(1)).toEqual(2);
      expect(pendingAsync.increaseCount(2)).toEqual(4);
    });

    it('should decrease and return new pending count', () {
      pendingAsync.increaseCount(3);
      expect(pendingAsync.increaseCount(-2)).toEqual(1);
      expect(pendingAsync.decreaseCount(1)).toEqual(0);
      expect(() => pendingAsync.decreaseCount(1)).toThrow();
      pendingAsync.increaseCount(3);
      expect(() => pendingAsync.decreaseCount(4)).toThrow();
    });

    describe('whenStable', () {
      it('should fire callbacks when in initial stable state', async(() {
        expect(pendingAsync.numPending).toEqual(0);
        pendingAsync.whenStable(callbackLog('cb 1'));
        expect(log.result()).toEqual('cb 1');
      }));

      it('should NOT fire callbacks when there are pending operations', async(() {
        pendingAsync.increaseCount(2);
        pendingAsync.whenStable(callbackLog('cb 2'));
        expect(log.result()).toEqual('');
        pendingAsync.decreaseCount(1);
        expect(log.result()).toEqual('');
      }));

      it('should complete the future when there no pending operations left', async(() {
        pendingAsync.increaseCount(2);
        pendingAsync.whenStable(callbackLog('cb 3'));
        expect(log.result()).toEqual('');
        pendingAsync.decreaseCount(2);
        expect(log.result()).toEqual('cb 3');
      }));

      it('should complete the future if already completed and still in a stable state', async(() {
        pendingAsync.increaseCount(1);
        pendingAsync.whenStable(callbackLog('cb 4'));
        pendingAsync.decreaseCount(1);
        expect(log.result()).toEqual('cb 4');
        pendingAsync.whenStable(callbackLog('cb 5'));
        expect(log.result()).toEqual('cb 4; cb 5');
      }));
    });

  });
}
