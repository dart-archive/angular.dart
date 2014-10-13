import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';

import 'dart:html';
import 'dart:js';

/**
 * A component with a simple template which the Javascript Google Maps API
 * will use to install a map inside the ShadowRoot.
 */
@Component(
  selector: 'x-google-map',
  template: '<div style="height: 300px; width: 300px"></div>'
)
class XGoogleMaps implements ShadowRootAware {
  var map, infowindow;

  onShadowRoot(root) {
    // From https://code.google.com/p/dart/source/browse/branches/bleeding_edge/dart/samples/google_maps/web/index.dart
    final gmaps = context['google']['maps'];
    var london = new JsObject(gmaps['LatLng'], [51.5, 0.125]);
    var mapOptions = new JsObject.jsify({
        "center": london,
        "zoom": 8,
    });

    map = new JsObject(gmaps['Map'], [root.querySelector('div'), mapOptions]);

    // The <content> tag is the exciting part of this component.  Instead
    // of passing a string of HTML to the component, we use Shadow DOM to
    // punch a hole into the Shadow DOM allowing consumers to use parts of
    // their 'light DOM'
    infowindow = new JsObject(gmaps['InfoWindow'], [new JsObject.jsify({
      "content": "<div style='height: 2em; width: 10em'><content></content></div>",
      "position": london
    })]);
  }

  @NgOneWay('info')
  set infoWindow(value) {
    if (value) {
      infowindow.callMethod('open', [map]);
    } else {
      infowindow.callMethod('close');
    }
  }
}

main() {
  var module = new Module()..bind(XGoogleMaps);

  var injector = applicationFactory()
      .addModule(module)
      .run();
}
