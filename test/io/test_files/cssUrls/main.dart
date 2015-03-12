library test_files.main;

import 'package:angular/core/annotation_src.dart';

@Component(
    selector: 'my-component',
    cssUrl: '/test/io/test_files/cssUrls/one.css')
class MyComponent
{
}

@Component(
    selector: 'my-component2',
    cssUrl: const [
        '/test/io/test_files/cssUrls/two.css',
        '/test/io/test_files/cssUrls/three.css'])
class MyComponent2
{
}

@Component(
    selector: 'my-component3',
    cssUrl: '/test/io/test_files/cssUrls/four.css')
class MyComponent3
{
}
