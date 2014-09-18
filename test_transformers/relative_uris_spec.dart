library angular.test_transformers.relative_uris_spec;

import 'package:protractor/protractor_api.dart';

main() {
  describe('relative-uri rewriting in static application', () {
    it('should rewrite a relative uri', () {
      var ptor = protractor.getInstance().get('index.html');
      var test_div = element(by.id('test_div'));
      expect(test_div.isPresent()).toEqual(true);
      expect(test_div.getText()).toEqual('Why hello there, Relative Foo...');
    });
  });
}
