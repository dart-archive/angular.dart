library ng_show_spec;

import '../_specs.dart';
import '../_test_bed.dart';
import 'dart:html' as dom;

main() {
  describe('NgShow', () {
    TestBed _;

    beforeEach(beforeEachTestBed((tb) => _ = tb));

    it('should add/remove ng-show class', () {
      var element = _.compile('<div ng-show="isVisible"></div>');

      expect(element).not.toHaveClass('ng-show');

      _.rootScope.$apply(() {
        _.rootScope['isVisible'] = true;
      });
      expect(element).toHaveClass('ng-show');

      _.rootScope.$apply(() {
        _.rootScope['isVisible'] = false;
      });
      expect(element).not.toHaveClass('ng-show');
    });

    it('should work together with ng-class', () {
      var element = _.compile('<div ng-class="currentCls" ng-show="isVisible"></div>');

      expect(element).not.toHaveClass('active');
      expect(element).not.toHaveClass('ng-show');

      _.rootScope.$apply(() {
        _.rootScope['currentCls'] = 'active';
      });
      expect(element).toHaveClass('active');
      expect(element).not.toHaveClass('ng-show');

      _.rootScope.$apply(() {
        _.rootScope['isVisible'] = true;
      });
      expect(element).toHaveClass('active');
      expect(element).toHaveClass('ng-show');
    });
  });
}
