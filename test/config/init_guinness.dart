import 'package:guinness2/guinness2.dart';

main() {
  _printWarnings();

  guinness.autoInit = false;
  guinness.initSpecs();
}

_printWarnings () {
  final info = guinness.suiteInfo();

  if (info.activeIts.any((it) => it.exclusive)) {
    print("WARN: iit caused some tests to be excluded");
  }

  if (info.exclusiveDescribes.isNotEmpty) {
    print("WARN: ddescribe caused some tests to be excluded");
  }
}

