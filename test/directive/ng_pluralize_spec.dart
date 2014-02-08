library ng_pluralize_spec;

import '../_specs.dart';

main() {
  describe('PluralizeDirective', () {

    describe('deal with pluralized strings without offset', () {
      var element;
      var elementAlt;
      var elt;
      TestBed _;

      beforeEach(inject((TestBed tb) {
        _ = tb;

        element = _.compile(
            '<ng-pluralize count="email"' +
                "when=\"{'-1': 'You have negative email. Whohoo!'," +
                "'0': 'You have no new email'," +
                "'one': 'You have one new email'," +
                "'other': 'You have {} new emails'}\">" +
            '</ng-pluralize>'
        );

        elementAlt = _.compile(
            '<p ng-pluralize count="email" ' +
                "when-minus-1='You have negative email. Whohoo!' " +
                "when-0='You have no new email' " +
                "when-one='You have one new email' " +
                "when-other='You have {} new emails'>" +
            '</p>'
        );
      }));

      it('should show single/plural strings', () {
        _.rootScope.email = '0';
        _.rootScope.$digest();
        expect(element.text).toEqual('You have no new email');
        expect(elementAlt.text).toEqual('You have no new email');

        _.rootScope.email = '0';
        _.rootScope.$digest();
        expect(element.text).toEqual('You have no new email');
        expect(elementAlt.text).toEqual('You have no new email');

        _.rootScope.email = 1;
        _.rootScope.$digest();
        expect(element.text).toEqual('You have one new email');
        expect(elementAlt.text).toEqual('You have one new email');

        _.rootScope.email = 0.01;
        _.rootScope.$digest();
        expect(element.text).toEqual('You have 0.01 new emails');
        expect(elementAlt.text).toEqual('You have 0.01 new emails');

        _.rootScope.email = '0.1';
        _.rootScope.$digest();
        expect(element.text).toEqual('You have 0.1 new emails');
        expect(elementAlt.text).toEqual('You have 0.1 new emails');

        _.rootScope.email = 2;
        _.rootScope.$digest();
        expect(element.text).toEqual('You have 2 new emails');
        expect(elementAlt.text).toEqual('You have 2 new emails');

        _.rootScope.email = -0.1;
        _.rootScope.$digest();
        expect(element.text).toEqual('You have -0.1 new emails');
        expect(elementAlt.text).toEqual('You have -0.1 new emails');

        _.rootScope.email = '-0.01';
        _.rootScope.$digest();
        expect(element.text).toEqual('You have -0.01 new emails');
        expect(elementAlt.text).toEqual('You have -0.01 new emails');

        _.rootScope.email = -2;
        _.rootScope.$digest();
        expect(element.text).toEqual('You have -2 new emails');
        expect(elementAlt.text).toEqual('You have -2 new emails');

        _.rootScope.email = -1;
        _.rootScope.$digest();
        expect(element.text).toEqual('You have negative email. Whohoo!');
        expect(elementAlt.text).toEqual('You have negative email. Whohoo!');
      });

      it('should show single/plural strings with mal-formed inputs', () {
        _.rootScope.email = '';
        _.rootScope.$digest();
        expect(element.text).toEqual('');
        expect(elementAlt.text).toEqual('');

        _.rootScope.email = null;
        _.rootScope.$digest();
        expect(element.text).toEqual('');
        expect(elementAlt.text).toEqual('');

        _.rootScope.email = 'a3';
        _.rootScope.$digest();
        expect(element.text).toEqual('');
        expect(elementAlt.text).toEqual('');

        _.rootScope.email = '011';
        _.rootScope.$digest();
        expect(element.text).toEqual('You have 11 new emails');
        expect(elementAlt.text).toEqual('You have 11 new emails');

        _.rootScope.email = '-011';
        _.rootScope.$digest();
        expect(element.text).toEqual('You have -11 new emails');
        expect(elementAlt.text).toEqual('You have -11 new emails');

        _.rootScope.email = '1fff';
        _.rootScope.$digest();
        expect(element.text).toEqual('');
        expect(elementAlt.text).toEqual('');

        _.rootScope.email = '0aa22';
        _.rootScope.$digest();
        expect(element.text).toEqual('');
        expect(elementAlt.text).toEqual('');

        _.rootScope.email = '000001';
        _.rootScope.$digest();
        expect(element.text).toEqual('You have one new email');
        expect(elementAlt.text).toEqual('You have one new email');
      });
    });

    describe('edge cases', () {
      it('should be able to handle empty strings as possible values', (inject((TestBed _) {
        var element = _.compile(
            '<ng-pluralize count="email"' +
                "when=\"{'0': ''," +
                "'one': 'Some text'," +
                "'other': 'Some text'}\">" +
            '</ng-pluralize>');
        _.rootScope.email = '0';
        _.rootScope.$digest();
        expect(element.text).toEqual('');
      })));
    });

    describe('deal with pluralized strings with offset', () {
      it('should show single/plural strings with offset', (inject((TestBed _) {
        var element = _.compile(
            "<ng-pluralize count='viewCount'  offset='2' " +
                "when=\"{'0': 'Nobody is viewing.'," +
                "'1': '{{p1}} is viewing.'," +
                "'2': '{{p1}} and {{p2}} are viewing.'," +
                "'one': '{{p1}}, {{p2}} and one other person are viewing.'," +
                "'other': '{{p1}}, {{p2}} and {} other people are viewing.'}\">" +
            "</ng-pluralize>");
        var elementAlt = _.compile(
            "<ng-pluralize count='viewCount'  offset='2' " +
                "when-0='Nobody is viewing.'" +
                "when-1='{{p1}} is viewing.'" +
                "when-2='{{p1}} and {{p2}} are viewing.'" +
                "when-one='{{p1}}, {{p2}} and one other person are viewing.'" +
                "when-other='{{p1}}, {{p2}} and {} other people are viewing.'>" +
            "</ng-pluralize>");
        _.rootScope.p1 = 'Igor';
        _.rootScope.p2 = 'Misko';

        _.rootScope.viewCount = 0;
        _.rootScope.$digest();
        expect(element.text).toEqual('Nobody is viewing.');
        expect(elementAlt.text).toEqual('Nobody is viewing.');

        _.rootScope.viewCount = 1;
        _.rootScope.$digest();
        expect(element.text).toEqual('Igor is viewing.');
        expect(elementAlt.text).toEqual('Igor is viewing.');

        _.rootScope.viewCount = 2;
        _.rootScope.$digest();
        expect(element.text).toEqual('Igor and Misko are viewing.');
        expect(elementAlt.text).toEqual('Igor and Misko are viewing.');

        _.rootScope.viewCount = 3;
        _.rootScope.$digest();
        expect(element.text).toEqual('Igor, Misko and one other person are viewing.');
        expect(elementAlt.text).toEqual('Igor, Misko and one other person are viewing.');

        _.rootScope.viewCount = 4;
        _.rootScope.$digest();
        expect(element.text).toEqual('Igor, Misko and 2 other people are viewing.');
        expect(elementAlt.text).toEqual('Igor, Misko and 2 other people are viewing.');
      })));
    });
  });
}
