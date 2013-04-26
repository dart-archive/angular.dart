import "_specs.dart";

main() {
  describe('jquery', () {
    describe('html', () {
      it('get', (){
        var div = $('<div>');
        expect(div.html()).toEqual('');
      });

      it('set', (){
        var div = $('<div>');
        expect(div.html('text')).toBe(div);
        expect(div.html()).toEqual('text');
      });
    });

  });
}
