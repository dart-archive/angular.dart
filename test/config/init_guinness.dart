import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' as unit;

main() {
  unit.filterStacks = true;
  unit.formatStacks = false;
  guinness.initSpecs();
}
