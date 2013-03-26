import 'package:unittest/unittest.dart';
import 'jasmineSyntax.dart';

main() {
  describe('hello World', () {
    it("should compare hello strings", () {
      expect("hello", equals("hello"));
    });
  });
}


