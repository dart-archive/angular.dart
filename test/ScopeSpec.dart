import '_specs.dart';

main() {
  describe('scope', () {
    var scope;

    beforeEach(() => scope = new Scope());

    describe(r'$watch/$digest', () {
      it('should watch and fire on simple property change', () {
      // TODO deboer: spys?
        var timesRun = 0;
        var lastValue;

        scope.$watch('name', (v) { timesRun++; lastValue = v; });
        expect(timesRun).toEqual(0);
        scope.$digest();

        expect(timesRun).toEqual(1);
        scope['name'] = 'james';
        scope.$digest();
        expect(timesRun).toEqual(2);
        expect(lastValue).toEqual('james');
      });

      it('should watch and run a function', () {
        var timesRun = 0;
        var passedValue;

        scope.$watch((x) { timesRun++; passedValue = x;});
        expect(timesRun).toEqual(0);
        scope.$digest();

        expect(timesRun).toEqual(1);
        expect(passedValue).toEqual(scope);
      });
    });


    describe('getter/setter methods emulation', () {
      it('should intercepm noSuchMethod getter/setters', () {
        scope.a = 123;
        expect(scope.a).toEqual(123);

        expect(scope['a']).toEqual(123);

        scope['a'] = 456;
        expect(scope.a).toEqual(456);
      });

      it('should return null', () {
        expect(scope.iDontExist).toEqual(null);
      });
    });
  });
}
