library ng_model_date_like_spec;

import '../_specs.dart';
import 'dart:html' as dom;

/**
 * Note: some tests become noops for browsers that do not support the particular
 * date-like input being tested.
 */
void main() {
  //----------------------------------------------------------------------------
  // Test fixture
  TestBed _;
  InputElement inputElement;

  //----------------------------------------------------------------------------
  // Utility functions

  /// Wrapper for [valueAsDate] IDL attribute access, necessary due to
  /// https://code.google.com/p/dart/issues/detail?id=17625
  DateTime inputValueAsDateWrapper(InputElement inputElement) {
    try {
      return inputElement.valueAsDate;
    } catch (e) {
      return null;
    }
  }

  DateTime inputValueAsDate() {
    DateTime dt = inputValueAsDateWrapper(inputElement);
    return (dt != null && !dt.isUtc) ? dt.toUtc() : dt;
  }

  bool isBrowser(String pattern) => 
      dom.window.navigator.userAgent.indexOf(pattern) > 0;

  /** Use this function to determine if a non type=text or type=textarea
   * input is supported by the browser under test. If [shouldWorkForChrome]
   * and then browser is Chrome, then `expect()` the input element to be supported.
   */
  bool nonTextInputElementSupported(InputElement input, {bool
      shouldWorkForChrome: true}) {
    const testValue = '!'; // any string that is not valid for the input.
    String savedValue = input.value;
    input.value = testValue;
    if (input.value == testValue) {
      if (shouldWorkForChrome) expect(isBrowser('Chrome')).toBeFalsy();
      return false;
    }
    input.value = savedValue;
    return true;
  }

  //----------------------------------------------------------------------------
  // Tests

  describe('ng-model for date-like input', () {
    beforeEach((TestBed tb) => _ = tb);
    beforeEach(() => inputElement = null);

    describe('type=date', () {
      final DateTime dateTime = new DateTime.utc(2014, 3, 29);
      final String dtAsString = "2014-03-29";

      it('should update input value from DateTime model property', () {
        _.compile('<input type=date ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;
        if (!nonTextInputElementSupported(inputElement)) return; // skip test

        _.rootScope.apply();
        expect(inputValueAsDate()).toBeNull();
        _.rootScope.context['model'] = dateTime;
        _.rootScope.apply();
        expect(inputValueAsDate()).toEqual(dateTime);
      });

      it('should update input value from String model property', () {
        _.compile('<input type=date ng-bind-type=string ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;
        // if(!nonTextInputElementSupported(inputElement)) return; // skip test

        _.rootScope.apply();
        expect(inputElement.value).toEqual('');
        _.rootScope.context['model'] = dtAsString;
        _.rootScope.apply();
        expect(inputElement.value).toEqual(dtAsString);
      });

      it('should update model from the input "valueAsDate" IDL attribute', () {
        _.compile('<input type=date ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;
        if (!nonTextInputElementSupported(inputElement)) return; // skip test

        inputElement.valueAsDate = dateTime;
        _.triggerEvent(inputElement, 'change');
        expect(_.rootScope.context['model']).toEqual(dateTime);
      });

      it('should update model from the input "value" IDL attribute', () {
        _.compile('<input type=date ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;
        if (!nonTextInputElementSupported(inputElement)) return; // skip test

        inputElement.value = dtAsString;
        _.triggerEvent(inputElement, 'change');
        expect(_.rootScope.context['model']).toEqual(dateTime);
      });

      it('should clear input when model is the empty string', () {
        _.compile('<input type=date ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;
        if (!nonTextInputElementSupported(inputElement)) return; // skip test

        _.rootScope.context['model'] = dateTime;
        _.rootScope.apply();
        expect(inputValueAsDate()).toEqual(dateTime);

        _.rootScope.context['model'] = '';
        _.rootScope.apply();
        expect(inputValueAsDate()).toBeNull();
        expect(inputElement.value).toEqual('');
      });

      it('should clear valid input when model is set to null', () {
        _.compile('<input type=date ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;
        if (!nonTextInputElementSupported(inputElement)) return; // skip test

        _.rootScope.context['model'] = dateTime;
        _.rootScope.apply();
        expect(inputValueAsDate()).toEqual(dateTime);

        _.rootScope.context['model'] = null;
        _.rootScope.apply();
        expect(inputValueAsDate()).toBeNull();
        expect(inputElement.value).toEqual('');
      });
    });

    describe('type=time', () {
      final DateTime dateTime = new DateTime.utc(1970, 1, 1, 23, 45, 16);
      final String dtAsString = "23:45:16";

      it('should update input value from DateTime model property', () {
        _.compile('<input type=time ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;
        if (!nonTextInputElementSupported(inputElement)) return; // skip test

        _.rootScope.apply();
        expect(inputValueAsDate()).toBeNull();
        _.rootScope.context['model'] = dateTime;
        _.rootScope.apply();
        expect(inputValueAsDate()).toEqual(dateTime);
      });

      it('should update input value from String model property', () {
        _.compile('<input type=time ng-bind-type=string ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;
        // if(!nonTextInputElementSupported(inputElement)) return; // skip test

        _.rootScope.apply();
        expect(inputElement.value).toEqual('');
        _.rootScope.context['model'] = dtAsString;
        _.rootScope.apply();
        expect(inputElement.value).toEqual(dtAsString);
      });

      it('should update model from the input "valueAsDate" IDL attribute', () {
        _.compile('<input type=time ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;
        if (!nonTextInputElementSupported(inputElement)) return; // skip test

        inputElement.valueAsDate = dateTime;
        _.triggerEvent(inputElement, 'change');
        expect(_.rootScope.context['model']).toEqual(dateTime);
      });

      it('should update model from the input "value" IDL attribute', () {
        _.compile('<input type=time ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;
        if (!nonTextInputElementSupported(inputElement)) return; // skip test

        inputElement.value = dtAsString;
        _.triggerEvent(inputElement, 'change');
        expect(_.rootScope.context['model']).toEqual(dateTime);
      });

      it('should clear input when model is the empty string', () {
        _.compile('<input type=time ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;
        if (!nonTextInputElementSupported(inputElement)) return; // skip test

        _.rootScope.context['model'] = dateTime;
        _.rootScope.apply();
        expect(inputValueAsDate()).toEqual(dateTime);

        _.rootScope.context['model'] = '';
        _.rootScope.apply();
        expect(inputValueAsDate()).toBeNull();
        expect(inputElement.value).toEqual('');
      });

      it('should clear valid input when model is set to null', () {
        _.compile('<input type=time ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;
        if (!nonTextInputElementSupported(inputElement)) return; // skip test

        _.rootScope.context['model'] = dateTime;
        _.rootScope.apply();
        expect(inputValueAsDate()).toEqual(dateTime);

        _.rootScope.context['model'] = null;
        _.rootScope.apply();
        expect(inputValueAsDate()).toBeNull();
        expect(inputElement.value).toEqual('');
      });
    });

    describe('type=datetime-local', () {
      final DateTime dt = new DateTime.utc(2014, 03, 30, 23, 45, 16);
      final num dateTime = dt.millisecondsSinceEpoch;
      final String dtAsString = "2014-03-30T23:45:16";

      it('should update input value from num model', () {
        _.compile('<input type=datetime-local ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;
        if (!nonTextInputElementSupported(inputElement)) return; // skip test

        _.rootScope.apply();
        expect(inputElement.valueAsNumber.isNaN).toBeTruthy();
        _.rootScope.context['model'] = dateTime;
        _.rootScope.apply();
        expect(inputElement.valueAsNumber).toEqual(dateTime);
      });

      it('should update input value from String model property', () {
        _.compile(
            '<input type=datetime-local ng-bind-type=string ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;

        _.rootScope.apply();
        expect(inputElement.value).toEqual('');
        _.rootScope.context['model'] = dtAsString;
        _.rootScope.apply();
        expect(inputElement.value).toEqual(dtAsString);
      });

      it('should update model from the input "valueAsNumber" IDL attribute', ()
          {
        _.compile('<input type=datetime-local ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;
        if (!nonTextInputElementSupported(inputElement)) return; // skip test

        inputElement.valueAsNumber = dateTime;
        expect(inputElement.valueAsNumber).toEqual(dateTime);
        _.triggerEvent(inputElement, 'change');
        expect(_.rootScope.context['model']).toEqual(dateTime);
      });

      it('should update model from the input "value" IDL attribute', () {
        _.compile('<input type=datetime-local ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;
        if (!nonTextInputElementSupported(inputElement)) return; // skip test

        inputElement.value = dtAsString;
        _.triggerEvent(inputElement, 'change');
        expect(_.rootScope.context['model']).toEqual(dateTime);
      });

      it('should clear input when model is the empty string', () {
        _.compile('<input type=datetime-local ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;
        if (!nonTextInputElementSupported(inputElement)) return; // skip test

        _.rootScope.context['model'] = dateTime;
        _.rootScope.apply();
        expect(inputElement.valueAsNumber).toEqual(dateTime);

        _.rootScope.context['model'] = '';
        _.rootScope.apply();
        expect(inputElement.valueAsNumber.isNaN).toBeTruthy();
        expect(inputElement.value).toEqual('');
      });

      it('should clear valid input when model is set to null', () {
        _.compile('<input type=datetime-local ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;
        if (!nonTextInputElementSupported(inputElement)) return; // skip test

        _.rootScope.context['model'] = dateTime;
        _.rootScope.apply();
        expect(inputElement.valueAsNumber).toEqual(dateTime);

        _.rootScope.context['model'] = null;
        _.rootScope.apply();
        expect(inputElement.valueAsNumber.isNaN).toBeTruthy();
        expect(inputElement.value).toEqual('');
      });
    });

    describe('type=datetime', () {
      /*
       * Note: no browser that I know of supports type=datetime other than
       * treating it as an ordinary type=text input. Hence, no tests
       * are added for type=datetime other than accessing its value as a string.
       */
      final DateTime dateTime = new DateTime.utc(2014, 03, 30, 23, 45, 16);
      final String dtAsString = "2014-03-30T23:45:16";

      it('should update input value from String model property', () {
        _.compile('<input type=datetime ng-bind-type=string ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;

        _.rootScope.apply();
        expect(inputElement.value).toEqual('');
        _.rootScope.context['model'] = dtAsString;
        _.rootScope.apply();
        expect(inputElement.value).toEqual(dtAsString);
      });

      it('should update model from the input "value" IDL attribute', () {
        _.compile('<input type=datetime ng-bind-type=string ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;
        if (!nonTextInputElementSupported(inputElement, shouldWorkForChrome:
            false)) return; // skip test

        inputElement.value = dtAsString;
        _.triggerEvent(inputElement, 'change');
        expect(_.rootScope.context['model']).toEqual(dtAsString);
      });
    });

    describe('type=month', () {
      final DateTime dateTime = new DateTime.utc(2014, 3);
      final String dtAsString = "2014-03";

      it('should update input value from DateTime model property', () {
        _.compile('<input type=month ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;
        if (!nonTextInputElementSupported(inputElement)) return; // skip test

        _.rootScope.apply();
        expect(inputValueAsDate()).toBeNull();
        _.rootScope.context['model'] = dateTime;
        _.rootScope.apply();
        expect(inputValueAsDate()).toEqual(dateTime);
      });

      it('should update input value from String model property', () {
        _.compile('<input type=month ng-bind-type=string ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;

        _.rootScope.apply();
        expect(inputElement.value).toEqual('');
        _.rootScope.context['model'] = dtAsString;
        _.rootScope.apply();
        expect(inputElement.value).toEqual(dtAsString);
      });

      it('should update model from the input "valueAsDate" IDL attribute', () {
        _.compile('<input type=month ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;
        if (!nonTextInputElementSupported(inputElement)) return; // skip test

        inputElement.valueAsDate = dateTime;
        _.triggerEvent(inputElement, 'change');
        expect(_.rootScope.context['model']).toEqual(dateTime);
      });

      it('should update model from the input "value" IDL attribute', () {
        _.compile('<input type=month ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;
        if (!nonTextInputElementSupported(inputElement)) return; // skip test

        inputElement.value = dtAsString;
        _.triggerEvent(inputElement, 'change');
        expect(_.rootScope.context['model']).toEqual(dateTime);
      });

      it('should clear input when model is the empty string', () {
        _.compile('<input type=month ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;
        if (!nonTextInputElementSupported(inputElement)) return; // skip test

        _.rootScope.context['model'] = dateTime;
        _.rootScope.apply();
        expect(inputValueAsDate()).toEqual(dateTime);

        _.rootScope.context['model'] = '';
        _.rootScope.apply();
        expect(inputValueAsDate()).toBeNull();
        expect(inputElement.value).toEqual('');
      });

      it('should clear valid input when model is set to null', () {
        _.compile('<input type=month ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;
        if (!nonTextInputElementSupported(inputElement)) return; // skip test

        _.rootScope.context['model'] = dateTime;
        _.rootScope.apply();
        expect(inputValueAsDate()).toEqual(dateTime);

        _.rootScope.context['model'] = null;
        _.rootScope.apply();
        expect(inputValueAsDate()).toBeNull();
        expect(inputElement.value).toEqual('');
      });
    });

    describe('type=week', () {
      final DateTime dateTime = new DateTime.utc(2014, 3, 31);
      final String dtAsString = "2014-W14";

      it('should update input value from DateTime model property', () {
        _.compile('<input type=week ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;
        if (!nonTextInputElementSupported(inputElement)) return; // skip test

        _.rootScope.apply();
        expect(inputValueAsDate()).toBeNull();
        _.rootScope.context['model'] = dateTime;
        _.rootScope.apply();
        expect(inputValueAsDate()).toEqual(dateTime);
      });

      it('should update input value from String model property', () {
        _.compile('<input type=week ng-bind-type=string ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;

        _.rootScope.apply();
        expect(inputElement.value).toEqual('');
        _.rootScope.context['model'] = dtAsString;
        _.rootScope.apply();
        expect(inputElement.value).toEqual(dtAsString);
      });

      it('should update model from the input "valueAsDate" IDL attribute', () {
        _.compile('<input type=week ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;
        if (!nonTextInputElementSupported(inputElement)) return; // skip test

        inputElement.valueAsDate = dateTime;
        _.triggerEvent(inputElement, 'change');
        expect(_.rootScope.context['model']).toEqual(dateTime);
      });

      it('should update model from the input "value" IDL attribute', () {
        _.compile('<input type=week ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;
        if (!nonTextInputElementSupported(inputElement)) return; // skip test

        inputElement.value = dtAsString;
        _.triggerEvent(inputElement, 'change');
        expect(_.rootScope.context['model']).toEqual(dateTime);
      });

      it('should clear input when model is the empty string', () {
        _.compile('<input type=week ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;
        if (!nonTextInputElementSupported(inputElement)) return; // skip test

        _.rootScope.context['model'] = dateTime;
        _.rootScope.apply();
        expect(inputValueAsDate()).toEqual(dateTime);

        _.rootScope.context['model'] = '';
        _.rootScope.apply();
        expect(inputValueAsDate()).toBeNull();
        expect(inputElement.value).toEqual('');
      });

      it('should clear valid input when model is set to null', () {
        _.compile('<input type=week ng-model=model>');
        inputElement = _.rootElement as dom.InputElement;
        if (!nonTextInputElementSupported(inputElement)) return; // skip test

        _.rootScope.context['model'] = dateTime;
        _.rootScope.apply();
        expect(inputValueAsDate()).toEqual(dateTime);

        _.rootScope.context['model'] = null;
        _.rootScope.apply();
        expect(inputValueAsDate()).toBeNull();
        expect(inputElement.value).toEqual('');
      });
    });
  });
}
