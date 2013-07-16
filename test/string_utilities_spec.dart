import "_specs.dart";

main() {
   describe('snake_case', (){
    it('should convert to snake_case', () {
      expect(snake_case('ABC')).toEqual('a_b_c');
      expect(snake_case('alanBobCharles')).toEqual('alan_bob_charles');
    });
  });
}
