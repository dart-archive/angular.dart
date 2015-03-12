import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';

@Component(
    selector: '[form-controller]',
    templateUrl: 'form_controller.html',
    useShadowDom: false)
class FormCtrl {
  static const String _COLOR_HEX = "hex";
  static const String _COLOR_HSL = "hsl";
  static const String _COLOR_RGB = "rgb";
  static const String _COLOR_NAME = "name";

  static const _COLOR_TYPES = const [_COLOR_RGB, _COLOR_HSL, _COLOR_HEX, _COLOR_NAME];

  static const _RESOLUTIONS = const ['1024x600',
                                     '1280x800',
                                     '1366x768',
                                     '1440x900',
                                     '1600x900',
                                     '1680x1050',
                                     '1920x1080',
                                     '1920x1200',
                                     '2560x1440',
                                     '2560x1600'];

  Scope scope;
  final List colors = [];
  final List formattedColors = [];
  NgForm myForm;
  NgForm colorForm;
  NgForm colorsForm;
  Map info;
  PreviewCtrl preview;

  FormCtrl() {
    newColor(_COLOR_HEX, '#222');
    newColor(_COLOR_HEX, '#444');
    newColor(_COLOR_HEX, '#000');
    info = new Map();
  }

  List<String> get colorTypes => _COLOR_TYPES;

  List<String> get resolutions => _RESOLUTIONS;

  void submit() {
    myForm.reset();
  }

  int getTotalSquares(inputValue) {
    var value = 4;
    if(inputValue != null) {
      try {
        value = double.parse(inputValue.toString());
      } catch(e) {
      }
    }
    return (value * value).toInt();
  }

  List<String> formatColors() {
    formattedColors.clear();
    colors.forEach((color) {
      var value = null;
      switch(color['type']) {
        case _COLOR_HEX:
          value = color['hex'];
          break;
        case _COLOR_HSL:
          var hue = color['hue'];
          var saturation = color['saturation'];
          var luminance = color['luminance'];
          if(hue != null && saturation != null && luminance != null) {
            value = "hsl($hue, $saturation%, $luminance%)";
          }
          break;
        case _COLOR_RGB:
          var red = color['red'];
          var blue = color['blue'];
          var green = color['green'];
          if(red != null && green != null && blue != null) {
            value = "rgb($red, $green, $blue)";
          }
          break;
        default: //COLOR_NAME
          value = color['name'];
          break;
      }
      if(value != null) {
        formattedColors.add(value);
      }
    });
    return formattedColors;
  }

  void newColor([String type = _COLOR_HEX, String color]) {
    colors.add({
      'id' : colors.length,
      'type' : type,
      'hex' : type == _COLOR_HEX ? color : '',
      'hue' : '',
      'saturation' : '',
      'luminance' : '',
      'red' : '',
      'green' : '',
      'blue': '',
      'name': ''
    });
  }
}

@Decorator(
    selector: '[preview-controller]'
)
class PreviewCtrl {
  PreviewCtrl(FormCtrl form) {
    form.preview = this;
  }

  List _collection = [];

  List expandList(items, limit) {
    _collection.clear();
    if(items != null && items.length > 0) {
      for (var i = 0; i < limit; i++) {
        var x = i % items.length;
        _collection.add(items[x]);
      }
    }
    return _collection;
  }
}

main() {
  applicationFactory()
      ..addModule(new Module()
          ..bind(FormCtrl)
          ..bind(PreviewCtrl))
      ..run();
}
