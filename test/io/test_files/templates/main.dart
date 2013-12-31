library test_files.main;

import 'package:angular/core/module.dart';
import 'package:angular/tools/template_cache_annotation.dart';

@NgComponent(
    selector: 'my-component',
    templateUrl: '/test/io/test_files/templates/main.html'
)
@NgTemplateCache()
class MyComponent {
}

@NgComponent(
    selector: 'my-component2',
    templateUrl: '/test/io/test_files/templates/dont.html'
)
@NgTemplateCache(cache: false)
class MyComponent2 {
}


@NgComponent(
    selector: 'my-component3',
    templateUrl: '/test/io/test_files/templates/dont.html'
)
@NgTemplateCache(cache: true)
class MyComponent3 {
}

@NgTemplateCache(
    preCacheUrls: const ["extra.html"]
)
class Router {
}

@NgTemplateCache(
    preCacheUrls: const ["dont.html"],
    cache: false
)
class Router2 {
}
