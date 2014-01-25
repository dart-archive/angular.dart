library ng.tool.template_cache_generator_spec;

import 'package:angular/angular.dart';
import 'package:angular/mock/module.dart';
import '../jasmine_syntax.dart';
import 'package:unittest/unittest.dart';

// Generated file. Run ../../test_tc_gen.sh.
import 'generated.dart' as gen;

main() {
  describe('template_cache_generator', () {
    TemplateCache cache;

    beforeEach(inject((TemplateCache tc) => cache = tc));

    it('should correctly generate the templates cache file', () {
      gen.primeTemplateCache(cache);

      HttpResponse response = cache.get("rewritten/templates/main.html");
      expect(response != null, true);
      expect(response.status, 200);
      expect(response.data, r"""Hello World!""");

      response = cache.get("extra.html");
      expect(response != null, true);
      expect(response.status, 200);
      expect(response.data, r"""More Cached Goodness!""");

      response = cache.get("package/test_lib/asset/lib.html");
      expect(response != null, true);
      expect(response.status, 200);
      expect(response.data, r"""Library Cached Goodness!""");

      response = cache.get("rewritten/templates/dont.html");
      expect(response, null);
    });
  });
}
