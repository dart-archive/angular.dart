import 'package:unittest/unittest.dart' as unit;
import '../jasmine_syntax.dart' as jasmine;

main() {
  unit.filterStacks = true;
  unit.formatStacks = false;
  unit.filterTests((test) {
    if (jasmine.ddescribeActive) {
      String name = test.currentGroup;
      return name.indexOf('DDESCRIBE: ') != -1;
    } else {
      return true;
    }
  });
}
