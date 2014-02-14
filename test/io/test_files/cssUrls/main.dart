library test_files.main;

import 'package:angular/core/module.dart';

@NgComponent(
    selector: 'my-component',
    cssUrl: '/test/io/test_files/cssUrls/one.css')
class MyComponent
{
}

@NgComponent(
    selector: 'my-component2',
    cssUrl: const [
        '/test/io/test_files/cssUrls/two.css',
        '/test/io/test_files/cssUrls/three.css'])
class MyComponent2
{
}

@NgComponent(
    selector: 'my-component3',
    cssUrl: '/test/io/test_files/cssUrls/four.css')
class MyComponent3
{
}
