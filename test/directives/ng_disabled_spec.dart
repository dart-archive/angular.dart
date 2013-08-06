import '../_specs.dart';
import "../_test_bed.dart";

main() =>
describe('ng-disabled', () {

  TestBed _;

  beforeEach(beforeEachTestBed((tb) => _ = tb));

  it('should disable/enable the element based on the model', async(inject((Scope scope) {
    var element = _.compile('<button ng-disabled="isDisabled">x</button>');

    scope.$apply(() {
      scope['isDisabled'] = true;
    });
    nextTurn(true);

    expect(element[0].disabled).toBe(true);

    scope.$apply(() {
      scope['isDisabled'] = false;
    });
    nextTurn(true);

    expect(element[0].disabled).toBe(false);
  })));


  it('should accept non boolean values', async(inject((Scope scope) {
    var element = _.compile('<button ng-disabled="isDisabled">x</button>');

    scope.$apply(() {
      scope['isDisabled'] = null;
    });
    nextTurn(true);

    expect(element[0].disabled).toBe(false);

    scope.$apply(() {
      scope['isDisabled'] = 1;
    });
    nextTurn(true);

    expect(element[0].disabled).toBe(true);

    scope.$apply(() {
      scope['isDisabled'] = 0;
    });
    nextTurn(true);

    expect(element[0].disabled).toBe(false);
  })));
});
