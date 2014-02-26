library noop_animation_spec;

import '../_specs.dart';

main() {
  describe('NoAniamte', () {
    it('should not do anything async unless the future is asked for', () {
      var completer = new NoOpAnimation();
      expect(completer).toBeDefined();
    });
    
    it('should create a future once onCompleted is accessed', () {
      expect(() => new NoOpAnimation().onCompleted).toThrow();
    });
    
    it('should return a [COMPLETED_IGNORED] result when completed.', async(() {
      bool success = false;
      new NoOpAnimation().onCompleted.then((result) {
        if(result == AnimationResult.COMPLETED_IGNORED) {
          success = true;
        }
      });
      microLeap();
      expect(success).toBe(true);
    }));
  });
}