import 'package:protractor/protractor_api.dart';

main() {
  describe('hello_world example', () {
    var nameByModel, nameByBinding;

    beforeEach(() {
      protractor.getInstance().get('hello_world.html');
      nameByModel = element(by.model('name'));
      nameByBinding = element(by.binding('name'));
    });

    it('should set initial value for input element', () {
      expect(nameByModel.getAttribute('value')).toEqual('world');
    });

    it('should set mustache value to initial value of model', () {
      nameByBinding = element(by.binding('name'));
      expect(nameByBinding.getText()).toEqual('Hello world!');
    });

  });
}
