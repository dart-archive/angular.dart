library ng_show_hide_spec;

import '../_specs.dart';
import 'dart:html' as dom;


main() {
  describe('NgHide', () {
    TestBed _;
    beforeEach(beforeEachTestBed((tb) => _ = tb));

    it('should add/remove ng-hide class', () {
      _.compile('<div ng-hide="isHidden"></div>');

      expect(_.rootElement).not.toHaveClass('ng-hide');

      _.rootScope.$apply(() {
        _.rootScope['isHidden'] = true;
      });
      expect(_.rootElement).toHaveClass('ng-hide');

      _.rootScope.$apply(() {
        _.rootScope['isHidden'] = false;
      });
      expect(_.rootElement).not.toHaveClass('ng-hide');
    });
  });
}
