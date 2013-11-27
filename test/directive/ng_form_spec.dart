library form_spec;

import '../_specs.dart';

main() =>
describe('form', () {
  TestBed _;

  beforeEach(inject((TestBed tb) => _ = tb));

  it('should suppress the submission event if no action is provided within the form', inject((Scope scope) {
    var element = $('<form name="myForm"></form>');

    _.compile(element);
    scope.$apply();

    Event submissionEvent = new Event.eventType('CustomEvent', 'submit');

    expect(submissionEvent.defaultPrevented).toBe(false);
    element[0].dispatchEvent(submissionEvent);
    expect(submissionEvent.defaultPrevented).toBe(true);

    Event fakeEvent = new Event.eventType('CustomEvent', 'running');

    expect(fakeEvent.defaultPrevented).toBe(false);
    element[0].dispatchEvent(submissionEvent);
    expect(fakeEvent.defaultPrevented).toBe(false);
  }));

  it('should not prevent the submission event if an action is defined', inject((Scope scope) {
    var element = $('<form name="myForm" action="..."></form>');

    _.compile(element);
    scope.$apply();

    Event submissionEvent = new Event.eventType('CustomEvent', 'submit');

    expect(submissionEvent.defaultPrevented).toBe(false);
    element[0].dispatchEvent(submissionEvent);
    expect(submissionEvent.defaultPrevented).toBe(false);
  }));

  it('should execute the ng-submit expression if provided upon form submission', inject((Scope scope) {
    var element = $('<form name="myForm" ng-submit="submitted = true"></form>');

    _.compile(element);
    scope.$apply();

    _.rootScope.submitted = false;

    Event submissionEvent = new Event.eventType('CustomEvent', 'submit');
    element[0].dispatchEvent(submissionEvent);

    expect(_.rootScope.submitted).toBe(true);
  }));
});
