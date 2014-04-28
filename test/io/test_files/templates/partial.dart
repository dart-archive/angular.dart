part of test_files.main;

@Component(
    selector: 'my-component',
    templateUrl: '/test/io/test_files/templates/main.html')
@NgTemplateCache()
class MyComponent
{
}

@Component(
    selector: 'my-component2',
    templateUrl: '/test/io/test_files/templates/dont.html')
@NgTemplateCache(cache: false)
class MyComponent2
{
}


@Component(
    selector: 'my-component3',
    templateUrl: '/test/io/test_files/templates/dont.html')
@NgTemplateCache(cache: true)
class MyComponent3
{
}
