library select_spec;

import 'dart:async';

import '../_specs.dart';
import '../_test_bed.dart';

main() =>
describe('select', () {
  TestBed _;

  beforeEach(beforeEachTestBed((tb) => _ = tb));

  describe('select-one', () {
    it('should compile children of a select without a ngModel, but not create a model for it',
        () {
      _.compile('<select>'
                '<option selected="true">{{a}}</option>'
                '<option value="">{{b}}</option>'
                '<option>C</option>'
                '</select>');
      _.rootScope.$apply(() {
        _.rootScope.a = 'foo';
        _.rootScope.b = 'bar';
      });

      expect(_.rootElement.text()).toEqual('foobarC');
    });

    it('should not interfere with selection via selected attr if ngModel directive is not present',
        () {
      _.compile('<select>'
                '<option>not me</option>'
                '<option selected>me!</option>'
                '<option>nah</option>'
                '</select>');
      _.rootScope.$digest();

      expect(_.rootElement).toEqualSelect(['not me', ['me!'], 'nah']);
    });

    it('should work with repeated value options', () {
      _.compile('<select ng-model="robot" probe="p">'
                '<option ng-repeat="r in robots">{{r}}</option>'
                '</select>');

      _.rootScope.$apply(() {
        _.rootScope.robots = ['c3p0', 'r2d2'];
        _.rootScope.robot = 'r2d2';
      });

      var select = _.rootScope.p.directive(SelectDirective);

      select.updateDom();
      expect(_.rootElement).toEqualSelect(['c3p0', ['r2d2']]);

      _.rootElement.find('option')[0].selected = true;
      select.processValue();

      expect(_.rootElement).toEqualSelect([['c3p0'], 'r2d2']);
      expect(_.rootScope.robot).toEqual('c3p0');

      _.rootScope.$apply(() {
        _.rootScope.robots.insert(0, 'wallee');
      });
      expect(_.rootElement).toEqualSelect(['wallee', ['c3p0'], 'r2d2']);
      expect(_.rootScope.robot).toEqual('c3p0');

      _.rootScope.$apply(() {
        _.rootScope.robots = ['c3p0+', 'r2d2+'];
        _.rootScope.robot = 'r2d2+';
      });
      select.updateDom();
      expect(_.rootElement).toEqualSelect(['c3p0+', ['r2d2+']]);
      expect(_.rootScope.robot).toBe('r2d2+');
    });

    // NOTE: Change in behaviour, null is treated as undefined
    describe('empty option', () {
      it('should select the empty option when model is undefined', () {
        _.compile('<select ng-model="robot">' +
                  '<option value="">--select--</option>' +
                  '<option value="x">robot x</option>' +
                  '<option value="y">robot y</option>' +
                  '</select>');
        _.rootScope.$digest();

        expect(_.rootElement).toEqualSelect([[''], 'x', 'y']);
      });

      it('should support defining an empty option anywhere in the option list', () {
        _.compile('<select ng-model="robot">' +
                  '<option value="x">robot x</option>' +
                  '<option value="">--select--</option>' +
                  '<option value="y">robot y</option>' +
                  '</select>');
        _.rootScope.$digest();

        expect(_.rootElement).toEqualSelect(['x', [''], 'y']);
      });

      it('should set the model to empty string when empty option is selected', () {
        _.rootScope.robot = 'x';
        _.compile('<select ng-model="robot" probe="p">' +
                  '<option value="">--select--</option>' +
                  '<option value="x">robot x</option>' +
                  '<option value="y">robot y</option>' +
                  '</select>');
        _.rootScope.$digest();

        var select = _.rootScope.p.directive(SelectDirective);

        expect(_.rootElement).toEqualSelect(['', ['x'], 'y']);

        _.rootElement.find('option')[0].selected = true;
        select.processValue();

        expect(_.rootElement).toEqualSelect([[''], 'x', 'y']);
        expect(_.rootScope.robot).toEqual('');
      });

      describe('interactions with repeated options', () {
        it('should select empty option when model is undefined', () {
          _.rootScope.robots = ['c3p0', 'r2d2'];
          _.compile('<select ng-model="robot">' +
                    '<option value="">--select--</option>' +
                    '<option ng-repeat="r in robots">{{r}}</option>' +
                    '</select>');
          _.rootScope.$digest();
          expect(_.rootElement).toEqualSelect([[''], 'c3p0', 'r2d2']);
        });

        it('should set model to empty string when selected', () {
          _.rootScope.robots = ['c3p0', 'r2d2'];
          _.compile('<select ng-model="robot" probe="p">' +
                    '<option value="">--select--</option>' +
                    '<option ng-repeat="r in robots">{{r}}</option>' +
                    '</select>');
          _.rootScope.$digest();
          var select = _.rootScope.p.directive(SelectDirective);

          _.rootElement.find('option')[1].selected = true;
          select.processValue();
          expect(_.rootElement).toEqualSelect(['', ['c3p0'], 'r2d2']);
          expect( _.rootScope.robot).toEqual('c3p0');

          _.rootElement.find('option')[0].selected = true;
          select.processValue();
          expect(_.rootElement).toEqualSelect([[''], 'c3p0', 'r2d2']);
          expect( _.rootScope.robot).toEqual('');
        });

        it('should not break if both the select and repeater models change at once', () {
          _.compile('<select ng-model="robot" probe="p">' +
                    '<option value="">--select--</option>' +
                    '<option ng-repeat="r in robots">{{r}}</option>' +
                    '</select>');
          _.rootScope.$apply(() {
            _.rootScope.robots = ['c3p0', 'r2d2'];
            _.rootScope.robot = 'c3p0';
          });

          var select = _.rootScope.p.directive(SelectDirective);
          select.updateDom();

          expect(_.rootElement).toEqualSelect(['', ['c3p0'], 'r2d2']);

          _.rootScope.$apply(() {
            _.rootScope.robots = ['wallee'];
            _.rootScope.robot = '';
          });
          select.updateDom();
          expect(_.rootElement).toEqualSelect([[''], 'wallee']);
        });
      });

      describe('unknown option', () {

        it("should insert&select temporary unknown option when no options-model match", () {
          _.compile('<select ng-model="robot">' +
                    '<option>c3p0</option>' +
                    '<option>r2d2</option>' +
                    '</select>');
          _.rootScope.$digest();
          // NOTE: Change in behaviour
          expect(_.rootElement).toEqualSelect([['?'], 'c3p0', 'r2d2']);

          _.rootScope.$apply(() {
            _.rootScope.robot = 'r2d2';
          });
          expect(_.rootElement).toEqualSelect(['c3p0', ['r2d2']]);


          _.rootScope.$apply(() {
            _.rootScope.robot = "wallee";
          });
          // NOTE: Change in behaviour
          expect(_.rootElement).toEqualSelect([['?'], 'c3p0', 'r2d2']);
        });

        it("should NOT insert temporary unknown option when model is undefined and empty options " +
            "is present", () {
          _.compile('<select ng-model="robot">' +
                    '<option value="">--select--</option>' +
                    '<option>c3p0</option>' +
                    '<option>r2d2</option>' +
                    '</select>');
          _.rootScope.$digest();

          expect(_.rootElement).toEqualSelect([[''], 'c3p0', 'r2d2']);
          expect(_.rootScope.robot).toBeNull();

          _.rootScope.$apply(() {
            _.rootScope.robot = 'wallee';
          });
          // NOTE: Change in behaviour
          expect(_.rootElement).toEqualSelect([['?'], '', 'c3p0', 'r2d2']);

          _.rootScope.$apply(() {
            _.rootScope.robot = 'r2d2';
          });
          expect(_.rootElement).toEqualSelect(['', 'c3p0', ['r2d2']]);

          _.rootScope.$apply(() {
            _.rootScope.robot = null;
          });
          expect(_.rootElement).toEqualSelect([[''], 'c3p0', 'r2d2']);
        });

        it("should insert&select temporary unknown option when no options-model match, empty " +
            "option is present and model is defined", () {
          _.rootScope.robot = 'wallee';
          _.compile('<select ng-model="robot">' +
                    '<option value="">--select--</option>' +
                    '<option>c3p0</option>' +
                    '<option>r2d2</option>' +
                    '</select>');
          _.rootScope.$digest();

          // NOTE: Change in behaviour
          expect(_.rootElement).toEqualSelect([['?'], '', 'c3p0', 'r2d2']);

          _.rootScope.$apply(() {
            _.rootScope.robot = 'r2d2';
          });
          expect(_.rootElement).toEqualSelect(['', 'c3p0', ['r2d2']]);
        });

        describe('interactions with repeated options', () {
          it('should work with repeated options', () {
            _.rootScope.robots = [];
            _.compile('<select ng-model="robot" probe="p">' +
                      '<option ng-repeat="r in robots">{{r}}</option>' +
                      '</select>');
            _.rootScope.$apply(() {
              _.rootScope.robots = [];
            });
            var select = _.rootScope.p.directive(SelectDirective);

            // NOTE: Change in behaviour
            expect(_.rootElement).toEqualSelect([['?']]);
            expect(_.rootScope.robot).toBeNull();

            _.rootScope.$apply(() {
              _.rootScope.robot = 'r2d2';
            });

            // NOTE: Change in behaviour
            expect(_.rootElement).toEqualSelect([['?']]);
            expect(_.rootScope.robot).toEqual('r2d2');

            _.rootScope.$apply(() {
              _.rootScope.robots = ['c3p0', 'r2d2'];
            });
            select.updateDom();
            expect(_.rootElement).toEqualSelect(['c3p0', ['r2d2']]);
            expect(_.rootScope.robot).toEqual('r2d2');
          });

          it('should work with empty option and repeated options', () {
            _.compile('<select ng-model="robot" probe="p">' +
                      '<option value="">--select--</option>' +
                      '<option ng-repeat="r in robots">{{r}}</option>' +
                      '</select>');
            _.rootScope.$apply(() {
              _.rootScope.robots = [];
            });
            var select = _.rootScope.p.directive(SelectDirective);

            expect(_.rootElement).toEqualSelect([['']]);
            expect(_.rootScope.robot).toBeNull();

            _.rootScope.$apply(() {
              _.rootScope.robot = 'r2d2';
            });

            // NOTE: Change in behaviour
            expect(_.rootElement).toEqualSelect([['?'], '']);
            expect(_.rootScope.robot).toEqual('r2d2');

            _.rootScope.$apply(() {
              _.rootScope.robots = ['c3p0', 'r2d2'];
            });
            select.updateDom();
            expect(_.rootElement).toEqualSelect(['', 'c3p0', ['r2d2']]);
            expect(_.rootScope.robot).toEqual('r2d2');
          });

          it('should insert unknown element when repeater shrinks and selected option is unavailable', () {
            _.compile('<select ng-model="robot" probe="p">' +
                      '<option ng-repeat="r in robots">{{r}}</option>' +
                      '</select>');
            _.rootScope.$apply(() {
              _.rootScope.robots = ['c3p0', 'r2d2'];
              _.rootScope.robot = 'r2d2';
            });
            var select = _.rootScope.p.directive(SelectDirective);
            select.updateDom();

            expect(_.rootElement).toEqualSelect(['c3p0', ['r2d2']]);
            expect(_.rootScope.robot).toEqual('r2d2');

            _.rootScope.$apply(() {
              _.rootScope.robots.remove('r2d2');
            });

            select.updateDom();

            // NOTE: Change in behaviour
            expect(_.rootElement).toEqualSelect([['?'], 'c3p0']);
            expect(_.rootScope.robot).toEqual('r2d2');

            _.rootScope.$apply(() {
              _.rootScope.robots.insert(0, 'r2d2');
            });

            select.updateDom();

            expect(_.rootElement).toEqualSelect([['r2d2'], 'c3p0']);
            expect(_.rootScope.robot).toEqual('r2d2');

            _.rootScope.$apply(() {
              _.rootScope.robots.clear();
            });

            select.updateDom();

            // NOTE: Change in behaviour
            expect(_.rootElement).toEqualSelect([['?']]);
            expect(_.rootScope.robot).toEqual('r2d2');
          });
        });
      });
    });
  });

  describe('select-multiple', () {

    it('should support type="select-multiple"', () {
      _.compile('<select ng-model="selection" multiple>' +
                '<option>A</option>' +
                '<option>B</option>' +
                '</select>');

      _.rootScope.$apply(() {
        _.rootScope.selection = ['A'];
      });

      expect(_.rootElement).toEqualSelect([['A'], 'B']);

      _.rootScope.$apply(() {
        _.rootScope.selection.add('B');
      });

      expect(_.rootElement).toEqualSelect([['A'], ['B']]);
    });

    it('should work with optgroups', () {
      _.compile('<select ng-model="selection" multiple>' +
                '<optgroup label="group1">' +
                '<option>A</option>' +
                '<option>B</option>' +
                '</optgroup>' +
                '</select>');

      expect(_.rootElement).toEqualSelect(['A', 'B']);
      expect(_.rootScope.selection).toBeNull();

      _.rootScope.$apply(() {
        _.rootScope.selection = ['A'];
      });
      expect(_.rootElement).toEqualSelect([['A'], 'B']);

      _.rootScope.$apply(() {
        _.rootScope.selection.add('B');
      });
      expect(_.rootElement).toEqualSelect([['A'], ['B']]);
    });

    it('should update model from view', () {
      _.compile('<select ng-model="selection" multiple probe="p">' +
                '<option>A</option>' +
                '<option>B</option>' +
                '</select>');

      var select = _.rootScope.p.directive(SelectDirective);

      _.rootElement.find('option')[0].selected = true;
      select.processValue();
      expect(_.rootScope.selection).toEqual(['A']);

      _.rootElement.find('option')[1].selected = true;
      select.processValue();
      expect(_.rootScope.selection).toEqual(['A', 'B']);

      _.rootElement.find('option')[0].selected = false;
      select.processValue();
      expect(_.rootScope.selection).toEqual(['B']);
    });
  });

  describe('ngOptions', () {
    createSelect(attrs, blank, unknown) {
      var html = '<select probe="p"';
      attrs.forEach((key, value) {
        if (value is bool) {
          if (value) html += ' ' + key;
        } else {
          html += ' ' + key + '="' + value + '"';
        }
      });
      html += '>' +
        (blank != null ? ((blank is String) ? blank : '<option value="">blank</option>') : '') +
        (unknown != null ? ((unknown) is String ? unknown : '<option value="?">unknown</option>') : '') +
      '</select>';

      _.compile(html);
    }

    createSingleSelect([blank, unknown]) {
      createSelect({
        'ng-model':'selected',
        'ng-options':'option.name for option in options'
      }, blank, unknown);
    }

    createMultiSelect([blank, unknown]) {
      createSelect({
        'ng-model':'selected',
        'multiple':true,
        'ng-options':'option.name for option in options'
      }, blank, unknown);
    }

    optionToString(option) =>
        '<${option.tagName} value="${option.value}"${option.selected?' selected':''}>${option.text}</${option.tagName}>';

    it('should throw when not formated "? for ? in ?"', () {
      expect(() {
          _.compile('<select ng-model="selected" ng-options="i dont parse"></select>');
      }).toThrow();
    });

    it('should render a list', () {

      createSingleSelect();
      _.rootScope.$apply(() {
        _.rootScope.options = [{'name': 'A'}, {'name': 'B'}, {'name': 'C'}];
        _.rootScope.selected = _.rootScope.options[0];
      });
      var options = _.rootElement.find('option');
      expect(options.length).toEqual(3);
      expect(optionToString(options[0])).toEqual('<OPTION value="0" selected>A</OPTION>');
      expect(optionToString(options[1])).toEqual('<OPTION value="1">B</OPTION>');
      expect(optionToString(options[2])).toEqual('<OPTION value="2">C</OPTION>');
    });

    it('should render zero as a valid display value', () {
      createSingleSelect();

      _.rootScope.$apply(() {
        _.rootScope.options = [{'name': 0}, {'name': 1}, {'name': 2}];
        _.rootScope.selected = _.rootScope.options[0];
      });

      var options = _.rootElement.find('option');
      expect(options.length).toEqual(3);
      expect(optionToString(options[0])).toEqual('<OPTION value="0" selected>0</OPTION>');
      expect(optionToString(options[1])).toEqual('<OPTION value="1">1</OPTION>');
      expect(optionToString(options[2])).toEqual('<OPTION value="2">2</OPTION>');
    });

    it('should grow list', () {
      createSingleSelect();

      _.rootScope.$apply(() {
        _.rootScope.options = [];
      });

      expect(_.rootElement.find('option').length).toEqual(1); // because we add special empty option
      expect(optionToString(_.rootElement.find('option')[0]))
          .toEqual('<OPTION value="?" selected></OPTION>');

      _.rootScope.$apply(() {
        _.rootScope.options.add({'name':'A'});
        _.rootScope.selected = _.rootScope.options[0];
      });

      expect(_.rootElement.find('option').length).toEqual(1);
      expect(optionToString(_.rootElement.find('option')[0])).toEqual('<OPTION value="0" selected>A</OPTION>');

      _.rootScope.$apply(() {
        _.rootScope.options.add({'name':'B'});
      });

      expect(_.rootElement.find('option').length).toEqual(2);
      expect(optionToString(_.rootElement.find('option')[0])).toEqual('<OPTION value="0" selected>A</OPTION>');
      expect(optionToString(_.rootElement.find('option')[1])).toEqual('<OPTION value="1">B</OPTION>');
    });

    it('should shrink list', () {
      createSingleSelect();

      _.rootScope.$apply(() {
        _.rootScope.options = [{'name':'A'}, {'name':'B'}, {'name':'C'}];
        _.rootScope.selected = _.rootScope.options[0];
      });

      expect(_.rootElement.find('option').length).toEqual(3);

      _.rootScope.$apply(() {
        _.rootScope.options.removeLast();
      });

      expect(_.rootElement.find('option').length).toEqual(2);
      expect(optionToString(_.rootElement.find('option')[0])).toEqual('<OPTION value="0" selected>A</OPTION>');
      expect(optionToString(_.rootElement.find('option')[1])).toEqual('<OPTION value="1">B</OPTION>');

      _.rootScope.$apply(() {
        _.rootScope.options.removeLast();
      });

      expect(_.rootElement.find('option').length).toEqual(1);
      expect(optionToString(_.rootElement.find('option')[0])).toEqual('<OPTION value="0" selected>A</OPTION>');

      _.rootScope.$apply(() {
        _.rootScope.options.removeLast();
        _.rootScope.selected = null;
      });

      expect(_.rootElement.find('option').length).toEqual(1); // we add back the special empty option
      expect(optionToString(_.rootElement.find('option')[0]))
          .toEqual('<OPTION value="?" selected></OPTION>');
    });

    it('should shrink and then grow list', () {
      createSingleSelect();

      _.rootScope.$apply(() {
        _.rootScope.options = [{'name':'A'}, {'name':'B'}, {'name':'C'}];
        _.rootScope.selected = _.rootScope.options[0];
      });

      expect(_.rootElement.find('option').length).toEqual(3);

      _.rootScope.$apply(() {
        _.rootScope.options = [{'name': '1'}, {'name': '2'}];
        _.rootScope.selected = _.rootScope.options[0];
      });

      expect(_.rootElement.find('option').length).toEqual(2);

      _.rootScope.$apply(() {
        _.rootScope.options = [{'name': 'A'}, {'name': 'B'}, {'name': 'C'}];
        _.rootScope.selected = _.rootScope.options[0];
      });

      expect(_.rootElement.find('option').length).toEqual(3);
    });

    it('should update list', () {
      createSingleSelect();

      _.rootScope.$apply(() {
        _.rootScope.options = [{'name': 'A'}, {'name': 'B'}, {'name': 'C'}];
        _.rootScope.selected = _.rootScope.options[0];
      });

      _.rootScope.$apply(() {
        _.rootScope.options = [{'name': 'B'}, {'name': 'C'}, {'name': 'D'}];
        _.rootScope.selected = _.rootScope.options[0];
      });

      var options = _.rootElement.find('option');
      expect(options.length).toEqual(3);
      expect(optionToString(options[0])).toEqual('<OPTION value="0" selected>B</OPTION>');
      expect(optionToString(options[1])).toEqual('<OPTION value="1">C</OPTION>');
      expect(optionToString(options[2])).toEqual('<OPTION value="2">D</OPTION>');
    });

    it('should preserve existing options', () {
      createSingleSelect(true);

      _.rootScope.$apply(() {
        _.rootScope.options = [];
      });

      expect(_.rootElement.find('option').length).toEqual(1);

      _.rootScope.$apply(() {
        _.rootScope.options = [{'name': 'A'}];
        _.rootScope.selected = _.rootScope.options[0];
      });

      expect(_.rootElement.find('option').length).toEqual(2);
      expect(_.rootElement.find('option')[0].text).toEqual('blank');
      expect(_.rootElement.find('option')[1].text).toEqual('A');

      _.rootScope.$apply(() {
        _.rootScope.options = [];
        _.rootScope.selected = null;
      });

      expect(_.rootElement.find('option').length).toEqual(1);
      expect(_.rootElement.find('option')[0].text).toEqual('blank');
    });

    describe('binding', () {

      it('should bind to scope value', () {
        createSingleSelect();

        _.rootScope.$apply(() {
          _.rootScope.options = [{'name': 'A'}, {'name': 'B'}];
          _.rootScope.selected = _.rootScope.options[0];
        });

        expect((_.rootElement.first as SelectElement).value).toEqual('0');

        _.rootScope.$apply(() {
          _.rootScope.selected = _.rootScope.options[1];
        });

        expect((_.rootElement.first as SelectElement).value).toEqual('1');
      });

      it('should insert a blank option if bound to null', () {
        createSingleSelect();

        _.rootScope.$apply(() {
          _.rootScope.options = [{'name': 'A'}];
          _.rootScope.selected = null;
        });

        expect(_.rootElement.find('option').length).toEqual(2);

        expect((_.rootElement.first as SelectElement).value)
            .toEqual('?');
        expect(_.rootElement.find('option')[0].value).toEqual('?');

        _.rootScope.$apply(() {
          _.rootScope.selected = _.rootScope.options[0];
        });

        expect((_.rootElement.first as SelectElement).value).toEqual('0');
        expect(_.rootElement.find('option').length).toEqual(1);
      });

      it('should reuse blank option if bound to null', () {
        createSingleSelect(true);

        _.rootScope.$apply(() {
          _.rootScope.options = [{'name': 'A'}];
          _.rootScope.selected = null;
        });

        expect(_.rootElement.find('option').length).toEqual(2);
        expect((_.rootElement.first as SelectElement).value).toEqual('');
        expect(_.rootElement.find('option')[0].value).toEqual('');

        _.rootScope.$apply(() {
          _.rootScope.selected = _.rootScope.options[0];
        });

        expect((_.rootElement.first as SelectElement).value).toEqual('0');
        expect(_.rootElement.find('option').length).toEqual(2);
      });

      it('should insert a unknown option if bound to something not in the list', () {
        createSingleSelect();

        _.rootScope.$apply(() {
          _.rootScope.options = [{'name': 'A'}];
          _.rootScope.selected = new Object();
        });

        expect(_.rootElement.find('option').length).toEqual(2);
        expect((_.rootElement.first as SelectElement).value).toEqual("?");
        expect(_.rootElement.find('option')[0].value).toEqual("?");

        _.rootScope.$apply(() {
          _.rootScope.selected = _.rootScope.options[0];
        });

        expect((_.rootElement.first as SelectElement).value).toEqual('0');
        expect(_.rootElement.find('option').length).toEqual(1);
      });

      it('should select correct input if previously selected option was "?"', () {
        createSingleSelect();

        _.rootScope.$apply(() {
          _.rootScope.options = [{'name': 'A'}, {'name': 'B'}];
          _.rootScope.selected = new Object();
        });

        var select = _.rootScope.p.directive(SelectDirective);

        expect(_.rootElement.find('option').length).toEqual(3);
        expect((_.rootElement.first as SelectElement).value).toEqual("?");
        expect(_.rootElement.find('option')[0].value).toEqual("?");

        _.rootElement.find('option')[1].selected = true;
        select.processValue();

        expect((_.rootElement.first as SelectElement).value).toEqual('0');
        expect(_.rootElement.find('option')[0].selected).toEqual(true);
        expect(_.rootElement.find('option').length).toEqual(2);
        expect(_.rootScope.selected).toEqual(_.rootScope.options[0]);
      });
    });

    describe('blank option', () {

      it('should be compiled as template, be watched and updated', () {
        createSingleSelect('<option value="">blank is {{blankVal}}</option>');

        _.rootScope.$apply(() {
          _.rootScope.blankVal = 'so blank';
          _.rootScope.options = [{'name': 'A'}];
        });

        // check blank option is first and is compiled
        expect(_.rootElement.find('option').length).toEqual(2);
        var option = _.rootElement.find('option')[0];
        expect(option.value).toEqual('');
        expect(option.text).toEqual('blank is so blank');

        _.rootScope.$apply(() {
          _.rootScope.blankVal = 'not so blank';
        });

        // check blank option is first and is compiled
        expect(_.rootElement.find('option').length).toEqual(2);
        option = _.rootElement.find('option')[0];
        expect(option.value).toEqual('');
        expect(option.text).toEqual('blank is not so blank');
      });

      it('should be rendered with the attributes preserved', () {
        createSingleSelect('<option value="" class="coyote" id="road-runner" ' +
          'custom-attr="custom-attr">{{blankVal}}</option>');

        _.rootScope.$apply(() {
          _.rootScope.blankVal = 'is blank';
        });

        // check blank option is first and is compiled
        var option = _.rootElement.find('option')[0];
        expect(option.classes, contains('coyote'));
        expect(option.id).toEqual('road-runner');
        expect(option.attributes['custom-attr']).toEqual('custom-attr');
      });

      it('should be selected, if it is available and no other option is selected', () {

        createSingleSelect(true);
        _.rootScope.$apply(() {
          _.rootScope.options = [{'name': 'A'}];
        });
        // ensure the first option (the blank option) is selected
        expect((_.rootElement.first as SelectElement).value).toEqual('');
        _.rootScope.$digest();
        // ensure the option has not changed following the digest
        expect((_.rootElement.first as SelectElement).value).toEqual('');
      });
    });

    describe('on change', () {

      it('should update model on change', () {
        createSingleSelect();

        _.rootScope.$apply(() {
          _.rootScope.options = [{'name': 'A'}, {'name': 'B'}];
          _.rootScope.selected = _.rootScope.options[0];
        });

        var select = _.rootScope.p.directive(SelectDirective);

        expect((_.rootElement.first as SelectElement).value).toEqual('0');

        (_.rootElement.first as SelectElement).value = '1';
        select.processValue();
        expect(_.rootScope.selected).toEqual(_.rootScope.options[1]);
      });

      it('should update model to null on change', () {
        createSingleSelect(true);

        _.rootScope.$apply(() {
          _.rootScope.options = [{'name': 'A'}, {'name': 'B'}];
          _.rootScope.selected = _.rootScope.options[0];
        });

        var select = _.rootScope.p.directive(SelectDirective);

        (_.rootElement.first as SelectElement).value = '';
        select.processValue();
        // NOTE: Change in behaviour
        expect(_.rootScope.selected).toEqual('');
      });
    });

    describe('select-many', () {

      it('should read multiple selection', () {
        createMultiSelect();

        _.rootScope.$apply(() {
          _.rootScope.options = [{'name': 'A'}, {'name': 'B'}];
          _.rootScope.selected = [];
        });

        expect(_.rootElement.find('option').length).toEqual(2);
        expect(_.rootElement.find('option')[0].selected).toBeFalsy();
        expect(_.rootElement.find('option')[1].selected).toBeFalsy();

        _.rootScope.$apply(() {
          _.rootScope.selected.add(_.rootScope.options[1]);
        });

        expect(_.rootElement.find('option').length).toEqual(2);
        expect(_.rootElement.find('option')[0].selected).toEqual(false);
        expect(_.rootElement.find('option')[1].selected).toEqual(true);

        _.rootScope.$apply(() {
          _.rootScope.selected.add(_.rootScope.options[0]);
        });

        expect(_.rootElement.find('option').length).toEqual(2);
        expect(_.rootElement.find('option')[0].selected).toEqual(true);
        expect(_.rootElement.find('option')[1].selected).toEqual(true);
      });

      it('should update model on change', () {
        createMultiSelect();

        _.rootScope.$apply(() {
          _.rootScope.options = [{'name': 'A'}, {'name': 'B'}];
          _.rootScope.selected = [];
        });

        var select = _.rootScope.p.directive(SelectDirective);

        _.rootElement.find('option')[0].selected = true;

        select.processValue();
        expect(_.rootScope.selected).toEqual([_.rootScope.options[0]]);
      });

      it('should deselect all options when model is emptied', () {
        createMultiSelect();
        _.rootScope.$apply(() {
          _.rootScope.options = [{'name': 'A'}, {'name': 'B'}];
          _.rootScope.selected = [_.rootScope.options[0]];
        });
        expect(_.rootElement.find('option')[0].selected).toEqual(true);

        _.rootScope.$apply(() {
          _.rootScope.selected.removeLast();
        });

        expect(_.rootElement.find('option')[0].selected).toEqual(false);
      });
    });
  });

  describe('option', () {

    it('should populate value attribute on OPTION', () {
      _.compile('<select ng-model="x"><option selected>abc</option></select>');
      _.rootScope.$digest();
      // NOTE: Change in behaviour
      expect(_.rootElement).toEqualSelect([['?'], 'abc']);
    });

    it('should ignore value if already exists', () {
      _.compile('<select ng-model="x"><option value="abc">xyz</option></select>');
      _.rootScope.$digest();
      // NOTE: Change in behaviour
      expect(_.rootElement).toEqualSelect([['?'], 'abc']);
    });

    it('should set value even if self closing HTML', () {
      _.rootScope.x = 'hello';
      _.compile('<select ng-model="x"><option>hello</select>');
      _.rootScope.$digest();
      expect(_.rootElement).toEqualSelect([['hello']]);
    });

    it('should not blow up when option directive is found inside of a datalist',
        () {
      _.compile('<div>' +
                '<datalist><option>some val</option></datalist>' +
                '<span>{{foo}}</span>' +
                '</div>');
      _.rootScope.$apply(() {
        _.rootScope.foo = 'success';
      });
      expect(_.rootElement.find('span')[0].text).toEqual('success');
    });
  });
});






















