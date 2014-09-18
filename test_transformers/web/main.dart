library angular.test_transformers.relative_uris;

import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';


import 'relative_uris/foo2/relative_foo.dart';

class RelativeUriTestModule extends Module {
  RelativeUriTestModule() {
    bind(RelativeFooComponent);
    bind(ResourceResolverConfig, toValue: new ResourceResolverConfig.resolveRelativeUrls(true));
  }
}
main() {
  applicationFactory()
      .addModule(new RelativeUriTestModule())
      .run();
}
