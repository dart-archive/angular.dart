library ng_attribute_spec;

import '../_specs.dart';

main() {
  describe('NgAttribute', () {
    TestBed _;
    beforeEach(inject((TestBed tb) => _ = tb));

    it('should remove the ng-attr- prefix', () {
      _.compile('<div bam="boom" ng-attr-bam="{{5 + 6}}"></div>');
      _.rootScope.$digest();
      expect(_.rootElement.attributes['bam']).toEqual('11');
      expect(_.rootElement.attributes.keys).not.toContain('ng-attr-bam');
    });
  });
}
