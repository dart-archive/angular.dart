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
        _.rootScope['a'] = 'foo';
        _.rootScope['b'] = 'bar';
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
        _.rootScope['robots'] = ['c3p0', 'r2d2'];
        _.rootScope['robot'] = 'r2d2';
      });

      var select = _.rootScope['p'].directive(SelectDirective);

      return new Future(() {
        expect(_.rootElement).toEqualSelect(['c3p0', ['r2d2']]);

        _.rootElement.find('option')[0].selected = true;
        select.processValue();

        expect(_.rootElement).toEqualSelect([['c3p0'], 'r2d2']);
        expect(_.rootScope['robot']).toEqual('c3p0');

        _.rootScope.$apply(() {
          _.rootScope['robots'].insert(0, 'wallee');
        });
        expect(_.rootElement).toEqualSelect(['wallee', ['c3p0'], 'r2d2']);
        expect(_.rootScope['robot']).toEqual('c3p0');

        _.rootScope.$apply(() {
          _.rootScope['robots'] = ['c3p0+', 'r2d2+'];
          _.rootScope['robot'] = 'r2d2+';
        });
        return new Future(() {
          expect(_.rootElement).toEqualSelect(['c3p0+', ['r2d2+']]);
          expect(_.rootScope['robot']).toBe('r2d2+');
        });
      });
    });

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
        _.rootScope['robot'] = 'x';
        _.compile('<select ng-model="robot" probe="p">' +
                  '<option value="">--select--</option>' +
                  '<option value="x">robot x</option>' +
                  '<option value="y">robot y</option>' +
                '</select>');
        _.rootScope.$digest();

        var select = _.rootScope['p'].directive(SelectDirective);

        expect(_.rootElement).toEqualSelect(['', ['x'], 'y']);

        _.rootElement.find('option')[0].selected = true;
        select.processValue();

        expect(_.rootElement).toEqualSelect([[''], 'x', 'y']);
        expect(_.rootScope['robot']).toEqual('');
      });

      describe('interactions with repeated options', () {
        it('should select empty option when model is undefined', () {
          _.rootScope['robots'] = ['c3p0', 'r2d2'];
          _.compile('<select ng-model="robot">' +
                    '<option value="">--select--</option>' +
                    '<option ng-repeat="r in robots">{{r}}</option>' +
                  '</select>');
          _.rootScope.$digest();
          expect(_.rootElement).toEqualSelect([[''], 'c3p0', 'r2d2']);
        });

        it('should set model to empty string when selected', () {
          _.rootScope['robots'] = ['c3p0', 'r2d2'];
          _.compile('<select ng-model="robot" probe="p">' +
                    '<option value="">--select--</option>' +
                    '<option ng-repeat="r in robots">{{r}}</option>' +
                  '</select>');
          _.rootScope.$digest();
          var select = _.rootScope['p'].directive(SelectDirective);

          _.rootElement.find('option')[1].selected = true;
          select.processValue();
          expect(_.rootElement).toEqualSelect(['', ['c3p0'], 'r2d2']);
          expect( _.rootScope['robot']).toEqual('c3p0');

          _.rootElement.find('option')[0].selected = true;
          select.processValue();
          expect(_.rootElement).toEqualSelect([[''], 'c3p0', 'r2d2']);
          expect( _.rootScope['robot']).toEqual('');
        });

        it('should not break if both the select and repeater models change at once', () {
          _.compile('<select ng-model="robot">' +
                    '<option value="">--select--</option>' +
                    '<option ng-repeat="r in robots">{{r}}</option>' +
                  '</select>');
          _.rootScope.$apply(() {
            _.rootScope['robots'] = ['c3p0', 'r2d2'];
            _.rootScope['robot'] = 'c3p0';
          });

          return new Future(() {
            expect(_.rootElement).toEqualSelect(['', ['c3p0'], 'r2d2']);

            _.rootScope.$apply(() {
              _.rootScope['robots'] = ['wallee'];
              _.rootScope['robot'] = '';
            });

            expect(_.rootElement).toEqualSelect([[''], 'wallee']);
          });
        });
      });

      describe('unknown option', () {

        it("should insert&select temporary unknown option when no options-model match", () {
          _.compile('<select ng-model="robot">' +
              '<option>c3p0</option>' +
              '<option>r2d2</option>' +
          '</select>');
          _.rootScope.$digest();
          expect(_.rootElement).toEqualSelect([['? Null:null ?'], 'c3p0', 'r2d2']);

          _.rootScope.$apply(() {
            _.rootScope['robot'] = 'r2d2';
          });
          expect(_.rootElement).toEqualSelect(['c3p0', ['r2d2']]);


          _.rootScope.$apply(() {
            _.rootScope['robot'] = "wallee";
          });
          expect(_.rootElement).toEqualSelect([['? String:wallee ?'], 'c3p0', 'r2d2']);
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
          expect(_.rootScope['robot']).toBeNull();

          _.rootScope.$apply(() {
            _.rootScope['robot'] = 'wallee';
          });
          expect(_.rootElement).toEqualSelect([['? String:wallee ?'], '', 'c3p0', 'r2d2']);

          _.rootScope.$apply(() {
            _.rootScope['robot'] = 'r2d2';
          });
          expect(_.rootElement).toEqualSelect(['', 'c3p0', ['r2d2']]);

          _.rootScope.$apply(() {
            _.rootScope['robot'] = null;
          });
          expect(_.rootElement).toEqualSelect([[''], 'c3p0', 'r2d2']);
        });

        it("should insert&select temporary unknown option when no options-model match, empty " +
            "option is present and model is defined", () {
          _.rootScope['robot'] = 'wallee';
          _.compile('<select ng-model="robot">' +
              '<option value="">--select--</option>' +
              '<option>c3p0</option>' +
              '<option>r2d2</option>' +
          '</select>');
          _.rootScope.$digest();

          expect(_.rootElement).toEqualSelect([['? String:wallee ?'], '', 'c3p0', 'r2d2']);

          _.rootScope.$apply(() {
            _.rootScope['robot'] = 'r2d2';
          });
          expect(_.rootElement).toEqualSelect(['', 'c3p0', ['r2d2']]);
        });

        describe('interactions with repeated options', () {
          it('should work with repeated options', () {
            _.rootScope['robots'] = [];
            _.compile('<select ng-model="robot">' +
                '<option ng-repeat="r in robots">{{r}}</option>' +
            '</select>');
            _.rootScope.$apply(() {
              _.rootScope['robots'] = [];
            });

            expect(_.rootElement).toEqualSelect([['? Null:null ?']]);
            expect(_.rootScope['robot']).toBeNull();

            _.rootScope.$apply(() {
              _.rootScope['robot'] = 'r2d2';
            });
            expect(_.rootElement).toEqualSelect([['? String:r2d2 ?']]);
            expect(_.rootScope['robot']).toEqual('r2d2');

            _.rootScope.$apply(() {
              _.rootScope['robots'] = ['c3p0', 'r2d2'];
            });
            return new Future(() {
              expect(_.rootElement).toEqualSelect(['c3p0', ['r2d2']]);
              expect(_.rootScope['robot']).toEqual('r2d2');
            });
          });

          it('should work with empty option and repeated options', () {
            _.compile('<select ng-model="robot">' +
                '<option value="">--select--</option>' +
                '<option ng-repeat="r in robots">{{r}}</option>' +
            '</select>');
            _.rootScope.$apply(() {
              _.rootScope['robots'] = [];
            });

            expect(_.rootElement).toEqualSelect([['']]);
            expect(_.rootScope['robot']).toBeNull();

            _.rootScope.$apply(() {
              _.rootScope['robot'] = 'r2d2';
            });
            expect(_.rootElement).toEqualSelect([['? String:r2d2 ?'], '']);
            expect(_.rootScope['robot']).toEqual('r2d2');

            _.rootScope.$apply(() {
              _.rootScope['robots'] = ['c3p0', 'r2d2'];
            });
            return new Future(() {
              expect(_.rootElement).toEqualSelect(['', 'c3p0', ['r2d2']]);
              expect(_.rootScope['robot']).toEqual('r2d2');
            });
          });

          it('should insert unknown element when repeater shrinks and selected option is unavailable',
              () {

            _.compile('<select ng-model="robot">' +
                '<option ng-repeat="r in robots">{{r}}</option>' +
            '</select>');
            _.rootScope.$apply(() {
              _.rootScope['robots'] = ['c3p0', 'r2d2'];
              _.rootScope['robot'] = 'r2d2';
            });
            return new Future(() {
              expect(_.rootElement).toEqualSelect(['c3p0', ['r2d2']]);
              expect(_.rootScope['robot']).toEqual('r2d2');

              _.rootScope.$apply(() {
                _.rootScope['robots'].remove('r2d2');
              });
              return new Future(() {
                expect(_.rootElement).toEqualSelect([['? String:r2d2 ?'], 'c3p0']);
                expect(_.rootScope['robot']).toEqual('r2d2');

                _.rootScope.$apply(() {
                  _.rootScope['robots'].insert(0, 'r2d2');
                });
                return new Future(() {
                  expect(_.rootElement).toEqualSelect([['r2d2'], 'c3p0']);
                  expect(_.rootScope['robot']).toEqual('r2d2');

                  _.rootScope.$apply(() {
                    _.rootScope['robots'].clear();
                  });
                  return new Future(() {
                    expect(_.rootElement).toEqualSelect([['? String:r2d2 ?']]);
                    expect(_.rootScope['robot']).toEqual('r2d2');
                  });
                });
              });
            });
          });
        });
      });
    });
  });
});