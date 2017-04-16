import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';
import 'dart:math';

@Controller(
  selector: '[form-controller]',
  publishAs: 'form_ctrl')
class FormCtrl {

  static const String COLOR_HEX = "hex";
  static const String COLOR_HSL = "hsl";
  static const String COLOR_RGB = "rgb";
  static const String COLOR_NAME = "name";

  Scope scope;
  NgForm form;
  List colors = [];
  List lastFormattedColors = [];

  FormCtrl(Scope this.scope, NgForm this.form) {
    newColor(COLOR_HEX, '#222');
    newColor(COLOR_HEX, '#444');
    newColor(COLOR_HEX, '#000');
  }

  get color_types => [COLOR_RGB, COLOR_HSL, COLOR_HEX, COLOR_NAME];
  get resolutions => [
    '1024x600',
    '1280x800',
    '1366x768',
    '1440x900',
    '1600x900',
    '1680x1050',
    '1920x1080',
    '1920x1200',
    '2560x1440',
    '2560x1600'
  ];

  submit() {
    this.form.reset();
  }

  getTotalSquares(value) {
    int defaultValue = 4;
    if(value != null) {
      try {
        value = double.parse(value.toString());
      } catch(e) {
        value = defaultValue;
      }
    } else {
      value = defaultValue;
    }
    return (value * value).toInt();
  }

  formatColors() {
    var formatted = [];
    colors.forEach((color) {
      var value = null;
      switch(color['type']) {
        case COLOR_HEX:
          value = color['hex'];
          break;
        case COLOR_HSL:
          var hue = color['hue'];
          var saturation = color['saturation'];
          var luminance = color['luminance'];
          if(hue != null && saturation != null && luminance != null) {
            value = "hsl($hue, $saturation%, $luminance%)";
          }
          break;
        case COLOR_RGB:
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
        formatted.add(value);
      }
    });
    lastFormattedColors = formatted;
    return formatted;
  }

  newColor([String type = COLOR_HEX, String color]) {
    var data = {
      'id' : colors.length,
      'type' : type,
      'hex' : '',
      'hue' : '',
      'saturation' : '',
      'luminance' : '',
      'red' : '',
      'green' : '',
      'blue': '',
      'name': ''
    };
    if(type == COLOR_HEX) {
      data['hex'] = color;
    }
    colors.add(data);
  }
}

@Controller(
  selector: '[preview-controller]',
  publishAs: 'preview')
class PreviewCtrl {

  static const DEFAULT_COLOR = '#555';

  List _collection = [];

  expandList(items, limit) {
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

class FormModule extends Module {
  FormModule() {
    type(FormCtrl);
    type(PreviewCtrl);
  }
}

main() {
  applicationFactory().addModule(new FormModule()).run();
}
