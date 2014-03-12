part of test_files.main;

@NgComponent(
    selector: 'my-component',
    templateUrl: '/test/io/test_files/templates/main.html')
@NgTemplateCache()
class MyComponent
{
}

@NgComponent(
    selector: 'my-component2',
    templateUrl: '/test/io/test_files/templates/dont.html')
@NgTemplateCache(cache: false)
class MyComponent2
{
}


@NgComponent(
    selector: 'my-component3',
    templateUrl: '/test/io/test_files/templates/dont.html')
@NgTemplateCache(cache: true)
class MyComponent3
{
}
