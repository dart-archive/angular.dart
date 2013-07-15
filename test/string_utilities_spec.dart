import "_specs.dart";

main() {
   describe('snakeCase', (){
    it('should convert to snake_case', () {
      expect(snakeCase('ABC')).toEqual('a_b_c');
      expect(snakeCase('alanBobCharles')).toEqual('alan_bob_charles');
    });


    it('should allow seperator to be overridden', () {
      expect(snakeCase('ABC', '&')).toEqual('a&b&c');
      expect(snakeCase('alanBobCharles', '&')).toEqual('alan&bob&charles');
    });
  });
}
