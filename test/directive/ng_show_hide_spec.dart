library ng_show_hide_spec;

import '../_specs.dart';


main() {
  describe('NgHide', () {
    TestBed _;
    beforeEach((TestBed tb) => _ = tb);

    it('should add/remove ng-hide class', () {
      _.compile('<div ng-hide="isHidden"></div>');

      expect(_.rootElement).not.toHaveClass('ng-hide');

      _.rootScope.apply(() {
        _.rootScope.context['isHidden'] = true;
      });
      expect(_.rootElement).toHaveClass('ng-hide');

      _.rootScope.apply(() {
        _.rootScope.context['isHidden'] = false;
      });
      expect(_.rootElement).not.toHaveClass('ng-hide');
    });
  });
  
  describe('NgShow', () {
    TestBed _;
    beforeEach((TestBed tb) => _ = tb);

    it('should add/remove ng-hide class', () {
      _.compile('<div ng-show="isShown"></div>');

      expect(_.rootElement).not.toHaveClass('ng-hide');

      _.rootScope.apply(() {
        _.rootScope.context['isShown'] = true;
      });
      expect(_.rootElement).not.toHaveClass('ng-hide');

      _.rootScope.apply(() {
        _.rootScope.context['isShown'] = false;
      });
      expect(_.rootElement).toHaveClass('ng-hide');
    });
  });
}
