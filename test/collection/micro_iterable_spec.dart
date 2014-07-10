library micro_iterable_spec;

import '../_specs.dart';
import 'package:angular/collection/micro_iterable.dart';

void main() {
  describe('MicroIterable', () {
    MicroIterable iterable;

    beforeEach(() {
      iterable = new MicroIterable(1,2,3,4,5,6,7,8,null, null, null, null, null, null, null, null, null, null, null, null, 8);
    });

    it('should have length', () {
      expect(iterable.length).toBe(8);
    });
  });
}