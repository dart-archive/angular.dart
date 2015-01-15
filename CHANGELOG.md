<a name="v1.1"></a>
# v1.1.0 isomorphic-panda (2015-01-15)

## Highlights

This is a primarily bug fix release. Angular.dart's dependencies have been
updated to their newest versions. A number of fixes went into the shadow-dom polyfill
and forms. Support for Observable objects in change detection has been improved.

## Bug Fixes

- **RootScope:** set the scope on ScopeAware root context
  ([99a2d372](https://github.com/angular/angular.dart/commit/99a2d372b53adf62a4ceed0b044bfbf0ffb5c230))
- **benchmark:** Platform.Android -> Platform.isAndroid
  ([ee5ebd75](https://github.com/angular/angular.dart/commit/ee5ebd75a222018950abf7973b3b6c25216a0059))
- **bouncing balls:** fix broken demo
  ([3eac327e](https://github.com/angular/angular.dart/commit/3eac327e1e9b0580a69fea1a67be0cd72f646310))
- **compiler:** change compiler to support attribute mapping for template decorators
  ([d658909a](https://github.com/angular/angular.dart/commit/d658909afdcedaf58c5ef480faf533f436364bbf),
   [#1581](https://github.com/angular/angular.dart/issues/1581))
- **css_shim:** allow "..." for content
  ([9a369e3d](https://github.com/angular/angular.dart/commit/9a369e3dd78f2b936877312f91a95d2e78772abb))
- **ngModel:** ensure post-reset validation works properly
  ([6bf7eaab](https://github.com/angular/angular.dart/commit/6bf7eaabd27d024252f916aa320445bf8997edaf),
   [#1605](https://github.com/angular/angular.dart/issues/1605))
- **source_metadata_extractor:** Fixed problem with processing Component and Decorator annotations when named import is used.
  ([5205c142](https://github.com/angular/angular.dart/commit/5205c142a2b7414db970bfb9ab0504d76d24a5e3))
- **url_resolver:** changes _baseUri to support non http schemes.
  ([d9291093](https://github.com/angular/angular.dart/commit/d929109333fe2370f5156df2204177ce37aa5bc0))
- **view:** change ViewPort to remove the view that got inserted in the same VM turn
  ([4933a5e8](https://github.com/angular/angular.dart/commit/4933a5e838edeffde5f026121fefbda1c7954148))


## Features

- **css_shim:** implement polyfill-unscoped-next-selector and polyfill-non-strict
  ([a3ff5cfb](https://github.com/angular/angular.dart/commit/a3ff5cfb49116da533cadd1bcae9f122c53fa8db))
- **dccd:** Observable support
  ([3827f424](https://github.com/angular/angular.dart/commit/3827f4240366e161534a6a693cb822f5caa447b2))
- **ng-repeat:** set the "$parent" variable to the parent context
  ([9da6d2ef](https://github.com/angular/angular.dart/commit/9da6d2efa36b0560f4fa78f4cb2c5d0a430c1f6d))
- **ngControl:** provide support for clearing errors states
  ([6a6e4caf](https://github.com/angular/angular.dart/commit/6a6e4cafefe988ec18d29d3584ae3fd0c4a47ce1))
- **ngForm:** allow forms to be manually validated
  ([7a103901](https://github.com/angular/angular.dart/commit/7a1039016bf9bcf5b0b654cee346c4b2792e85c7))
- **routing:** upgraded route_hierachical to 0.6.0 and added support for watchQueryParameters
  ([0fbd007e](https://github.com/angular/angular.dart/commit/0fbd007e0910fe421a9dc8b84da2ea92b2c7b768))


## Breaking Changes

None

<a name="v1.0"></a>
# v1.0 industrious-pangolin (2014-10-10)
## Highlights

Angular.Dart v1.0 is our first production-ready release.

This release contains a bit of everything: new features, performance improvements
and bug fixes. Angular expressions now evaluate in the context of the
surrounding component instead of the current scope. This reduces the boilerplate
component authors need to write; no more 'ctrl' prefixes in your templates.

In the same vein, the templateUrl and cssUrls in Component annotations take
paths relative to the library defining the Component.  The contents of the
template likewise use relative paths.  You no longer to to specify the full
paths to your templates, CSS and resources. Absolute paths are left unchanged.

The new touch module adds support for swipe left and swipe right.  Change
detection now understands Observable objects (through dart:observe). A number
of small changes enable more seamless integration with web-components. Finally,
instantiating components is nearly 40% faster.

The new PendingAsync module allows you to be notified when all background
asynchronous operations known to Angular (XHR, timers, microtasks, etc.) are
complete.  The Testability API exposes this in the JavsScript API for use
by Protractor E2E tests.

## Bug Fixes

- **Component:** Remove deprecated applyAuthorStyles & resetStyleInheritance
  ([059b76e7](https://github.com/angular/angular.dart/commit/059b76e71766329549542d3f84b5d9e5a0b2adc5),
   [#1345](https://github.com/angular/angular.dart/issues/1345))
- **DirectiveInjector:** fix exceptions
  ([87fcd1eb](https://github.com/angular/angular.dart/commit/87fcd1ebbe57c66c6e74cad7ba595cac2617949c),
   [#1484](https://github.com/angular/angular.dart/issues/1484))
- **WTFramework:** add back traceDetectWTF call in application start
  ([de824080](https://github.com/angular/angular.dart/commit/de824080b00531d1df6aafa26a287a1d3ab05254))
- **animate:** Remove a reference to dart:mirrors
  ([9a60bcb6](https://github.com/angular/angular.dart/commit/9a60bcb614786dae15145d65ec81ee03bbdc4a12))
- **application:** set injector property when bootstraping the app
  ([bf5d15a7](https://github.com/angular/angular.dart/commit/bf5d15a74c76c316e41c63e8a4e53cc55d2dbf0b),
   [#1391](https://github.com/angular/angular.dart/issues/1391))
- **benchmark:** update benchmark to work with new context.
  ([22a50a75](https://github.com/angular/angular.dart/commit/22a50a757936250f11558817c4671f71cf440de8))
- **bind-*:** zone.run scope.apply on bind- change events
  ([77fdc617](https://github.com/angular/angular.dart/commit/77fdc617aa8b4686686256537802240d1803b7bf))
- **compiler:** Support camelCase property bindings
  ([4cb23914](https://github.com/angular/angular.dart/commit/4cb23914ab1e77ad75e3f219a989bd569785bc5a),
   [#1460](https://github.com/angular/angular.dart/issues/1460), [#1462](https://github.com/angular/angular.dart/issues/1462))
- **components:**
  - do not reinsert nodes during redistribution if they have not changed
  ([013f18d4](https://github.com/angular/angular.dart/commit/013f18d4dcfc6d42422512a8aa7c902b41400fbe))
  - TranscludingComponentFactory passes a wrong element to onShadowRoot
  ([2c87e84f](https://github.com/angular/angular.dart/commit/2c87e84f880fdc5e7fdc127b59311e84be590636),
   [#1435](https://github.com/angular/angular.dart/issues/1435), [#1436](https://github.com/angular/angular.dart/issues/1436))
  - the content tag duplicates elements
  ([ff46fb7b](https://github.com/angular/angular.dart/commit/ff46fb7b3354d9d7e6ec4cd71e57c5d2464159b7),
   [#1422](https://github.com/angular/angular.dart/issues/1422))
- **directive-injector:** wrong variable name in error thrown.
  ([c533eb55](https://github.com/angular/angular.dart/commit/c533eb558cf65765ee77fe3bd99f9d26039ad2fa),
   [#1397](https://github.com/angular/angular.dart/issues/1397))
- **form example:**
  - watched collections can not be mutated
  ([d39e62a3](https://github.com/angular/angular.dart/commit/d39e62a33c7553ffaa5d62e1a843058a85edf068))
  - type() has been replaced by bind()
  ([e5584e16](https://github.com/angular/angular.dart/commit/e5584e16855700b61281a7f80cc8697c47268211))
- **introspection:** fix ngProbe with introspected bindings and findElements returning only elements
  ([3ea2b10e](https://github.com/angular/angular.dart/commit/3ea2b10e828643edafcf5c63d7b5986e757f9984))
- **metadata_extractor:** Do not try to guess the selector
  ([28f9ee48](https://github.com/angular/angular.dart/commit/28f9ee48a204c251f45f0d6a6dae6eaeecf5a665))
- **mock:** Fix unitialized variable in MockWindow.
  ([862f46c3](https://github.com/angular/angular.dart/commit/862f46c3e80267c29e3d41447ce9d6d623b5ad44))
- **perf_api:** updgrade the pkg minimum version to fix an analyzer error
  ([09d3c830](https://github.com/angular/angular.dart/commit/09d3c830961dfda57ab5bcf434563711724e679d),
   [#1408](https://github.com/angular/angular.dart/issues/1408))
- **resource_url_resolver:**
  - IE/Safari compatible HTML parsing
  ([ecb7db27](https://github.com/angular/angular.dart/commit/ecb7db27f27b0acf52044b841f42fabe6d809bfb))
  - correct type for Node
  ([a760ec19](https://github.com/angular/angular.dart/commit/a760ec19ef7d6ea5fb829fa44972dfccf8e9fe12))
  - fix DOM parsing for Safari
  ([50025832](https://github.com/angular/angular.dart/commit/50025832947a2121e999c68fdc81dccb5ef0cf9e),
   [#1439](https://github.com/angular/angular.dart/issues/1439))
- **scope:** fix a potential memory leak
  ([97410f7d](https://github.com/angular/angular.dart/commit/97410f7d4bc12d429c146f19add40df9fe0cca86))
- **shadow_boundary:** change ShadowBoundary not to reorder styles when prepending them
  ([81bab3ea](https://github.com/angular/angular.dart/commit/81bab3ea35383fc0f7abd1804e3cc9a7c5a3b0ec))
- **source_metadata_extractor:** Extract config from controllers
  ([a981feb2](https://github.com/angular/angular.dart/commit/a981feb2df849fbe5aa30c4d1a60ca329287571b))
- **test:** remove at trailing "," in JS object literal
  ([e6387cff](https://github.com/angular/angular.dart/commit/e6387cff067371b79761553a7c8ae32cd155ac74))
- **travis:** BUILD_LEADER is not available in build.sh
  ([0720c3c5](https://github.com/angular/angular.dart/commit/0720c3c58442d5733df6c82faa2b2b39cc7dca91),
   [#1362](https://github.com/angular/angular.dart/issues/1362), [#1393](https://github.com/angular/angular.dart/issues/1393))
- **web components:** Fix tests in IE10
  ([43b6f4f0](https://github.com/angular/angular.dart/commit/43b6f4f069f938146a998dabbe8385efb5adbbe2),
   [#1372](https://github.com/angular/angular.dart/issues/1372))
- **core:** remove analyze warnings
  ([298f0fed](https://github.com/angular/angular.dart/commit/298f0fed0bcdd1208dfe708cfd7def923b9347da))


## Features

- **Touch:**
  - New touch module including ng-swipe-left/ng-swipe-right directives
  ([5d84c6db](https://github.com/angular/angular.dart/commit/5d84c6db655b4f553f419d5fe449b4f9e19008d4))
- **TestBed:** add whitespace handling to compile
  ([5f5ce353](https://github.com/angular/angular.dart/commit/5f5ce353d04b77da2018c59a0a98c89205d15dca),
   [#1262](https://github.com/angular/angular.dart/issues/1262), [#1346](https://github.com/angular/angular.dart/issues/1346), [#1445](https://github.com/angular/angular.dart/issues/1445))
- **compiler:**
  - support ScopeAware for decorators
  ([943d6193](https://github.com/angular/angular.dart/commit/943d61936c2d9296dd31838d4dfb014f5292b9ae))
- **components:**
  - change shadow boundary to ignore duplicate styles
  ([5b04b17b](https://github.com/angular/angular.dart/commit/5b04b17b526097a33ba13bd8d84f832f605ec4a0))
  - implement css encapsulation for transcluding components
  ([18843e1c](https://github.com/angular/angular.dart/commit/18843e1ca9e69f274e7d6e2bf0c37b217e770973))
  - add support for multiple insertion points for transcluding components
  ([0d5c99e8](https://github.com/angular/angular.dart/commit/0d5c99e8324bb29d12e651b1cc1e69de6db08310),
   [#1290](https://github.com/angular/angular.dart/issues/1290))
- **core, testability:** PendingAsync service
  ([1d29b79c](https://github.com/angular/angular.dart/commit/1d29b79ca2369336bcba91dae48a8cf963cd621e))
- **dccd:** add Support for ObservableList, ObservableMap & ChangeNotifier
  ([85eceef5](https://github.com/angular/angular.dart/commit/85eceef5afad1d220d125b97277b3dc32be88f11),
   [#773](https://github.com/angular/angular.dart/issues/773), [#1156](https://github.com/angular/angular.dart/issues/1156))
- **directive-injector:**
  - Assert that the injector has been initialized
  ([060eb550](https://github.com/angular/angular.dart/commit/060eb550f17f1ddb27ccf22c450329a90effff13))
  - DiCircularDependencyError -> _CircularDependencyError
  ([9f46fb95](https://github.com/angular/angular.dart/commit/9f46fb95e7bc6e56f5c7b839a6a26992169ade00),
   [#1399](https://github.com/angular/angular.dart/issues/1399))
  - detect and throw on circular deps
  ([0b0080b4](https://github.com/angular/angular.dart/commit/0b0080b445f5d0f58cc05e13b416e9956be076b2),
   [#1364](https://github.com/angular/angular.dart/issues/1364))
  - component directive injector injects parent
  ([3af94348](https://github.com/angular/angular.dart/commit/3af94348c56813fda667ccfcd68275bcea6e9edf),
   [#1351](https://github.com/angular/angular.dart/issues/1351))
- **directives:** remove the @Controller directive
  ([5f8e2765](https://github.com/angular/angular.dart/commit/5f8e27659ffb0140e0c153f8cecd627df273bfd2),
   [#1401](https://github.com/angular/angular.dart/issues/1401))
- **eventHandler:** Support snake-case event names instead of camelCase.
  ([fd54c304](https://github.com/angular/angular.dart/commit/fd54c304c2ac533ea7128e5abebd00593abf8c7e),
   [#1434](https://github.com/angular/angular.dart/issues/1434), [#1478](https://github.com/angular/angular.dart/issues/1478), [#1477](https://github.com/angular/angular.dart/issues/1477))
- **examples:** Add a compelling Shadow DOM example
  ([028b2373](https://github.com/angular/angular.dart/commit/028b23730ef993d93045c04eebd908dea7aa68ed),
   [#1377](https://github.com/angular/angular.dart/issues/1377))
- **mocks:** change MockHttpBackend to define the assertion on flush.
  ([635f9d0c](https://github.com/angular/angular.dart/commit/635f9d0cf2ac9f50e9190047bde080d468d7cfe8),
   [#900](https://github.com/angular/angular.dart/issues/900))
- **scope:**
  - component is the new context
  ([a4f08a79](https://github.com/angular/angular.dart/commit/a4f08a798df7525132ec7b0e18c4c6a8091480e8))
  - add new createProtoChild method
  ([caac098f](https://github.com/angular/angular.dart/commit/caac098f2d109622b05251c340e981bd8e58e562))
  - move domWrite and domRead from RootScope to Scope
  ([c18a8f33](https://github.com/angular/angular.dart/commit/c18a8f33f355996f9d63a77c7af3f9559bc898f8),
   [#1161](https://github.com/angular/angular.dart/issues/1161), [#1341](https://github.com/angular/angular.dart/issues/1341))
- **tests:** run tests on all browsers
  ([8c1f79a4](https://github.com/angular/angular.dart/commit/8c1f79a42d2411373cddbb2ff89b20434bf99add))
- **travis:** Also check for dart2js sizes that are unexpectedly small
  ([e90fa606](https://github.com/angular/angular.dart/commit/e90fa606358a106ecba23657702d25b05c7c80d2),
   [#1427](https://github.com/angular/angular.dart/issues/1427))
- **urls:** support relative CSS / template URLs in components
  ([50e26453](https://github.com/angular/angular.dart/commit/50e26453efc79d2db3a335112b37d13c5b0becbb))
- **web components:** Support custom events for element property binding
  ([94c35225](https://github.com/angular/angular.dart/commit/94c3522512ba7089a524fce0f7fd8bdedffe3f88),
   [#1449](https://github.com/angular/angular.dart/issues/1449), [#1453](https://github.com/angular/angular.dart/issues/1453))


## Performance Improvements

- **component:** add a benchmark that measures component creation with and without css files
  ([29f39470](https://github.com/angular/angular.dart/commit/29f394703afb58bf342a072fd901c85583060c80),
   [#1421](https://github.com/angular/angular.dart/issues/1421))
- **util:** call toLowerCase() only where needed
  ([2bcd29e7](https://github.com/angular/angular.dart/commit/2bcd29e7b284ed3a32c0698a6820ca161ea8f99f),
   [#1468](https://github.com/angular/angular.dart/issues/1468))
- **view:** increase view instantiation speed 40%
  ([00960bb9](https://github.com/angular/angular.dart/commit/00960bb95f298640a46a8e58a42f68396e776ead),
   [#1358](https://github.com/angular/angular.dart/issues/1358))
- **view_factory:** add a benchmark that measures view_factory in isolation
  ([abbe4efb](https://github.com/angular/angular.dart/commit/abbe4efbb80546df0a615591f44e8fafabd29f89),
   [#1384](https://github.com/angular/angular.dart/issues/1384))


## Breaking Changes

- **mocks:** due to [635f9d0c](https://github.com/angular/angular.dart/commit/635f9d0cf2ac9f50e9190047bde080d468d7cfe8), 
Unexpected requests are detected only when `flush` is called.

Before:

		backend("GET", /some"); //throws here if `/some` has not been defined

After:

		backend("GET", /some"); //no problem, just records the request
		backend.flush(); //throws here

Closes #900
- **scope:** due to [a4f08a79](https://github.com/angular/angular.dart/commit/a4f08a798df7525132ec7b0e18c4c6a8091480e8),
 

Scope context is set to the component instance that trigged the creation
of the scope (previously it was of a PrototypeMap.)

Repercussions:
1) You can not inject a scope in a component or in the root context any
more.

As the Scope context is set to the Component instance, the scope could
not be injected any more. Components should implements the "ScopeAware"
interface and declare a "scope" setter in order to get a reference to
the scope.

before:

     @Component(...)
     class MyComponent {
       Watch watch;
       Scope scope;

       MyComponent(Dependency myDep, Scope scope) {
          watch = scope.rootScope.watch("expression", (v, p) => ...);
       }
     }

after:

     @Component(...)
     class MyComponent implements ScopeAware {
       Watch watch;

       MyComponent(Dependency myDep) {
         // It is an error to add a Scope argument to the
         // ctor and will result in a DI circular dependency error
         // The scope is never accessible in the class constructor
       }

       void set scope(Scope scope) {
          // This setter gets called to initialize the scope
          watch = scope.watch("expression", (v, p) => ...);
       }
     }

or:

     @Component(...)
     class MyComponent implements ScopeAware {
       Scope scope;

       MyComponent(Dependency myDep) {
         // It is an error to add a Scope argument to the
         // ctor and will result in a DI circular dependency error
         // The scope is never accessible in the class constructor
       }
     }

2) The parent component to an NgForm must have a "$name" field to store
   the form instance.

closes #919
closes #917
- **urls:** due to [50e26453](https://github.com/angular/angular.dart/commit/50e26453efc79d2db3a335112b37d13c5b0becbb),
 

You must update relative paths to your templates and in ng-include's to
be relative to the component's library / ng-include'd file.

NOTE: This feature is defaulted to an "on" state.  To get back the old
behavior, you may disable this feature for your application.  This is
only to help you adjust to this change and will go away in a later
version.  Here's how you can get the old behavior:

```dart
module.bind(ResourceResolverConfig, toValue:
	new ResourceResolverConfig.useRelativeUrls(false));
```

*Testing*:
- e2e transformer tests can now be done on the sample application found
  in the test_transformers folder


<a name="v0.14.0"></a>
# v0.14.0 symbiotic-meerkat (2014-08-22)

## Highlights

This release is focused on supporting Polymer web components inside Angular
components, using the new on-* and bind-* syntax. Take a look at
[example/web/paper.html](
https://github.com/angular/angular.dart/blob/master/example/web/paper.html) for
some [material
design](http://www.google.com/design/spec/material-design/introduction.html)
examples.
                                                                                     
Also, we have added instrumentation for [Web Tracing Framework]
(http://google.github.io/tracing-framework/), so that you can visualize
codepaths in your live apps (only browser plug-in required).
                 
At last we did plenty of bug fixing and performance improvements for an even
smoother developer experience.


## Bug Fixes

- **HttpConfig:** Remove the optional argument to the default ctor
  ([a84c0b87](https://github.com/angular/angular.dart/commit/a84c0b8780ac03eeb7579e8416c76096e625cee2),
   [#1285](https://github.com/angular/angular.dart/issues/1285))
- **NgRepeat:** remove duplicated call to _updateContext()
  ([15570eea](https://github.com/angular/angular.dart/commit/15570eead275f572b3b6dc63620fdb19c3ebb81f))
- **benchmark:** Remove obsolete DI call
  ([4068e242](https://github.com/angular/angular.dart/commit/4068e242877353603658cc31192194bb46413263))
- **directive-injector:** breaking changes and fixes
  ([600113a8](https://github.com/angular/angular.dart/commit/600113a8e6bc1aff08f00513eb1b794ca28e54ee),
   [#1111](https://github.com/angular/angular.dart/issues/1111))
- **dom_util:** loosen typing of nodes list
  ([f393a96d](https://github.com/angular/angular.dart/commit/f393a96deaf0c4c144ee8b1bc54efe0fb6af4abc),
   [#1359](https://github.com/angular/angular.dart/issues/1359))
- **example:** cleanup imports for ShadowDOM example
  ([721eebab](https://github.com/angular/angular.dart/commit/721eebabc657534932b845929fd41aea61bcf253),
   [#1323](https://github.com/angular/angular.dart/issues/1323))
- **html_extractor:** correct handling of camelCased attributes
  ([7e7c934b](https://github.com/angular/angular.dart/commit/7e7c934b52a944d22e473dd4597b71cbb419462a),
   [#1301](https://github.com/angular/angular.dart/issues/1301))
- **http:** always initialize final coalesceDuration
  ([e5cf3784](https://github.com/angular/angular.dart/commit/e5cf37848984315b6af9b0819f53360b6f2d21f2))
- **mock:** Timer.isActive should be false after running callback
  ([75d40649](https://github.com/angular/angular.dart/commit/75d40649bd632bcc4724584bfadefc61e07dcb20))
- **scope:** increase default ScopeDigestTTL to 10 iterations
  ([5ff38bd5](https://github.com/angular/angular.dart/commit/5ff38bd5812077f28a09d916b1e1f0a2d6fc65ae))
- **web components:** Support Polymer quirks
  ([879772fa](https://github.com/angular/angular.dart/commit/879772fa28983a88d77a9624dceb5af6ce3dca98),
   [#1292](https://github.com/angular/angular.dart/issues/1292))
- **web_platform:** include selector in viewFactoryCache key
  ([aa5abed2](https://github.com/angular/angular.dart/commit/aa5abed2613758dccd63d95fe2bf8b5094d3f753))
- **transformer:** Don't share resolvers between parallel transformers as this will cause a deadlock
  ([dba6727b](https://github.com/angular/angular.dart/commit/dba6727b90cd6dc0dbf8257061482e88b05939b9),
   [#1276](https://github.com/angular/angular.dart/issues/1276), [#1382](https://github.com/angular/angular.dart/issues/1382))

## Features

- **Context:** Add ability to set the Type for the rootScope context
  ([6a6a7feb](https://github.com/angular/angular.dart/commit/6a6a7febd47e55f3d1dc9d4345d8bee61d6e924d))
- **DirectiveInjector:** add a toInstanceOf parameter to bind()
  ([f8bbd35f](https://github.com/angular/angular.dart/commit/f8bbd35ffdfd21005be118e45ddc8d3dd6a265ce))
- **OrderBy:**
  - allow specifying an Iterable expression
  ([a300adfc](https://github.com/angular/angular.dart/commit/a300adfccbc42d5a33c714d6d34a3798fc72f116),
   [#1329](https://github.com/angular/angular.dart/issues/1329))
  - allow ordering an Iterable
  ([5cd74823](https://github.com/angular/angular.dart/commit/5cd74823aa6493b5b86cef4383366d94f154b412))
- **ScopeAware:** introduce ScopeAware abstract class
  ([181f0144](https://github.com/angular/angular.dart/commit/181f01448555c475869505491159045904e5dc89),
   [#1360](https://github.com/angular/angular.dart/issues/1360))
- **WTF:** Add support for WTF
  ([23639c13](https://github.com/angular/angular.dart/commit/23639c138e1929931720619fef1e64b2fd6d92c7),
   [#1354](https://github.com/angular/angular.dart/issues/1354))
- **directive-injector:** introduce getFromParent[byKey] methods on DirectiveInjector
  ([3b7b0d65](https://github.com/angular/angular.dart/commit/3b7b0d653831e3a150dc48947965c0848442e1e4))
- **element binder:**
  - Two way binding for Web Components
  ([4633451f](https://github.com/angular/angular.dart/commit/4633451f2bb41fd1b2d70b26ada1cf1156bd94c8),
   [#1282](https://github.com/angular/angular.dart/issues/1282))
  - Bind to Web Component properties
  ([c53dc779](https://github.com/angular/angular.dart/commit/c53dc779862c8a36fdb01a8032b99a03165a3ec9),
   [#1277](https://github.com/angular/angular.dart/issues/1277))
- **probe:** add directive getter and export ElementProbe type.
  ([3ec5d753](https://github.com/angular/angular.dart/commit/3ec5d75300c8e5cb315783524a735c6a426ed6b0))
- **routing:** add support for dontLeaveOnParamChanges
  ([9f55fbfc](https://github.com/angular/angular.dart/commit/9f55fbfc7c98ca6c4a2b6a890032cb40cb161e02),
   [#1252](https://github.com/angular/angular.dart/issues/1252), [#1254](https://github.com/angular/angular.dart/issues/1254))
- **testability:** findBindings and findModels should descend into the ShadowDOM
  ([60a1a21d](https://github.com/angular/angular.dart/commit/60a1a21d83cc5d30c7336dbcca46f3a8881e9dbd))
- **template-cache** add option to use external css rewriter in template_cache_generator
  ([25d85fb3](https://github.com/angular/angular.dart/commit/25d85fb3c940a6c499d93040e8bf421487149b0e),
   [#1052](https://github.com/angular/angular.dart/issues/1052))
- **WTF:** extracted scopes to separate file, add documentation
  ([ef3fb7b2](https://github.com/angular/angular.dart/commit/ef3fb7b2b89d512e691c451140abc76d31039835),
   [#1361](https://github.com/angular/angular.dart/issues/1361))


## Performance Improvements

- **dom:** improve dom cloning speed
  ([dec8a972](https://github.com/angular/angular.dart/commit/dec8a972ba66e399309e89c675b822a7a0a97a20))
- **nodecursor:** do not grow/shrink the nodes list
  ([1ab510df](https://github.com/angular/angular.dart/commit/1ab510df4f644b97234b5a713a481d0c9e8fb19d))
- **watch-group:** remove expression coalescing
  ([3de00bd4](https://github.com/angular/angular.dart/commit/3de00bd4902d20137dad0b551312eceb9a599d98),
   [#1328](https://github.com/angular/angular.dart/issues/1328))


## Breaking Changes

- **directive-injector:** due to [600113a8](https://github.com/angular/angular.dart/commit/600113a8e6bc1aff08f00513eb1b794ca28e54ee),
 

Regular injectors (aka application injectors) can no longer be used to
retrieve DirectiveInjectors.  The compiler creates the Directive
Injector as part of view creation process.

<a name="v0.13.0"></a>
# v0.13.0 tempus-fugitification (2014-07-25)

## Highlights

This release is focused on performance and significantly speeds up rendering.  We optimized our 
entire rendering pipeline and now component rendering is 2.8 times (those with inlined templates) 
to 6.3 times faster (those with template files) than the previous 0.12.0 release.

To accomplish these performance improvements, we
- fixed a number of performance bugs
- moved more compilation work out of the ViewFactories, which stamps out DOM nodes, and into the 
  Compiler, which sets up the ViewFactories.
- implemented a custom "directive injector" to optimize Dependency Injection calls from the 
  ViewFactories
- optimized Dependency Injection, eliminating slow APIs

Also, we have given apps more knobs to tune performance
- The Http service now supports coalescing http requests. This means that all the HTTP responses 
  that arrive within a particular interval can all be processed in a single digest.
- The ElementProbe can be disabled for apps that do not use animation
- Along with the existing ScopeStats, Angular now exposes cache statistics through the ngCaches 
  global object. This also allows developers to clear the caches and measure memory usage
- Along with these changes, we have also added support for ProtractorDart.

## Bug Fixes

- **DynamicParser:** Correctly handle throwing exceptions from method.
  ([82ca6bad](https://github.com/angular/angular.dart/commit/82ca6bad7d930d645e57e5d0f1d795e0b97501dc),
   [#971](https://github.com/angular/angular.dart/issues/971), [#1064](https://github.com/angular/angular.dart/issues/1064))
- **Http:**
  - Auxiliary methods like get, put, post, etc. do not set type restriction on data being sent.
  ([68c3e80a](https://github.com/angular/angular.dart/commit/68c3e80afa258f5307e1655beadcf85257b35b11),
   [#1051](https://github.com/angular/angular.dart/issues/1051))
  - Fix NoSuchMethodError in Http when cache set to true and update documentation about cache usage.
  ([5b483324](https://github.com/angular/angular.dart/commit/5b483324bd73955ed799b9ba363dbc2557e2b09a),
   [#1066](https://github.com/angular/angular.dart/issues/1066))
- **NgModel:** Read the view value in the flush phase
  ([75c2f170](https://github.com/angular/angular.dart/commit/75c2f170e1d4de3f40666835c176cff73b08ee82))
- **WatchGroup:** Handle watching elements of array that were removed.
  ([8c271f78](https://github.com/angular/angular.dart/commit/8c271f78941438059b0e71577e363fa48146441f),
   [#1046](https://github.com/angular/angular.dart/issues/1046))
- **benchmark:**
  - typo in element tag names
  ([86de17c2](https://github.com/angular/angular.dart/commit/86de17c2432fb92cdc8efcb7d671d1830649b300),
   [#1220](https://github.com/angular/angular.dart/issues/1220))
  - incorrect mirrors import
  ([b74d5682](https://github.com/angular/angular.dart/commit/b74d5682b9437880029bdc456466ade9ba3e7722))
  - fix standard deviation calculation
  ([1f59d114](https://github.com/angular/angular.dart/commit/1f59d1149f962e6b4008fd7ab6a050f9a39108cd))
- **cache:**
  - Make UnboundedCache extend Cache
  ([08e73054](https://github.com/angular/angular.dart/commit/08e73054a4efc06861ea85481e7bbd4c07f502d3),
   [#1174](https://github.com/angular/angular.dart/issues/1174))
  - Do not export the Cache symbol.
  ([016d463c](https://github.com/angular/angular.dart/commit/016d463c1975e04e71139310c297399f5e6c14cb))
- **change_detector:** fix NaN move detection in collections
  ([f01e2867](https://github.com/angular/angular.dart/commit/f01e2867543cb439dd1ad1db41d9c616f418baab),
   [#1136](https://github.com/angular/angular.dart/issues/1136), [#1149](https://github.com/angular/angular.dart/issues/1149))
- **component factory:** Only create a single ShadowDomComponentFactory
  ([707f701c](https://github.com/angular/angular.dart/commit/707f701c3cf8a96425888f61dd3d753dad5e28a7))
- **dccd:**
  - fix false positive for collection moves
  ([ea3eb1e0](https://github.com/angular/angular.dart/commit/ea3eb1e03eea9033f9bc7177941e41bbb5a32c2a),
   [#1105](https://github.com/angular/angular.dart/issues/1105))
  - fix removals reporting
  ([8dbeefc4](https://github.com/angular/angular.dart/commit/8dbeefc4abb412706991f99f5c8d21d1bebd8237))
- **di:** Remove deprecated calls to DI bind(Type, inject[]).
- **directive:** Support multiple directives with same selector.
  ([01488977](https://github.com/angular/angular.dart/commit/014889771ae4a80f7f934b60f02cbb1d37d5ed41))
- **element binder:**
  - New-style Module.bind for AttrMustache
  ([cfa11e05](https://github.com/angular/angular.dart/commit/cfa11e050fcbc43539e37b51571c40e3270c999a))
  - Use the new-style Module.bind(toFactory) syntax
  ([bed6bcbe](https://github.com/angular/angular.dart/commit/bed6bcbec3a635b9193ac79a7d8249a13f67ea95))
- **examples:** do not use shadow DOM
  ([0cf209bb](https://github.com/angular/angular.dart/commit/0cf209bb091839b8e1192e2fd54a0ced1a057201))
- **expression extractor:** Do not use implicit DI
  ([105b41f4](https://github.com/angular/angular.dart/commit/105b41f4247dac8b59738ad740fff545320431a2))
- **introspection:**
  - getTestability should throw when ElementProbes are unavailable
  ([158e9aa7](https://github.com/angular/angular.dart/commit/158e9aa70cf38141959a185b2c39e33ead09e543))
  - work around http://dartbug.com/17752
  ([384039a1](https://github.com/angular/angular.dart/commit/384039a1c07ee66ac2a886e58b3eb3c12bcba04d))
- **karma:** remove saucelabs from default browser list.
  ([989992de](https://github.com/angular/angular.dart/commit/989992deec9f5253ea9028eeb6b74022736fae36))
- **ng-model:** Turn off failing test until Dart 1.6 is stable.
  ([e8825165](https://github.com/angular/angular.dart/commit/e88251651fb466e48e6f1a208cd24df7fade59f1),
   [#1234](https://github.com/angular/angular.dart/issues/1234))
- **ng-view:** cleanup should not destroy an already destroyed scope
  ([5cb46a16](https://github.com/angular/angular.dart/commit/5cb46a1608f41f8a1c7db1f473c7efccc265598f),
   [#1182](https://github.com/angular/angular.dart/issues/1182))
- **ng_repeat:** fix ng_repeat not moving views for elements that have not moved
  ([559a685e](https://github.com/angular/angular.dart/commit/559a685e218c453eea158eee068d2e0afaf718eb),
   [#1154](https://github.com/angular/angular.dart/issues/1154), [#1155](https://github.com/angular/angular.dart/issues/1155))
- **parser:** ensure only one instance of dynamic parser
  ([f2c45758](https://github.com/angular/angular.dart/commit/f2c457580de28eb250ddce455edd3ede4af6c847))
- **pubspec:** Add missing upper bound version constraints
  ([cee0d727](https://github.com/angular/angular.dart/commit/cee0d727d9b18e6d21350bf74e023565e3908f57))
- **registry_dynamic:** Do not use HashMaps.
  ([04624f21](https://github.com/angular/angular.dart/commit/04624f21813be8efc5bffaa8daf0029e777958a2))
- **scope:**
  - remove deprecation warning for scope.watch with context
  ([1c7c0ba3](https://github.com/angular/angular.dart/commit/1c7c0ba3c8745a73a03c14845c70e83662c55d3e))
  - Use runAsync for microtasks in digest.
  ([d1e745e0](https://github.com/angular/angular.dart/commit/d1e745e04ba1c9fdf23b416d299e193b77e3cc53))
- **transcluding component:** Perfer getByKey over get
  ([6f3587d2](https://github.com/angular/angular.dart/commit/6f3587d21d00da296a40c4879c7e8c248c0b06a8))
- **travis:** Work around Travis breakages
  ([be76be4f](https://github.com/angular/angular.dart/commit/be76be4fde537bf9c52ae307541f045e8b06c8f3))
- **various:** Use the new-style Module.bind(toFactory) syntax
  ([a30c0a57](https://github.com/angular/angular.dart/commit/a30c0a5726e71491646506b9306ce53138c47c44))
- **watch_group:** fix for NaN !== NaN
  ([d24ff897](https://github.com/angular/angular.dart/commit/d24ff8979e3b2c6a72f388f478ea0aab655f35cb),
   [#1146](https://github.com/angular/angular.dart/issues/1146))
- **web platform:** Do not barf on attribute selectors.
  ([f2b83930](https://github.com/angular/angular.dart/commit/f2b83930f2473f7d6b1f1796a8e1f07ec4e0422e))


## Features

- **animate:** Allowed property to turn off all animations
  ([b3f2e6ca](https://github.com/angular/angular.dart/commit/b3f2e6caa5bc4047af59f730c17fcb5a34f1bc9f))
- **benchmark:**
  - improve layout of data by moving averages to dedicated row
  ([3330d657](https://github.com/angular/angular.dart/commit/3330d657cd5c592924816a4a88876881de2460da))
  - calculate coefficient of variation
  ([fc09af2c](https://github.com/angular/angular.dart/commit/fc09af2c880bf741abe8c9284805a92bd63f8742))
  - add standard deviation to report
  ([13e87e06](https://github.com/angular/angular.dart/commit/13e87e06fb3972b7c0b6d35b08351a639a329eba))
  - calculate relative margin of error and simplify report
  ([4614cc06](https://github.com/angular/angular.dart/commit/4614cc061011b01809eb884d7ad127d89fe4e547))
  - add confidence and stability info to averages
  ([bd17bbe7](https://github.com/angular/angular.dart/commit/bd17bbe7e61b83789f4cc3f36d6d4222b37f0279))
  - add statistical functions to calculate confidence interval
  ([26f7defe](https://github.com/angular/angular.dart/commit/26f7defe4bc2b70c9fd746b42053e4fa9cefc63b))
  - add ability to profile memory usage per iteration
  ([afe55814](https://github.com/angular/angular.dart/commit/afe558141802f84f8cd34d61bfd4dd1e7ca9eba4))
  - improve sampling UI
  ([e1c17d90](https://github.com/angular/angular.dart/commit/e1c17d904177c186825d939742800d94e6bd6304))
  - change samples input type from range to text
  ([387933d0](https://github.com/angular/angular.dart/commit/387933d03fa908d7fe29fc8d673847cd18d824cc))
  - record gc time for each test run
  ([dfdf67b5](https://github.com/angular/angular.dart/commit/dfdf67b50921b6ff69d9fe2360fbb7b55bf6d1ec))
  - add ability to adjust sample quantity
  ([a98663d9](https://github.com/angular/angular.dart/commit/a98663d9bd148839d14e1f95d887560b58bc63f2))
  - add automatic gc before each test
  ([fe1f74d0](https://github.com/angular/angular.dart/commit/fe1f74d0d845bcfe3b416ada4bb8849a1ecba3ff),
   [#1133](https://github.com/angular/angular.dart/issues/1133))
- **cache:**
  - Add a JS interface to CacheRegister
  ([435d9987](https://github.com/angular/angular.dart/commit/435d9987beaf2965a75ed13a18f29bb672c32806),
   [#1181](https://github.com/angular/angular.dart/issues/1181))
  - Add existing caches to CacheRegister
  ([59003705](https://github.com/angular/angular.dart/commit/59003705f7225760151136951361d1e71a453db4),
   [#1165](https://github.com/angular/angular.dart/issues/1165))
  - Move cache out of core, add a CacheRegister
  ([be62c48e](https://github.com/angular/angular.dart/commit/be62c48e3b4c9dbe5a0b4cb7fcadec4e29255861))
- **compiler:**
  - Backport DirectiveBinder API from #1178 to allow gradual migration.
  ([1f3cca42](https://github.com/angular/angular.dart/commit/1f3cca429e2074400ce7e0f476d972d6b54e2774))
- **element binder:** Use a child scope instead of Scope.watch(context:o)
  ([6051340b](https://github.com/angular/angular.dart/commit/6051340bb583382ff0157e255eafa537ab5564aa))
- **form:** Add support for `input[type=color]`
  ([0064ef5c](https://github.com/angular/angular.dart/commit/0064ef5c7db5ce2286cc7d626b2cc620429e4da3),
   [#611](https://github.com/angular/angular.dart/issues/611), [#1080](https://github.com/angular/angular.dart/issues/1080))
- **http:**
  - support coalescing http requests
  ([3e44a542](https://github.com/angular/angular.dart/commit/3e44a542faccd3f5e5f7861cff44e221279bcc42))
  - run interceptors synchronously until first non-sync interceptor
  ([38d3cfd6](https://github.com/angular/angular.dart/commit/38d3cfd6ff680dd92ce3b34018fdb7b148a29ea9))
- **mock:** Add timer queue checks in mock zone
  ([98e61b77](https://github.com/angular/angular.dart/commit/98e61b77d91a58fe13406ded2b94167b595701d5),
   [#1157](https://github.com/angular/angular.dart/issues/1157))
- **router:** added vetoable preLeave event
  ([ddd9e414](https://github.com/angular/angular.dart/commit/ddd9e4147c0c88a374345bf8b32df6cf57740ac4),
   [#1070](https://github.com/angular/angular.dart/issues/1070))
- **scope:**
  - Expose Scope.watchAST as a public API
  ([ecd75ce7](https://github.com/angular/angular.dart/commit/ecd75ce71460a3bb1e87e0c9371c8d8ac892c512))
  - Deprecate Scope.watch's context parameter.
  ([e8a5ce73](https://github.com/angular/angular.dart/commit/e8a5ce734b00fd22f700e2fc1be5507dda195638))
  - Instrument Scope to use User tags in Dart Obervatory
  ([c21ac7ea](https://github.com/angular/angular.dart/commit/c21ac7eaec3fd15bba7a124fdfb3e9680092a0f2),
   [#1138](https://github.com/angular/angular.dart/issues/1138))
  - Use VmTurnZone.onScheduleMicrotask in Scope
  ([81667aad](https://github.com/angular/angular.dart/commit/81667aad6a2da1efa39adaf333b8ebfe297c88b1),
   [#984](https://github.com/angular/angular.dart/issues/984))
- **testability:**
  - whenStable replaces notifyWhenNoOutstandingRequests
  ([5ef596d1](https://github.com/angular/angular.dart/commit/5ef596d10f50d2739eba6a7be9555f240f12abf6))
  - implement the testability for ProtractorDart
  ([f2d1f2e9](https://github.com/angular/angular.dart/commit/f2d1f2e9e64d18fe5407f67555eb1c30110bd419))


## Performance Improvements

- **ChangeDetector:**
  - create _EvalWatchRecord#namedArgs lazily
  ([42e53b86](https://github.com/angular/angular.dart/commit/42e53b8663936b3637b2d13de4f3f56db27e94cf))
  - lazy initialize DuplicateMap
  ([11629dee](https://github.com/angular/angular.dart/commit/11629deea92bb0f0b341ba6eb2f04a5072fbdcd2))
- **View:** Improve View instantiation speed and memory consumption.
  ([494deda5](https://github.com/angular/angular.dart/commit/494deda594f39b422e4c2f5def1a2cbaf749efba))
- **cd:** fewer string concatenations (10% improvement)
  ([a6526803](https://github.com/angular/angular.dart/commit/a6526803fb07f126414f0259d4d0baf8e89d70b1))
- **compiler:**
  - +6% Pre-compute ViewFactories, styles for components.
  ([be3cdd41](https://github.com/angular/angular.dart/commit/be3cdd4147d7917dea5fcca301cb73057f0f604d),
   [#1134](https://github.com/angular/angular.dart/issues/1134))
  - An option to disable the ElementProbe.
  ([9f0c7bca](https://github.com/angular/angular.dart/commit/9f0c7bcab2915ffa7509a28eaff1d1762f1d9bf0),
   [#1118](https://github.com/angular/angular.dart/issues/1118), [#1131](https://github.com/angular/angular.dart/issues/1131))
  - Pre-compile Scope.watch ASTs for attribute mustaches
  ([90df4eb2](https://github.com/angular/angular.dart/commit/90df4eb2012a0bf21f33bf219be544bd535f765c),
   [#1088](https://github.com/angular/angular.dart/issues/1088))
  - Precompute Scope.watch AST for TextMustache
  ([daf8d5af](https://github.com/angular/angular.dart/commit/daf8d5afdc8f0f0f66eed5de6eea4a5df2280a9f))
- **element binder:** Do not create tasklists when not needed
  ([a33891ea](https://github.com/angular/angular.dart/commit/a33891ea915a4faf98caf78725dfc093b213744b))
- **scope:** Cache the Scope.watch AST.
  ([05e2c576](https://github.com/angular/angular.dart/commit/05e2c57625f1cc2c56c3cc91534420d066e41389),
   [#1173](https://github.com/angular/angular.dart/issues/1173))
- **various:** Avoid putIfAbsent
  ([57da29d7](https://github.com/angular/angular.dart/commit/57da29d7ea0e20aecde60ac42788b30aedcaa3b6))
- **view cache:** Avoid http.get
  ([db72a4fc](https://github.com/angular/angular.dart/commit/db72a4fc99e1d2b9921b361198e0c57d93091f5e),
   [#1108](https://github.com/angular/angular.dart/issues/1108))
- **view factory:** 14% Precompute linking information for nodes
  ([eac36d1d](https://github.com/angular/angular.dart/commit/eac36d1d26a283560742b3555886f5db99ee9c65),
   [#1194](https://github.com/angular/angular.dart/issues/1194), [#1196](https://github.com/angular/angular.dart/issues/1196))


## Breaking Changes

- **Scope:** due to [81667aad](https://github.com/angular/angular.dart/commit/81667aad6a2da1efa39adaf333b8ebfe297c88b1),


Previously a micro task registered in flush phase would cause a new
digest cycle after the current digest cycle. The new behavior
will cause an error.

Closes #984
- **View:** due to [494deda5](https://github.com/angular/angular.dart/commit/494deda594f39b422e4c2f5def1a2cbaf749efba),


- Injector no longer supports visibility
- The Directive:module instead of returning Module now takes
  DirectiveModule (which supports visibility)
- Application Injector and DirectiveInjector now have separate trees.
  (The root if DirectiveInjector is ApplicationInjector)
- **scope:** due to [d1e745e0](https://github.com/angular/angular.dart/commit/d1e745e04ba1c9fdf23b416d299e193b77e3cc53),


Microtasks scheduled in flush will process in current cycle, but they
are not allowed to do model changes.

Microtasks scheduled in digest will be executed in digest, counting
towards the ScopeDigestTTL.
- **testability:** due to [5ef596d1](https://github.com/angular/angular.dart/commit/5ef596d10f50d2739eba6a7be9555f240f12abf6),

  NOTE: This only affects you if you are calling this API directly.  If
  you are using ProtractorDart, then you are insulated from this change.

  To update your code, rename all references to the
  notifyWhenNoOutstandingRequests(callback) method on the testability
  object to whenStable(callback).

<a name="v0.12.0"></a>
# v0.12.0 sprightly-argentinosaurus (2014-06-03)

## Highlights

- A 20% performance improvement from caching interpolated expressions.
- Http service can make cross-site requests (get, post, put, etc.) which use credentials (such as 
  cookies or authorization headers).
- **Breaking change**: vetoing is no longer allowed on leave (RouteLeaveEvent). This change corrects 
  an issue with routes unable to recover from another route vetoing a leave event.
- **Breaking change**:  Zone.defaultOnScheduleMicrotask is now named Zone.onScheduleMicrotask
- **Breaking change**: OneWayOneTime bindings will continue to accept value assignments until their 
  stabilized value is non-null.

## Bug Fixes

- **NgStyle:** make NgStyle export expressions
  ([8470abd3](https://github.com/angular/angular.dart/commit/8470abd3b58a46ca2bce96b925155fac7a8f2969),
   [#993](https://github.com/angular/angular.dart/issues/993))
- **ViewCache:** Use an unbounded cache in the ViewCache.
  ([36d93d87](https://github.com/angular/angular.dart/commit/36d93d8764c28fa02da3c4ccb622fbe19af229d9))
- **VmTurnZone:**
  - Remove a unneeded delegate.run() call.
  ([a0d5d82d](https://github.com/angular/angular.dart/commit/a0d5d82d1fbc7aa5e7ba279d8153a33129318b9d))
  - onScheduleMicrotask behaves correctly with orphaned scheduleMicrotasks.
  ([a8699da0](https://github.com/angular/angular.dart/commit/a8699da016c754e08502ae24034a86bd8d6e0d8e))
- **angular_spec:** export symbols for the route preLeave event
  ([7c9a7585](https://github.com/angular/angular.dart/commit/7c9a7585f265bcba88e05fa41f3b6a4698633460))
- **compiler:**
  - Do not store injectors with TaggingElementBinders
  ([a9dc429c](https://github.com/angular/angular.dart/commit/a9dc429c4e9fd019193f51b8db97281fa8529903))
  - OneWayOneTime bindings now wait for the model to stablize
  ([0e129496](https://github.com/angular/angular.dart/commit/0e1294966d7daacc0aa7866fd9674e8e5695abb5),
   [#1013](https://github.com/angular/angular.dart/issues/1013))
- **dccd:** fix DirtyCheckingRecord.toString() throws an exception
  ([efcdca3f](https://github.com/angular/angular.dart/commit/efcdca3f2fe603318979647c28fd9815b94646a8))
- **directives:** remove an unused import
  ([6102d8a1](https://github.com/angular/angular.dart/commit/6102d8a15092f2206093842ab8629c86472d4a4e))
- **element binder:**
  - fix memory leak with expando value holding onto node
  ([b7f175bf](https://github.com/angular/angular.dart/commit/b7f175bfa9b2786a58718d544fc75c867cd2fa40))
  - Ensure mappings are evaluated before attach() is called.
  ([fef0da0a](https://github.com/angular/angular.dart/commit/fef0da0a045856134bdb4e8e56b8bce05d4f6511),
   [#1059](https://github.com/angular/angular.dart/issues/1059))
- **http:** use location.href instead of toString
  ([6a48a39d](https://github.com/angular/angular.dart/commit/6a48a39da1ab22693aed354e0df84590915cf84b))
- **ng-repeat:** handle the ref changing to null and back
  ([46b4c0e0](https://github.com/angular/angular.dart/commit/46b4c0e020709ceb88c590e825b106a081a68226),
   [#1015](https://github.com/angular/angular.dart/issues/1015))
- **transcluding component factory:** allow removing components that have no content to transclude
  ([706f9e9b](https://github.com/angular/angular.dart/commit/706f9e9b1442c86d37cfe2bb5cdb6d2d950ce541))
- **transcluding_component_factory:** fix content detach logic
  ([3141d32e](https://github.com/angular/angular.dart/commit/3141d32ee72c3a3dd1674b10702e411b740690a2))
- **watch group:** Fixed WatchGroup.toString(), added a test.
  ([c9776b4c](https://github.com/angular/angular.dart/commit/c9776b4c7d30b01ea22a014f9120e862c9c3463a))

## Features

- **Http:** Http service can make cross-site requests (get, post, put, etc.) which use credentials (such as cookies or authorization headers).
  ([3ef9d8e4](https://github.com/angular/angular.dart/commit/3ef9d8e4dc1491f6fa0afda5b29444c03d454919),
   [#945](https://github.com/angular/angular.dart/issues/945), [#1026](https://github.com/angular/angular.dart/issues/1026))
- **date:** Use localized patterns for shorthand format
  ([fb1bcf47](https://github.com/angular/angular.dart/commit/fb1bcf477765b444aef6460c2cf245ef11c85822))
- **dccd:** Make toString() code more robust
  ([47ad9d9b](https://github.com/angular/angular.dart/commit/47ad9d9b73c17fdd3fd31aa2ef1d477ff50420e2))
- **ng-base-css:** useNgBaseCss Component annotation field.
  ([b861a9fc](https://github.com/angular/angular.dart/commit/b861a9fcc1d2bcf60c6ef937d88bcd88aeaab629))
- **ng-model:** Added ng-model-options
  ([f7115aa8](https://github.com/angular/angular.dart/commit/f7115aa86da0cd7b37e68b2a652959e6572ffa14),
   [#969](https://github.com/angular/angular.dart/issues/969), [#974](https://github.com/angular/angular.dart/issues/974))
- **platform:** Make angular invoke web_component polyfills for browsers without native web_component implementations.
  ([0c22a3b6](https://github.com/angular/angular.dart/commit/0c22a3b6d73ab6789dca7859ce3424e6018fa688))
- **travis:** Web platform features for Chrome 34
  ([7466489d](https://github.com/angular/angular.dart/commit/7466489dfa9326fda14c2a57e7f2c60e41313da9))

## Performance Improvements

- **NodeCursor:** Do not duplicate child nodes
  ([45436680](https://github.com/angular/angular.dart/commit/454366808d711ccd0cc05fc8d8eb7f565ba4ff29))
- **_ElementSelector:** Remove recursion in addDirective
  ([2fbb60b5](https://github.com/angular/angular.dart/commit/2fbb60b54f0675464f87f3311e2e28936e320562))
- **interpolate:** 20%. Cache the interpolated expressions.
  ([669d47ce](https://github.com/angular/angular.dart/commit/669d47ce8dd9c1df1033a7f0715be76843be67a3))
- **selector:** Remove an useless check
  ([6fea97d4](https://github.com/angular/angular.dart/commit/6fea97d4f02ad525b4b900b8a31b7184692e5296))
- **tagging_view_factory:** Move a test out of the loop
  ([e4f7e349](https://github.com/angular/angular.dart/commit/e4f7e349809c7a27dcb0729ad100036cbb6fd7cf))
- **view factory:**
  - Compute DI Keys ahead of time
  ([317c23c0](https://github.com/angular/angular.dart/commit/317c23c0953f54d8c589a5d77cf86a06603cf067),
   [#1085](https://github.com/angular/angular.dart/issues/1085))
  - Remove try-finally from ElementBinder._link
  ([60626104](https://github.com/angular/angular.dart/commit/606261043295812c8c7e6dab07aad9808003f075))
  - Remove a try-catch and a timer for the critical path
  ([9f4defef](https://github.com/angular/angular.dart/commit/9f4defef56d85c5a07fbf7bbfd2db98810657b4e))
- **watch group:** Do not use List.map for tiny lists
  ([61f33489](https://github.com/angular/angular.dart/commit/61f33489055717fecb0c0f58a0cee663bd535846))


## Breaking Changes

- **VmTurnZone:** due to [a8699da0](https://github.com/angular/angular.dart/commit/a8699da016c754e08502ae24034a86bd8d6e0d8e),
 
`Zone.defaultOnScheduleMicrotask` is now named `Zone.onScheduleMicrotask`


<a name="v0.11.0"></a>
# v0.11.0 ungulate-funambulism (2014-05-06)

## Highlights

### Breaking Change

The breaking change first: `Http.getString()` is gone.

If you said: `Http.getString('data.txt').then((String data) { ... })` before, now say
`Http.get('data.txt').then((HttpResponse resp) { var data = resp.data; ... });`

### New Features

- Shadow DOM-less components

Shadow DOM is still enabled by default for components. Now, its use can be controlled through the 
new `useShadowDom` option in the Component annotation.

For example:

```dart
@Component(
  selector: 'my-comp',
  templateUrl: 'my-comp.html',
  useShadowDom: false)
class MyComp {}
```

will disable Shadow DOM for that component and construct the template in the "light" DOM. Either 
omitting the `useShadowDom` option or explicitly setting it to `true` will cause Angular to 
construct the template in the component's shadow DOM.

Adding cssUrls to Components with Shadow DOM disabled is not allowed. Since they aren't using Shadow 
DOM, there is no style encapsulation and per-component CSS doesn't make sense. The component has 
access to the styles in the `documentFragment` where it was created. Style encapsulation is a 
feature we are thinking about, so this design will likely change in the future.

- bind-* syntax

We have shipped an early "preview" of the upcoming bind-* syntax. In 0.11.0, you may bind an 
expression to any mapped attribute, even if that attribute is a `@NgAttr` mapping which typically 
takes a string.

### Performance improvements

There are two significant performance improvements:
- We now cache CSS as `StyleElement`s instead of string, saving a `setInnerHtml` call on each styled 
  component instantiation. In a benchmark where components used unminified Bootstrap styles (124kB), 
  this sped up component creation by 31%.
- Changes in the DI package sped up View instantiation by 200%. This change makes AngularDart 
  rendering significantly faster.

## Bug Fixes

- **Animate:** Animation rename types.
  ([70b2e408](https://github.com/angular/angular.dart/commit/70b2e408559cc21ed471fcd25421260a53547118))
- **Change detection:** _LinkList items extend _LinkedListItem
  ([2960d7c2](https://github.com/angular/angular.dart/commit/2960d7c25d35933f60bd8d33c44a9950a31d67b2),
   [#932](https://github.com/angular/angular.dart/issues/932))
- **Dirty Checking:** fix watching methods/closures
  ([d71c7fa7](https://github.com/angular/angular.dart/commit/d71c7fa7e146cc07606dd6693fc644d6fec37f1c),
   [#999](https://github.com/angular/angular.dart/issues/999))
- **ShadowDomComponentFactory:** annotate ShadowDomComponentFactory with @Injectable so that appropriate entry in static factories in generated.
  ([61ce182d](https://github.com/angular/angular.dart/commit/61ce182df43f23a6065ba45a19718c774bbdf0fa),
   [#963](https://github.com/angular/angular.dart/issues/963))
- **StaticMetadataExtractor:** Map members annotations to all annotations
  ([9622318e](https://github.com/angular/angular.dart/commit/9622318ef4fdc16ae8265b01ebf9262f578e861d),
   [#904](https://github.com/angular/angular.dart/issues/904))
- **angular_spec:** Acutally assert
  ([aae2c1f9](https://github.com/angular/angular.dart/commit/aae2c1f9e5d7c4f0723da176615c86dca2cacb88))
- **change-detection:** correctly detect isMethod in StaticFieldGetterFactory
  ([474b002e](https://github.com/angular/angular.dart/commit/474b002eed5611608fe9ee58b324f926579a0a02))
- **codegen:** Add missing @Injectable annotation
  ([a4375192](https://github.com/angular/angular.dart/commit/a437519204bce8d66929a2cf55ae30a66cd88bcc))
- **dccd:** Fix _MapChangeRecord
  ([36923850](https://github.com/angular/angular.dart/commit/3692385031adfb0ef9e58a79c3a9a795b36a2c28))
- **interpolate:** changes the interpolate function to escape double quotes
  ([806ed695](https://github.com/angular/angular.dart/commit/806ed69576b91e3612a4acd5477042566add744a),
   [#937](https://github.com/angular/angular.dart/issues/937))
- **ngModel:** add input type tel to ngModel directive
  ([a91bbca8](https://github.com/angular/angular.dart/commit/a91bbca87b62f675251dcfd341a3f56dabb3a6b6))
- **specs:** toHaveText merges shadow DOM correctly
  ([d4127643](https://github.com/angular/angular.dart/commit/d41276435570a2a8c9b3fcee2f60a7a9364bc8a7))
- **symbol_inspector:** Do not return private symbols
  ([a66b2c13](https://github.com/angular/angular.dart/commit/a66b2c136c7830eb042053243757d3a1d1540dfd))
- **tests:** Use updated annotation type
  ([c93a1bde](https://github.com/angular/angular.dart/commit/c93a1bde5eaa2457b320006a1db528b644669d02),
   [#948](https://github.com/angular/angular.dart/issues/948))
- **transformer:**
  - Fixing some analyzer warnings
  ([1360d193](https://github.com/angular/angular.dart/commit/1360d193f908d5b9b62e2b34ff5aebbefee5c46e),
   [#955](https://github.com/angular/angular.dart/issues/955))
  - Fixing invalid code generation for dashed filenames
  ([1df0f641](https://github.com/angular/angular.dart/commit/1df0f641d85dc82d4d1494f0ba0e618ddeb76421),
   [#947](https://github.com/angular/angular.dart/issues/947))
- **travis:** Curl should follow redirects when fetching scripts
  ([40563c89](https://github.com/angular/angular.dart/commit/40563c891ed63e86b72d160fcafc6bfda0d21577))


## Features

- **LRUCache:** Support zero-length caches
  ([3e60863e](https://github.com/angular/angular.dart/commit/3e60863ed2567e7f0380951eb32d18799409320c))
- **VmTurnZone:** VmTurnZone can handle scheduling microtasks.
  ([ecf9b714](https://github.com/angular/angular.dart/commit/ecf9b7148e2fcb90ec9f5e897ad5c480c303a827),
   [#976](https://github.com/angular/angular.dart/issues/976), [#979](https://github.com/angular/angular.dart/issues/979))
- **Zone:** add onTurnStart to NgZone.
  ([4bf0c32e](https://github.com/angular/angular.dart/commit/4bf0c32ef26980f7f7e5c95b8a3b1c15156f6522),
   [#83](https://github.com/angular/angular.dart/issues/83))
- **annotation:** Annotations on superclasses are honored
  ([eee41911](https://github.com/angular/angular.dart/commit/eee4191130b2cd16f00aa1aaa57ce4fadee1454e),
   [#829](https://github.com/angular/angular.dart/issues/829))
- **compiler:**
  - bind- syntax
  ([4d17c119](https://github.com/angular/angular.dart/commit/4d17c1193bc39bc92026ce5b5e0ff9e45df03de8),
   [#957](https://github.com/angular/angular.dart/issues/957))
  - useShadowDom option
  ([c60e9369](https://github.com/angular/angular.dart/commit/c60e9369a60a4ca1a2ff37def9c7a0e98cd274fd),
   [#367](https://github.com/angular/angular.dart/issues/367), [#936](https://github.com/angular/angular.dart/issues/936))
  - Shadow DOM-less components
  ([26ad8801](https://github.com/angular/angular.dart/commit/26ad8801b11255da49ceb120656bc79d2b4bfb4d))
- **debug:** Make ngProbe accept a CSS selector
  ([eb057c38](https://github.com/angular/angular.dart/commit/eb057c384bdc6f6112c0c92536b134cd13ab76be),
   [#970](https://github.com/angular/angular.dart/issues/970))
- **formatter:** Add arrayify formatter.
  ([d2780f8b](https://github.com/angular/angular.dart/commit/d2780f8bb849c62d995d939d00594ebe93428631),
   [#394](https://github.com/angular/angular.dart/issues/394), [#931](https://github.com/angular/angular.dart/issues/931))


## Performance Improvements

- **compiler:** 31%. Cache CSS in Style elements.
  ([cd2594da](https://github.com/angular/angular.dart/commit/cd2594da80a343824bb98b4c87ed99c2118f7b2c))


## Breaking Changes

- **Http:** due to [39a143d](https://github.com/angular/angular.dart/commit/39a143da630965703cbe53e45e902e97163a75d54),

The deprecated Http.getString() method has been removed in favour of Http.get()
 
<a name="v0.10.0"></a>
# v0.10.0 ostemad-teleportation (2014-04-17)

*NOTE:* Contains significant BREAKING CHANGES!

## Bug Fixes

- **DateFilter:** cache DateFormat correctly
  ([64cf96f1](https://github.com/angular/angular.dart/commit/64cf96f104f886036b6f25d0bda5d1307f50d1d1),
   [#882](https://github.com/angular/angular.dart/issues/882))
- **NgA:** Do not cause a scope digest
  ([de21f4de](https://github.com/angular/angular.dart/commit/de21f4de1f39a4745ad088805459848204457e23),
   [#810](https://github.com/angular/angular.dart/issues/810))
- **NgControl:** Remove dead code
  ([b30ebe0f](https://github.com/angular/angular.dart/commit/b30ebe0fbaef0e7aa39d52a0bc8bf9cc2174386b))
- **angular.core:** re-export required annotations
  ([6a9ea37c](https://github.com/angular/angular.dart/commit/6a9ea37cfb444bdfb5e99af42a091c12d949b307))
- **animation:** temporary fix for Animation symbol conflict
  ([82b4f3e1](https://github.com/angular/angular.dart/commit/82b4f3e12a6a5b1e079c40c8341467089ab8fdf0))
- **application_factory:** add missing @MirrorsUsed targets
  ([b5e835a0](https://github.com/angular/angular.dart/commit/b5e835a0e3b4bfd8b8b44c260bb0466caa75ab93),
   [#911](https://github.com/angular/angular.dart/issues/911))
- **bootstrap:** Rename bootstrapping methods
  ([155582d1](https://github.com/angular/angular.dart/commit/155582d199e25aa69ff803b228c3c3c0e5b9ac70))
- **change-detection:** When two identical pure functions removed
  ([84781ef3](https://github.com/angular/angular.dart/commit/84781ef3377b4cdb92a2cb3b98fb58468e34abc1),
   [#787](https://github.com/angular/angular.dart/issues/787), [#788](https://github.com/angular/angular.dart/issues/788))
- **change-detection:** properly watch map['key'] constructs
  ([03f0a4c7](https://github.com/angular/angular.dart/commit/03f0a4c72709d74c3b4d5f3fa168189efd7e5b97),
   [#824](https://github.com/angular/angular.dart/issues/824))
- **cookies:** Make sure Cookies is injectable.
  ([8952cbdd](https://github.com/angular/angular.dart/commit/8952cbdd70f32e8b920942476648b1a8f1473480),
   [#856](https://github.com/angular/angular.dart/issues/856))
- **core:** ensure change detection doesn't trigger an infinite loop while not in debug mode
  ([6ac105c9](https://github.com/angular/angular.dart/commit/6ac105c9bf662c8717dab811c6c41ded9eed05ea))
- **dirty-checking:**
  - handle simultaneous mutations and ref changes
  ([28a79bc2](https://github.com/angular/angular.dart/commit/28a79bc21ef3a4a7b0824249bfa31a668275c76e))
  - fix removal of watch record on disconnected group.
  ([d22899aa](https://github.com/angular/angular.dart/commit/d22899aa68f4da15673821cb16f04d4f8c7a4dee))
- **doc:** add angular.core.annotation lib to docs
  ([ad2e6b0e](https://github.com/angular/angular.dart/commit/ad2e6b0e76357e3aeaee0cd1726247059acc1f49))
- **docs:** reenable broken doc generation
  ([e925a143](https://github.com/angular/angular.dart/commit/e925a1430e9de53d710e175703c57aefd4dad700))
- **events:** make ShadowRootEventHandler play nice with static injection
  ([d7683218](https://github.com/angular/angular.dart/commit/d76832181706a86dcef1e0c3b60749f82a2e0e27))
- **example:** Adjust MirrorsUsed to make the Todo example work thru dart2js
  ([ee4a448b](https://github.com/angular/angular.dart/commit/ee4a448b9defd4c9fda1e86f3c9c37e5465f7e21))
- **export:** Add missing NgController to angualr.dart
  ([7475ccc4](https://github.com/angular/angular.dart/commit/7475ccc44cec302a0bd0745e99ec491ff3289427))
- **filters:**
  - handle the current locale correctly
  ([212b6f79](https://github.com/angular/angular.dart/commit/212b6f79560cc24b4a210c6f44e73a8408690fa9),
   [#865](https://github.com/angular/angular.dart/issues/865))
  - pass filters to all evals
  ([25dfd32f](https://github.com/angular/angular.dart/commit/25dfd32ff9e1523ee9220769871867111ed93c3b))
- **forms:** change valid_submit and invalid_submit to camelcase
  ([e5baa502](https://github.com/angular/angular.dart/commit/e5baa50235aa3ec53f00f87b86dab78ef5882900),
   [#793](https://github.com/angular/angular.dart/issues/793))
- **http:** fix header map type for http.call()
  ([a6cc826a](https://github.com/angular/angular.dart/commit/a6cc826a1bbe580dd2774b6d53e246a838d3425d))
- **jasmine:** don't swallow exceptions in afterEach
  ([ae15983d](https://github.com/angular/angular.dart/commit/ae15983d2134bf0fb1823f427654629f92c295d5))
- **mirror:** added missing mirrors declarations
  ([0ebb49f8](https://github.com/angular/angular.dart/commit/0ebb49f84c12ec2c4b11f1cf75d230f601975ebc))
- **mock:** export test_injection from module
  ([70546ca5](https://github.com/angular/angular.dart/commit/70546ca50dc5038ba911fcf972af90de492743d4))
- **mustache:** fix regression that fired an initial empty string
  ([c71b8cfc](https://github.com/angular/angular.dart/commit/c71b8cfc935d1599b2c1c7cef5a08ff4caee7010),
   [#734](https://github.com/angular/angular.dart/issues/734))
- **ng-model:** Do not use valueAsNumber to work around dartbug.com/15788
  ([019209e7](https://github.com/angular/angular.dart/commit/019209e79ce0752351f2b8d74511fa39694d1e93),
   [#694](https://github.com/angular/angular.dart/issues/694))
- **ng-repeat:** don't use iterable.length
  ([cf2671ab](https://github.com/angular/angular.dart/commit/cf2671ab718d019a0eaa7d7e0483cae196aaa76c))
- **ng-view:** correct infinite loop in RouteProvider injection
  ([be902f46](https://github.com/angular/angular.dart/commit/be902f46035b0ea9464eafd12eb4470316ec82fe))
- **ng_mustache:** actually assign to _hasObservers
  ([61c953d9](https://github.com/angular/angular.dart/commit/61c953d9be3e2626e159cd08ac585a67f412a37e))
- **parser:** changes parser to throw an error when it encounters an unexpected token
  ([7c26ab0d](https://github.com/angular/angular.dart/commit/7c26ab0dbce3b8ebbde26716e9dc1cfda1e38c71),
   [#830](https://github.com/angular/angular.dart/issues/830), [#905](https://github.com/angular/angular.dart/issues/905))
- **profiler:** Fix API
  ([f032b376](https://github.com/angular/angular.dart/commit/f032b376c77b9b054d4c2b2db7b29cb7f7c71102))
- **scope:** allow watching an empty string
  ([bd0d4ffd](https://github.com/angular/angular.dart/commit/bd0d4ffdded131cd3040c6ddda32c46f6553b629))
- **startup:** Avoid creating rarely needed objects
  ([29bda806](https://github.com/angular/angular.dart/commit/29bda8061aa5240f5445ac28a310990f4f3b80d0))
- **tagging-compiler:** support top level comments
  ([dc75b016](https://github.com/angular/angular.dart/commit/dc75b0166cc93c08bf81fa364c247de3d97ad2c1))
- **test:** fixes for latest unittest lib
  ([c8527208](https://github.com/angular/angular.dart/commit/c852720827584065fdc5d48d5dc6d0e23770ebc1),
   [#811](https://github.com/angular/angular.dart/issues/811))
- **transformer:**
  - Serializing execution of transformers
  ([8b06e673](https://github.com/angular/angular.dart/commit/8b06e673d72d0e98d8a99ef159cc4ebc6fbf8c65),
   [#889](https://github.com/angular/angular.dart/issues/889))
  - crashes in metadata extraction while in pub serve
  ([e35a5e17](https://github.com/angular/angular.dart/commit/e35a5e17e890d739ee546227fef98acbc66c1112),
   [#888](https://github.com/angular/angular.dart/issues/888))
  - Transformer needs html5lib 0.9.2
  ([b52323e4](https://github.com/angular/angular.dart/commit/b52323e4e227d9de9a69134912845835733c20f7))
- **transformers:**
  - fix accidental breakage due to library rename. Added tests.
  ([88593eec](https://github.com/angular/angular.dart/commit/88593eec6499f93765980087fcdf59a242ec9334))
  - fix breakage from commit 3fb218180b17bdc9808e575e3a9aaf9928fef28b
  ([5caadbf1](https://github.com/angular/angular.dart/commit/5caadbf10304c46da552f4fa118351a3d2de4571))
- **watch_group:** remove debugging print statement
  ([93c7b9af](https://github.com/angular/angular.dart/commit/93c7b9afbec1154e0869cb820210b401129ee4fe))


## Features

- **AstParser:** Made the AST parser private to the scope
  ([8944f0d9](https://github.com/angular/angular.dart/commit/8944f0d927a402f184160b6bfffdff664fb21ee4))
- **NgAnnotation:** Use `module` parameter to publish types.
  ([5ec7e831](https://github.com/angular/angular.dart/commit/5ec7e831052ce1fe5af70dc970941a4a884a9e02),
   [#779](https://github.com/angular/angular.dart/issues/779))
- **NgBaseCss:** Add NgBaseCss, which adds css files to all components
  ([06fc28a3](https://github.com/angular/angular.dart/commit/06fc28a319b9c0334a977c4a177348c6f6a3d003))
- **Scope:**
  - Allow turning emission of scope stats from console.
  ([18ecd950](https://github.com/angular/angular.dart/commit/18ecd950cd815677cba35e26eb6069da19d73300),
   [#836](https://github.com/angular/angular.dart/issues/836), [#857](https://github.com/angular/angular.dart/issues/857))
  - Mirror Scope methods in ngScope.
  ([277f2832](https://github.com/angular/angular.dart/commit/277f283258b7dcdb4994a1c78e6cee862386654d),
   [#850](https://github.com/angular/angular.dart/issues/850), [#858](https://github.com/angular/angular.dart/issues/858))
- **deploy:** Move all reflection behind separate import
  ([9bf04eba](https://github.com/angular/angular.dart/commit/9bf04eba808f7fc1f4e5285fad7feae360918718))
- **directives:** Add deprecated warning to applyAuthorStyle, resetStyleInheritance
  ([779ccb80](https://github.com/angular/angular.dart/commit/779ccb800d6db85100418c3e4a89a6003048bcab),
   [#838](https://github.com/angular/angular.dart/issues/838))
- **event_spec:** Add aaddTest to run an event test in an iit
  ([a5999863](https://github.com/angular/angular.dart/commit/a5999863f85bf172c75bd8f213d640b55f4a5cb8))
- **expect:**
  - toHaveText handles shadow DOM.  Deprecates JQuery.textWithShadow
  ([0384346d](https://github.com/angular/angular.dart/commit/0384346db3b715f6a67425d81825d2d20caae74f))
  - Move JQuery.text to Expect.toHaveText() and element.text
  ([dfe84d8f](https://github.com/angular/angular.dart/commit/dfe84d8f48e97db992d1b70382a2e531b91a1607))
- **http:** Allow overriding of recording URL.
  ([6ecf1d54](https://github.com/angular/angular.dart/commit/6ecf1d54a2c294035427fd3f274e1fb8e098f45e),
   [#872](https://github.com/angular/angular.dart/issues/872))
- **karma:** Allow Firefox to execute Karma tests
  ([4a6234b3](https://github.com/angular/angular.dart/commit/4a6234b350c7c25f7de45fceb19bceb31573cb30))
- **metadata extractor:** Cache the fieldMetadataExtractor for greater performance
  ([63c229c7](https://github.com/angular/angular.dart/commit/63c229c7f7dab901e650fb1c8b155d2bc006ca30))
- **ng-model:** support input type=date | datetime and all other date/time variants
  ([90e0e076](https://github.com/angular/angular.dart/commit/90e0e0761d2ed59b6a70ba31f9ceb741593bcb26),
   [#747](https://github.com/angular/angular.dart/issues/747))
- **ngElement:** add support for attributes
  ([581861e5](https://github.com/angular/angular.dart/commit/581861e5f428b2fe43356be012e1fe35b9f7499a))
- **ngRepeat:** make use of the new change detection
  ([09871cb2](https://github.com/angular/angular.dart/commit/09871cb29b5345d49929895b2a490360eee69244))
- **parser:** Add support for named arguments.
  ([18ceb4df](https://github.com/angular/angular.dart/commit/18ceb4dfa751615cecc73ff38d7bb1744b914c0a),
   [#762](https://github.com/angular/angular.dart/issues/762))
- **routing:** allow routing to view html
  ([cdc89c43](https://github.com/angular/angular.dart/commit/cdc89c43664c5d451ae92c83dd86922ccefd807c),
   [#425](https://github.com/angular/angular.dart/issues/425), [#908](https://github.com/angular/angular.dart/issues/908))
- **selector:** Collect bind- attributes.  More tests. Cleanup
  ([4707826b](https://github.com/angular/angular.dart/commit/4707826bd1dff114addb16372f58b7cfc19a8ffc))
- **template_cache_generator:** Support custom template path resolution
  ([f5bf7eff](https://github.com/angular/angular.dart/commit/f5bf7effaacb9d2423e033a8d7ade122eef6910c),
   [#923](https://github.com/angular/angular.dart/issues/923))
- **transformers:** Add angular transformers to pub for no-mirror code generation
  ([3fb21818](https://github.com/angular/angular.dart/commit/3fb218180b17bdc9808e575e3a9aaf9928fef28b))
- **travis:**
  - Firefox
  ([23a3e35f](https://github.com/angular/angular.dart/commit/23a3e35f22489f66692d0559421f33cff0926ab7),
   [#801](https://github.com/angular/angular.dart/issues/801))
  - Only submit if all the builds complete
  ([633d323d](https://github.com/angular/angular.dart/commit/633d323d672ee67ab2dbbd1dd6711a45aa86b0b5))
- **view factory:** Each css file has its own &lt;style&gt; tag
  ([4c81989f](https://github.com/angular/angular.dart/commit/4c81989fb404279c516ef11a5dccf067831732e0))


## Performance Improvements

- **DirtyCheckingChangeDetectorGroup:** Disable calls to _assertRecordsOk().
  ([d6b9bb70](https://github.com/angular/angular.dart/commit/d6b9bb708af9b44b59e482d1a8588c29a2a3608f),
   [#813](https://github.com/angular/angular.dart/issues/813))
- **compiler:** 45x speedup. Cache the attribute keys.
  ([556ef5cf](https://github.com/angular/angular.dart/commit/556ef5cfea30f210e5d56b42a054f46bbfdcf640))
- **element_binder:** use every rather than reduce
  ([27e2845d](https://github.com/angular/angular.dart/commit/27e2845d69597f2bfe4da7aa00cc8bc614e8ad19))


## Breaking Changes

- **NgAnnotation:** due to [5ec7e831](https://github.com/angular/angular.dart/commit/5ec7e831052ce1fe5af70dc970941a4a884a9e02),
  `publishTypes` parameter is removed.

  ```
  @NgDirective(
    publishTypes: [FooInt]
  )
  class Foo extends FooInt {
  }
  ```

  becomes

  ```
  @NgDirective(
    module: Foo.module,
    visibility: NgDirective.LOCAL_VISIBILITY
  )
  class Foo extends FooInt {
    module() => new Module()
      ..factory(FooInt,
                (i) => i.get(Foo),
                visibility: NgDirective.LOCAL_VISIBILITY)
  }
  ```

  Closes #779
- **bootstrap:** due to [155582d1](https://github.com/angular/angular.dart/commit/155582d199e25aa69ff803b228c3c3c0e5b9ac70),

  - import:
    - angular/angular_dynamic.dart -> angular/application_factory.dart
    - angular/angular_static.dart  -> angular/application_factory_static.dart

  - functions:
    - dynamicApplication()         -> applicationFactory()
    - staticApplication()          -> staticApplicationFactory()
- **forms:** due to [e5baa502](https://github.com/angular/angular.dart/commit/e5baa50235aa3ec53f00f87b86dab78ef5882900),
  All form code that uses control.valid_submit and control.invalid_submit will throw an error. Instead use control.validSubmit
  and control.invalidSubmit to checkthe submission validitity on a control.

  Closes #793
- **selector_spec:** due to [c03c538d](https://github.com/angular/angular.dart/commit/c03c538d31f01b7f543a03441fec613c2df2d641),
  This relaxs the assumption that directives will be created in the same order everywhere.
  For #801
- **nameing:** due to [f055ab6f](https://github.com/angular/angular.dart/commit/f055ab6f7c4fadfdbb6a46d8bc547b304586d95c)
  Closes #902

  BREAKING CHANGE: These are the renames

  - Concepts:
    ```
    - Filter                        -> Formatter
    ```

  - Importing:
    ```
    - angular/directive/ng_a.dart   -> angular/directive/a_href.dart
    - angular/filter/currency.dart  -> angular/formatter/currency.dart
    - angular/filter/date.dart      -> angular/formatter/date.dart
    - angular/filter/filter.dart    -> angular/formatter/filter.dart
    - angular/filter/json.dart      -> angular/formatter/json.dart
    - angular/filter/limit_to.dart  -> angular/formatter/limit_to.dart
    - angular/filter/lowercase.dart -> angular/formatter/lowercase.dart
    - angular/filter/module.dart    -> angular/formatter/module.dart
    - angular/filter/number.dart    -> angular/formatter/number.dart
    - angular/filter/order_by.dart  -> angular/formatter/order_by.dart
    - angular/filter/stringify.dart -> angular/formatter/stringify.dart
    - angular/filter/uppercase.dart -> angular/formatter/uppercase.dart
    ```

  - Types:
    ```
    - NgA                           -> AHref
    - NgAttachAware                 -> AttachAware
    - NgDetachAware                 -> DetachAware
    - NgShadowRootAware             -> ShadowRootAware
    - NgFilter                      -> Formatter
    - NgInjectableService           -> Injectable
    - AbstractNgAnnotation          -> Directive
    - AbstractNgFieldAnnotation     -> DirectiveAnnotation
    - NgComponent                   -> Component
    - NgController                  -> Controller
    - NgDirective                   -> Decorator
    - NgAnimate                     -> Animate
    - NgZone                        -> VmTurnZone
    - NgAnimationModule             -> AnimationModule
    - NgCoreModule                  -> CoreModule
    - NgCoreDomModule               -> CoreDomModule
    - NgAnimationDirective          -> NgAnimation
    - NgAnimationChildrenDirective  -> NgAnimationChildren
    - FilterMap                     -> FormatterMap
    - NgAttrMustacheDirective       -> AttrMustache
    - NgTextMustacheDirective       -> TextMustache
    ```

  - Constants
    ```
    - NgDirective.LOCAL_VISIBILITY           -> Directive.LOCAL_VISIBILITY
    - NgDirective.CHILDREN_VISIBILITY        -> Directive.CHILDREN_VISIBILITY
    - NgDirective.DIRECT_CHILDREN_VISIBILITY -> Directive.DIRECT_CHILDREN_VISIBILITY
    ```

<a name="v0.9.10"></a>
# v0.9.10 llama-magnetism (2014-03-20)

## Bug Fixes

- **Filter:** Add support for maps
  ([b32beecf](https://github.com/angular/angular.dart/commit/b32beecfeeecf40a05320b29e19b1572442542cf))
- **Jasmine:** Execute AfterEach methods
  ([71b2855c](https://github.com/angular/angular.dart/commit/71b2855ceab53ec1afa6b1b8950f3d12b58c4b2c))
- **NgModel:** ensure DOM value changes are only applied during scope.domWrite
  ([419e9189](https://github.com/angular/angular.dart/commit/419e9189b482fc054146b51a44613ff543efb485))
- **NgModelValidators:** ensure all validators can properly toggle attribute values
  ([98143034](https://github.com/angular/angular.dart/commit/98143034287f4a6adfd08f4064e4a751c569b108))
- **NodeAttrs:** lazy init of observer listeners
  ([144eb4c7](https://github.com/angular/angular.dart/commit/144eb4c76598a73a251477efc91c1460f5052937))
- **animation:** correct broken build http://dartbug.com/17634
  ([9891f333](https://github.com/angular/angular.dart/commit/9891f3339207e921a0a50cac3d855eb4606b41bb))
- **change_detection:**
  - should properly support objects with equality
   ([9b480dad](https://github.com/angular/angular.dart/commit/9b480dad5f9eaf86099c6c1760a837d1eb6d6442),
   [#735](https://github.com/angular/angular.dart/issues/735), [#670](https://github.com/angular/angular.dart/issues/670))
  - leaking watch records when removing deeply nested watch_groups
  ([1ba5befb](https://github.com/angular/angular.dart/commit/1ba5befba3392769752c1d163de7c691234fca15),
   [#700](https://github.com/angular/angular.dart/issues/700))
  - don't call reactionFn on deleted scope
  ([0aacdc4f](https://github.com/angular/angular.dart/commit/0aacdc4f73b79f874a78783308feea471279db0d))
- **compiler:** Remove the Block/BlockFactory typedefs
  ([9b790f49](https://github.com/angular/angular.dart/commit/9b790f490b16c2834177df75f235da8d3347aa64))
- **component:** revert regression of injecting Element/Node into Component
  ([d9fc724e](https://github.com/angular/angular.dart/commit/d9fc724e56e99b26192e41eaef46607760f4ac2a))
- **forms:**
  - ensure models are validated when validator attributes change
  ([0622f3a9](https://github.com/angular/angular.dart/commit/0622f3a969b99b06c5f07da10ceb756b720a3331))
  - consider forms as pristine only when all the inner models are non-dirty
  ([4458ce8e](https://github.com/angular/angular.dart/commit/4458ce8e0035f8250cc35ec02906f63ba33c8974))
  - store models instead of controls within the collection of errors
  ([2928ae71](https://github.com/angular/angular.dart/commit/2928ae71b694be5e2a47eaa2cdd1d602f8ae26e9))
- **i18n:** properly restore locale after test WARNING
  ([f16536ee](https://github.com/angular/angular.dart/commit/f16536eed937bcdb5421ac61059ad40fe58ed2ef))
- **jasmine syntax:** Drop the wrapFn concept and let `_specs.dart` handle the sync wrapper
  ([1e971e6b](https://github.com/angular/angular.dart/commit/1e971e6b7c65958bbf9a4779fbac944afaebb278))
- **jquery:** Deprecate renderedText() in favour of JQuery.textWithShadow()
  ([364d9ff7](https://github.com/angular/angular.dart/commit/364d9ff712a635cd3b0d86bff9e663105ffce86b))
- **ng-class:** remove previously registered watch
  ([8b54f5e6](https://github.com/angular/angular.dart/commit/8b54f5e6c8d99a4b9531edb78ec10e8177e53407),
   [#725](https://github.com/angular/angular.dart/issues/725))
- **ng-repeat:** should correctly handle detached state
  ([775bbce4](https://github.com/angular/angular.dart/commit/775bbce4060c3828c1cbaeffcb8fc4092f46868b),
   [#697](https://github.com/angular/angular.dart/issues/697))
- **ng-style:** watch in RO mode
  ([51ee3298](https://github.com/angular/angular.dart/commit/51ee32987464832ddca113528d899ea27f0b6f40),
   [#721](https://github.com/angular/angular.dart/issues/721))
- **presubmit:**
  - Set new token; correct env variable name
  ([53aeb4aa](https://github.com/angular/angular.dart/commit/53aeb4aaea69bcd0ca21e6430b02a50de997f991))
  - use https protocol for push
  ([a2845a50](https://github.com/angular/angular.dart/commit/a2845a50e680555f4ef129247d1d2045233a5f0f))
  - correct presubmit authentication
  ([8b430d10](https://github.com/angular/angular.dart/commit/8b430d100c6c99267c3459310a762e6e831b4727))
- **scope:**
  - allow concurrent fire/add/remove on listeners
  ([e6689e37](https://github.com/angular/angular.dart/commit/e6689e37c800682a81d7690c3b05baf732c307c6))
  - should allow removing listener during an event
  ([4662d494](https://github.com/angular/angular.dart/commit/4662d49477fdf0b5ef01f8d4f8aed8b87d77ea66),
   [#695](https://github.com/angular/angular.dart/issues/695))
  - add scope id for easier debugging.
  ([5a368087](https://github.com/angular/angular.dart/commit/5a36808736efae4760c8f9fdc5b291353ca9ec02))
- **tagging compiler:**
  - a text child after a directive child
  ([81030dde](https://github.com/angular/angular.dart/commit/81030dde483bf0b4bb943f31408733f3238286ee))
  - ancestor injectables
  ([81ad184d](https://github.com/angular/angular.dart/commit/81ad184d928625a97e15fd8baf3e6df21cf1efae))
  - Sibling templates
  ([167b4909](https://github.com/angular/angular.dart/commit/167b4909fca4c72a903ccc695043f6a13d1a4b98))
  - Transclusions with an existing ElementBinder
  ([0e4cb8ed](https://github.com/angular/angular.dart/commit/0e4cb8ed82f98e6a3e9dc2d131394a4d769cb0cc))
  - Empty transclusions
  ([b71a5009](https://github.com/angular/angular.dart/commit/b71a50092d6a529e21e06f4080bbe50873eac997))
- **zone:** Avoid silently ignoring uncaught exceptions by default.
  ([7bb1944e](https://github.com/angular/angular.dart/commit/7bb1944e3726dea221e6ab33d4bc6f1de6a364c8),
   [#710](https://github.com/angular/angular.dart/issues/710))

## Features

- **NgModel:** introduce parsers and formatters
  ([bed9fe15](https://github.com/angular/angular.dart/commit/bed9fe15f8b89b296a9b519268bd3e3c326b6265))
- **Scope:** Improve ScopeStats reporting
  ([1954e9e2](https://github.com/angular/angular.dart/commit/1954e9e293203466a50f3931126ebde0335b885d),
   [#744](https://github.com/angular/angular.dart/issues/744))
- **compiler:**
  - Make the TaggingCompiler the default compiler
  ([3ed50b5e](https://github.com/angular/angular.dart/commit/3ed50b5ebdf8013a3f9d354846770c1e9f75497a))
  - Tagging compiler
  ([59516afb](https://github.com/angular/angular.dart/commit/59516afb37d1dd33dbdca9e705646dad1afafd1d))
  - Initial TagggingCompiler implementation
  ([80163401](https://github.com/angular/angular.dart/commit/80163401e1524c2b5c90a8c0d66b263370a6c402))
  - ViewFactory now takes a list of ElementBinders
  ([eb559ad0](https://github.com/angular/angular.dart/commit/eb559ad05ca33e6c985ceed492f20c9b2a88c5b9))
  - Add an ElementBinder class and return it from Selector
  ([41bc9a40](https://github.com/angular/angular.dart/commit/41bc9a40a17521285eb7d342a5590c2a7b09be93))
- **core_dom:** introduce NgElement
  ([1afa0b61](https://github.com/angular/angular.dart/commit/1afa0b61da45038ea192f34208ffb9e2a6081fd9))
- **doc:**
  - Animation library documentation updates and fixes.
  ([613030a0](https://github.com/angular/angular.dart/commit/613030a04c584040a09cade196945fde9fa830cc),
   [#760](https://github.com/angular/angular.dart/issues/760))
  - Library description for angular.animate
  ([0576f278](https://github.com/angular/angular.dart/commit/0576f27841c8842b0d84bfae8c4b202c39833beb))
- **element binder:**
  - Make ElementBinder non-recursive and create an external tree
  ([811b4607](https://github.com/angular/angular.dart/commit/811b46073af9fe2f7e353ce1b811898c1557bad8))
  - ElementBinder.bind
  ([b1a518bd](https://github.com/angular/angular.dart/commit/b1a518bd678ab4a4d53f8915a9e3c34c87c5d3c1))
- **filters:** revert filter being restricted to top level
  ([66cda204](https://github.com/angular/angular.dart/commit/66cda2046ea84d29edd7a478509565989834e391))
- **forms:** append valid/invalid CSS classes for each validator on all controls
  ([574065f5](https://github.com/angular/angular.dart/commit/574065f5b8183f4b6d9ac7b66a2ae501a21ee2ac))
- **jasmine:** beforeEachModule syntax and injectifying its
  ([4019046f](https://github.com/angular/angular.dart/commit/4019046f4b56a629f6db71a6e1caff82b728940a),
   [#727](https://github.com/angular/angular.dart/issues/727))
- **jquery:** Add shadowRoot() and use it in templateurl_spec
  ([e1745c60](https://github.com/angular/angular.dart/commit/e1745c601a22030b4241a93589cb13a4935049d1))
- **mock zone:** isAsyncQueueEmpty
  ([c834837d](https://github.com/angular/angular.dart/commit/c834837dcb5b9220b1570c7f96785d763a7b0968))
- **mustache:** Move unobserved mustache attributes to the flush phase
  ([56647a36](https://github.com/angular/angular.dart/commit/56647a36d67fe3b4b28967a78b193e90e0a65152),
   [#734](https://github.com/angular/angular.dart/issues/734))
- **selector:** DirectiveSelector is real now: matchElement, matchText
  ([eb4422a9](https://github.com/angular/angular.dart/commit/eb4422a9a2d0d0dbdb2fb9d04fdcbcae99b65757))
- **spec:** Ignore ng-binding classes in html()
  ([441daf79](https://github.com/angular/angular.dart/commit/441daf79a4e3fca8f42379022f078327d4e69e59))
- **tagging compiler:**
  - Create fewer ElementBinder lists
  ([7e185219](https://github.com/angular/angular.dart/commit/7e185219a9a477330ea8d2074bd9dad385bedd4b))
  - Support comments
  ([6fe02a07](https://github.com/angular/angular.dart/commit/6fe02a07431231a39c6e174327b36533b91f0073))
- **travis:** Seperate Chrome and Dartium into two different jobs.
  ([7c5bdb01](https://github.com/angular/angular.dart/commit/7c5bdb01dae7933540679e070ace5dc9fe223cd2))
- **EventHandler** Add support for on-* style events
  ([c28e6a02](https://github.com/angular/angular.dart/commit/c28e6a02d7ec3386c856bd6aa79f8ddee2ff09b9))

<a name="v0.9.9"></a>
# v0.9.9 glutinous-waterfall (2014-03-10)


## Bug Fixes

- **DateFilter:**
  - should work on other locale
  ([d7e77de9](https://github.com/angular/angular.dart/commit/d7e77de92fd61fabd7842eb0acb4d9236935dd76),
   [#604](https://github.com/angular/angular.dart/issues/604))
  - fix a wrong type
  ([cec3edad](https://github.com/angular/angular.dart/commit/cec3edad1944a8411882b0a87ea6193c25513392),
   [#579](https://github.com/angular/angular.dart/issues/579))
- **Directive:** remove publishAs from NgDirective to avoid confusion.
  ([7ee587f6](https://github.com/angular/angular.dart/commit/7ee587f6f959d89cfdd87b0f615510405d693db9),
   [#396](https://github.com/angular/angular.dart/issues/396))
- **MetadataExtractor:** ignore typedefs
  ([37f1c321](https://github.com/angular/angular.dart/commit/37f1c32118383b250ba2db6f21adf1737beb2b0a),
   [#524](https://github.com/angular/angular.dart/issues/524))
- **NgAttachAware:** revert to original behavior and define stronger test
  ([500446d1](https://github.com/angular/angular.dart/commit/500446d1f6d548bbc007957017cf7cae74c7f30c))
- **NgAttrMustacheDirective:** support parsing of multiline attribute values
  ([a37e1576](https://github.com/angular/angular.dart/commit/a37e15761b5bbad2f32308ccd0f765bd977fb0ca))
- **NgComponent:**
  - Handle errors while loading CSS
  ([b5aa130f](https://github.com/angular/angular.dart/commit/b5aa130f68c589e2e4a8c6fad1dbd69078608be1),
   [#411](https://github.com/angular/angular.dart/issues/411))
  - Drop cssUrls, leaving cssUrl only
  ([92ed26fb](https://github.com/angular/angular.dart/commit/92ed26fb1a00a239c164428979a2f53226ae4b2c))
  - attach method was called earlier rathe then later.
  ([3c594130](https://github.com/angular/angular.dart/commit/3c594130589f43a6f82374a87bf498f2d5645ab5))
- **NgForm:**
  - always return the first matching control when using map notation on a NgForm instance
  ([95e66d6b](https://github.com/angular/angular.dart/commit/95e66d6bb28c3075952e31cdbce3c044ed00fc8f))
  - use map notation for controls and dot notation for instance properties
  ([0cc1217b](https://github.com/angular/angular.dart/commit/0cc1217b80ceb2b9dd383d0e51e128be40bec9d4))
- **NgModelValidators:** ensure that number input types render invalid when non-numeric characters are present
  ([476a8dbf](https://github.com/angular/angular.dart/commit/476a8dbfac40f695a02e49a8e76590135e5867d2))
- **NodeCursor:** Removes nodeList() in favor of current
  ([aaae1d60](https://github.com/angular/angular.dart/commit/aaae1d60832b331be62b0fd94c65935ce68b2856),
   [#644](https://github.com/angular/angular.dart/issues/644))
- **WatchGroup:** don't call reaction functions on removed WatchGroups
  ([a7cabe35](https://github.com/angular/angular.dart/commit/a7cabe35a0a8bd9288d517df3885245242da3676))
- **angular:** export GetterCache from dccd
  ([c1655e8c](https://github.com/angular/angular.dart/commit/c1655e8c51b1133da70f04e7630e733557806a9e))
- **binding:** call attach when attribute is not specified
  ([1cb8eb9f](https://github.com/angular/angular.dart/commit/1cb8eb9f135c55a75af2a0ada6401e5c8594b03b))
- **block_factory:**
  - should not load template or call onShadowRoot when scope is destroyed
  ([2e403504](https://github.com/angular/angular.dart/commit/2e403504845f2899dd8b80f424a68eeb1c0e3fe6))
  - should not call attach when scope is destroyed
  ([72708e33](https://github.com/angular/angular.dart/commit/72708e3337deb95a579cd8181a688e3e7859ebff))
- **bouncing_balls:** ball number can not go below 0
  ([6de4f810](https://github.com/angular/angular.dart/commit/6de4f810f4bcdaf639739a97816cac8006eb5faf))
- **change-detection:**
  - correctly process watch registration inside reaction FN.
  ([d6bc9ab8](https://github.com/angular/angular.dart/commit/d6bc9ab871490148f937f0587f2e9d16beca62ee))
  - Fix the handling of NaN & string values for maps
  ([156d6386](https://github.com/angular/angular.dart/commit/156d6386f45c4f6c4672432de28b1245da1c1515))
  - Fix for comparing string by value
  ([11f1bd87](https://github.com/angular/angular.dart/commit/11f1bd872a474bd2b99f40027003c356abff6e21))
  - reset next/prev on watchGroup.marker
  ([4dfa2676](https://github.com/angular/angular.dart/commit/4dfa267698b56017fae4b491b855767f030f3598))
  - delay processing watch registration inside reaction fn.
  ([cd4e2e3d](https://github.com/angular/angular.dart/commit/cd4e2e3d2dbab33e31ce1cfc3273e37d55ac9008))
  - remove memory leak, use iterator
  ([75fbded7](https://github.com/angular/angular.dart/commit/75fbded7ad2691eb4391c56a595ab488842a85ed))
  - remove memory leak
  ([847af41f](https://github.com/angular/angular.dart/commit/847af41fd66d9016e32cf5b3d8f86e91bae7e6d9))
  - corrected adding group to sibling which had children
  ([8583d08b](https://github.com/angular/angular.dart/commit/8583d08baf60ed63940b3ff38967877327ccf03d))
- **change-detector:** handle double.NAN for collections (in JS)
  ([07f9b240](https://github.com/angular/angular.dart/commit/07f9b240008a143964d29153589c078aa85ddd09))
- **compiler:**
  - don't wait indefinitly for non-null value on =>!
  ([5451d63d](https://github.com/angular/angular.dart/commit/5451d63d135b271a52af522343e67abfd30d7cb8))
  - ensure parent controllers are exposed within the scope of their children
  ([cad8cc4a](https://github.com/angular/angular.dart/commit/cad8cc4a64a223c677f420acb800da89b1d0061c),
   [#602](https://github.com/angular/angular.dart/issues/602))
  - support filters in attribute expressions
  ([8f020f99](https://github.com/angular/angular.dart/commit/8f020f998e8a4b7d5b595e5c44086fa2628fe8b3),
   [#571](https://github.com/angular/angular.dart/issues/571), [#580](https://github.com/angular/angular.dart/issues/580))
- **di:** Upgrade dependency of package di preventing problems with dart sdk 1.1 resolves #408
  ([1f85a8ce](https://github.com/angular/angular.dart/commit/1f85a8cee164d85d6eed43e7604a0190d1542d84),
   [#408](https://github.com/angular/angular.dart/issues/408), [#583](https://github.com/angular/angular.dart/issues/583))
- **dirty_checking_change_detector:** correctly truncate collection change record
  ([c1937b4e](https://github.com/angular/angular.dart/commit/c1937b4eab87e227d2aa3b126740c93a6c75a353),
   [#692](https://github.com/angular/angular.dart/issues/692))
- **doc:** Correct markdown for ElementProbe
  ([5783de44](https://github.com/angular/angular.dart/commit/5783de448333cfd0d408c4c9663f1cc7e32a6350))
  - Use a consistent name for the library
  ([3f541fa4](https://github.com/angular/angular.dart/commit/3f541fa49a9543e8d3c7a6c416b04934c591bf74))
- **doc-gen:**
  - add docviewer flags for generating the new angulardart docs
  ([99d9f2ae](https://github.com/angular/angular.dart/commit/99d9f2ae843fbda320f87e505aecb8ba2f2db4ed))
  - dartbug.com/16752
  ([9a1ef31d](https://github.com/angular/angular.dart/commit/9a1ef31d66f151f22b79893e11251a6780605257))
- **dynamic_parser:** Handle reserved words correctly
  ([271ecec0](https://github.com/angular/angular.dart/commit/271ecec05e21b1eddb7663dd8297ab4b9ead4d19),
   [#614](https://github.com/angular/angular.dart/issues/614))
- **eval access:** Do not crash on null cached value
  ([bbcbd3e7](https://github.com/angular/angular.dart/commit/bbcbd3e70f289c1fcc232a38ac89038f83342d3c),
   [#424](https://github.com/angular/angular.dart/issues/424))
- **forms:**
  - do not reset input fields on valid submission
  ([24e9c3dd](https://github.com/angular/angular.dart/commit/24e9c3dd3f1cc46bdb8092f6deac0e4ad8732c1d))
  - ensure fields, fieldsets & forms are marked as dirty when modified
  ([ad60d55a](https://github.com/angular/angular.dart/commit/ad60d55a2f8cdd6c7f0a246efdc79a5af85a833e))
  - treat <input> with no type as type="text"
  ([8f0a8a7f](https://github.com/angular/angular.dart/commit/8f0a8a7fe87517a65b2c5ed2857c90ea87898a0b))
- **generator:**
  - remove invalid sort on elements
  ([e2a00abe](https://github.com/angular/angular.dart/commit/e2a00abe371bb2d9d3c1d3c19849e075a32e92e4),
   [#554](https://github.com/angular/angular.dart/issues/554))
  - write files in sorted order for predictable tests
  ([79b7525a](https://github.com/angular/angular.dart/commit/79b7525a790ce73a50c2874e2f43110fbce61d16))
  - Write URI in sorted order to prevent SHA churn
  ([217839ef](https://github.com/angular/angular.dart/commit/217839ef3495506313a226681a6c10a52e71df0f))
- **http_spec:** implement lastModified getter
  ([e719e75e](https://github.com/angular/angular.dart/commit/e719e75e15ca01048d1212ec403b8ee5ba3bfa74))
- **introspection:**
  - Better error messages and checked mode support
  ([9ad2a686](https://github.com/angular/angular.dart/commit/9ad2a686860b21e555587dd2986ca77b969919cc))
  - Export all symbols. And a test.
  ([691c4cab](https://github.com/angular/angular.dart/commit/691c4cab02115963fa974e55f5ee8f196c2aef13))
  - warnings
  ([70d83c53](https://github.com/angular/angular.dart/commit/70d83c53c350920fc27942a9c3b4c83dff5c10b5),
   [#497](https://github.com/angular/angular.dart/issues/497))
- **ng-attr:** remove camel-cased dom attributes
  ([b5e45117](https://github.com/angular/angular.dart/commit/b5e45117c17fdd07d5db659815eb49c2dca17b84),
   [#567](https://github.com/angular/angular.dart/issues/567))
- **ng-class:** array syntax should not insert nulls
  ([b982e326](https://github.com/angular/angular.dart/commit/b982e326cd7d3fbd4e53fbe7b65ba9adc0f5cf64),
   [#513](https://github.com/angular/angular.dart/issues/513))
- **ng-event:** don't double digest
  ([c38989a4](https://github.com/angular/angular.dart/commit/c38989a4496e47813d77e3d0cc4868691af7e166))
- **ng-pluralize:** use ${..} to interpolate
  ([a630487d](https://github.com/angular/angular.dart/commit/a630487d302e396a920e02c8db5d256a81d3dd1a),
   [#572](https://github.com/angular/angular.dart/issues/572))
- **ng-value:** Add ng-value support for checked/radio/option
  ([8fc2c0f4](https://github.com/angular/angular.dart/commit/8fc2c0f49aabc53ee6240ad8063ecf6c9c8b8a1f))
- **ngControl:** unregister control from parent on detach
  ([4c9b8044](https://github.com/angular/angular.dart/commit/4c9b804454e3e0f0cb680d9359834692fc9ec304),
   [#684](https://github.com/angular/angular.dart/issues/684))
- **ngModel:**
  - ensure checkboxes and radio buttons are flagged as dirty when changed
  ([5766a6a1](https://github.com/angular/angular.dart/commit/5766a6a173dc1d65b9293fd5bd0bcbc21b0791ec),
   [#569](https://github.com/angular/angular.dart/issues/569), [#585](https://github.com/angular/angular.dart/issues/585))
  - process input type=number according to convention, using valueAsNumber
  ([cf0160b8](https://github.com/angular/angular.dart/commit/cf0160b8c316a39ac9d0fcce843c6f764429a1d4),
   [#574](https://github.com/angular/angular.dart/issues/574), [#577](https://github.com/angular/angular.dart/issues/577))
  - ensure validation occurs when the model value changes upon digest
  ([f34e0b31](https://github.com/angular/angular.dart/commit/f34e0b31a6f2f42457a6d1a1b5b5aaa7e2ef86fe))
  - evaluate user input using onInput instead of onKeyDown
  ([64442974](https://github.com/angular/angular.dart/commit/64442974157211b49bad6f28182a15aedd652efd))
- **ngShow:** Add/remove ng-hide class instead of ng-show class
  ([0b88d2e8](https://github.com/angular/angular.dart/commit/0b88d2e8102db8b89f38b00c277b9023b260285e),
   [#521](https://github.com/angular/angular.dart/issues/521))
- **package.json:** add repo, licenses and switch to devDependencies
  ([d099db59](https://github.com/angular/angular.dart/commit/d099db5944e2287fbf97a13b1aa73f8082652e09),
   [#544](https://github.com/angular/angular.dart/issues/544), [#545](https://github.com/angular/angular.dart/issues/545))
- **parser:**
  - disallow filters in a chain and inside expressions
  ([5bcea649](https://github.com/angular/angular.dart/commit/5bcea6492f6d0fd39ba316fa3b241c50bb94de8d))
  - Correctly distinguish NoSuchMethodError
  ([bde52abe](https://github.com/angular/angular.dart/commit/bde52abebd026d0226b90bd84380a24d7a8eab4e))
- **parser, scope:** Allow nulls in binary operations.
  ([59811752](https://github.com/angular/angular.dart/commit/59811752f57a87fe8f6a6313fd8764f4d45b4c5c),
   [#646](https://github.com/angular/angular.dart/issues/646))
- **parser_generator:** use parser getter/setter generator instead
  ([42c8d8c8](https://github.com/angular/angular.dart/commit/42c8d8c89087932c1be19965b6b649075919287d))
- **readme:** Read the Travis badge
  ([6fe5692b](https://github.com/angular/angular.dart/commit/6fe5692b58e71c86f2001659b9f8f78016d74ebf))
- **routing:** correctly scope routing to ng-app
  ([3ab250a7](https://github.com/angular/angular.dart/commit/3ab250a706c84542c9e618d9e98eea81d99a5d22))
- **scope:**
  - fix null comparisons
  ([fb0fe0e3](https://github.com/angular/angular.dart/commit/fb0fe0e3f8adb24312646ee9bd01502be605ae7e),
   [#646](https://github.com/angular/angular.dart/issues/646))
  - incorrect stage message
  ([2169a950](https://github.com/angular/angular.dart/commit/2169a950404bf8c68a9f2d239580a27caf1d9779))
  - correctly setup NgZone onError handler with ExceptionHandler
  ([e8bc580c](https://github.com/angular/angular.dart/commit/e8bc580cfb2d3995fd113916894b26e98d07b8d6))
  - return null to supress an analyzer error
  ([fad457e9](https://github.com/angular/angular.dart/commit/fad457e96f2c6ee17e6ce3c14a499e230e630ca5),
   [#594](https://github.com/angular/angular.dart/issues/594))
  - correctly handle canceled listeners bookkeeping
  ([259ac5b1](https://github.com/angular/angular.dart/commit/259ac5b147652522a92b40a12298891dd491c9a7))
  - should not trigger assertions on fork
  ([484f03dc](https://github.com/angular/angular.dart/commit/484f03dcce7bdc20a101d795d85eee58484d02c9))
  - skip scopes without event on broadcast
  ([ae22a6f3](https://github.com/angular/angular.dart/commit/ae22a6f3f82e321a923a64a573b000485a3fd70e))
  - createChild now requires context
  ([6722e1a4](https://github.com/angular/angular.dart/commit/6722e1a45bb65a86211c2eb3cef2a264bc7e871e))
  - improve error msg on unstable model
  ([c9bf23a0](https://github.com/angular/angular.dart/commit/c9bf23a095cc1863b7075fa7bd2fd6bb6fbc9d38))
  - allow sending emit/broadcast when no on()
  ([d9dfe0f8](https://github.com/angular/angular.dart/commit/d9dfe0f830f2df3fb1e811d6891c684f5080ee7c))
  - Use Iterable instead of List
  ([951fa178](https://github.com/angular/angular.dart/commit/951fa1783afa65f410a2b82249850eed458ed294),
   [#565](https://github.com/angular/angular.dart/issues/565))
  - use correct filters when digesting scope tree
  ([95f6503f](https://github.com/angular/angular.dart/commit/95f6503f1390159eeedfe6d14ea60ec0d70b9381))
- **select:** Corrected NPE if select multiple nested in ng-if
  ([6228692b](https://github.com/angular/angular.dart/commit/6228692bbf0cc269999cb3cb77374bb815120a4b),
   [#428](https://github.com/angular/angular.dart/issues/428))
- **selector:** Allow two directives with the same selector
  ([467b935e](https://github.com/angular/angular.dart/commit/467b935ee93a87913cfc8a025973ffd00e31bf2d),
   [#471](https://github.com/angular/angular.dart/issues/471), [#481](https://github.com/angular/angular.dart/issues/481))
- **template_cache_generator:** support traversal of partial files
  ([f918d4dd](https://github.com/angular/angular.dart/commit/f918d4dd9ac7c777b0197a700fd6af58103e4129),
   [#662](https://github.com/angular/angular.dart/issues/662))
- **watch_group:** prevent removed watches from firing
  ([a558a26f](https://github.com/angular/angular.dart/commit/a558a26ffdafddec986f4fafab5bbe55ef6b0b48))


## Features

- **Animation:** Animation for AngularDart.
  ([5a36e773](https://github.com/angular/angular.dart/commit/5a36e773482bce7b4a797613516a56d1b628035b),
   [#635](https://github.com/angular/angular.dart/issues/635))
  - introduce ng-animate and ng-animate-children.
  ([88d2af6f](https://github.com/angular/angular.dart/commit/88d2af6f81b11518cf359b85066a0f0677140b16),
   [#661](https://github.com/angular/angular.dart/issues/661))
- **NgForm:** provide access to non-uniquely named control instances via form.controls
  ([6099c037](https://github.com/angular/angular.dart/commit/6099c0373f3b59bbeea8c1dfd585bbb6a50a1833),
   [#642](https://github.com/angular/angular.dart/issues/642))
- **NgModelValidator:**
  - perform number validations on range input elements
  ([710cd5b0](https://github.com/angular/angular.dart/commit/710cd5b0ff0a7b2dfe71536e3455523d3c939b5f),
   [#682](https://github.com/angular/angular.dart/issues/682))
  - provide support for min and max validations on number input fields
  ([7dc55fbf](https://github.com/angular/angular.dart/commit/7dc55fbff47b99eb5e64cd63192a7a3e7b8eae88))
- **Scope:** Brand new scope implementation which takes advantage of the new change detection
  ([390aea5e](https://github.com/angular/angular.dart/commit/390aea5ee4318855584911afb2ce4a2b86fc718c))
- **block:**
  - Kill block events.
  ([27308e9e](https://github.com/angular/angular.dart/commit/27308e9e334477370a3417535af92540bfa3d24f),
   [#659](https://github.com/angular/angular.dart/issues/659))
  - Chain ElementProbe parents; add to shadowRoot
  ([b77534e4](https://github.com/angular/angular.dart/commit/b77534e4cc8ed1996bfd1d5cc27f07e81748fb95),
   [#625](https://github.com/angular/angular.dart/issues/625), [#630](https://github.com/angular/angular.dart/issues/630))
- **blockhole:** Change blockhole to have the insert / remove / move methods.
  ([c1e70ce8](https://github.com/angular/angular.dart/commit/c1e70ce8e0c8c510f0dee4de043e78f61c3e9c3d),
   [#689](https://github.com/angular/angular.dart/issues/689))
- **change-detection:** Initial implementation of new change-detection algorithm.
  ([d0b2dd95](https://github.com/angular/angular.dart/commit/d0b2dd957b02215671f9b2b8d8f30c05879ad8c5))
- **doc:** Documentation generation for NgAnimateModule.
  ([a029ac5e](https://github.com/angular/angular.dart/commit/a029ac5edf7e1226dc2a04fc4d55e41bceb26d36))
- **doc-gen:** Use new docviewer for generating docs
  ([67fcafff](https://github.com/angular/angular.dart/commit/67fcafff85d3ff1c32b610e247aa672d6eb91496))
- **forms:**
  - use the ng-form attribute as the name of the inner form
  ([8b989b6d](https://github.com/angular/angular.dart/commit/8b989b6d5866eea45a3e867e3b3a56ac114ff59e),
   [#681](https://github.com/angular/angular.dart/issues/681))
  - introduce the control.hasError helper method
  ([7b75af44](https://github.com/angular/angular.dart/commit/7b75af44bc4a998c83bd0a5a0339984e74766f55))
  - expose getters for submitted, valid_submit and invalid_submit
  ([9daaa0fc](https://github.com/angular/angular.dart/commit/9daaa0fcd5898ead0a62e577001dd2568eb17dfb),
   [#601](https://github.com/angular/angular.dart/issues/601))
  - provide support for touch and untouched control flags
  ([634c62b1](https://github.com/angular/angular.dart/commit/634c62b1d9d77e3d3413934b068c312afa637b43),
   [#591](https://github.com/angular/angular.dart/issues/591))
  - generate ng-submit-valid / ng-submit-invalid CSS classes upon form submission
  ([4bf9447c](https://github.com/angular/angular.dart/commit/4bf9447cc64650d6c73b66c844fb5396b4a2ae27))
  - provide support for reseting forms, fieldsets and models
  ([c75202d5](https://github.com/angular/angular.dart/commit/c75202d5d7ecabd01366f2198e0c0c3b5c087e59))
  - add a test for input type="search"
  ([87a60d1f](https://github.com/angular/angular.dart/commit/87a60d1f43b8a4f4e7e31ca179e9de8cd2d94ce9))
- **ngModel:**
  - Treat the values of number and range inputs as numbers
  ([e703bd1b](https://github.com/angular/angular.dart/commit/e703bd1bc75f4d6420afad0bbb975b3e23672ff8),
   [#527](https://github.com/angular/angular.dart/issues/527))
  - support the input[type="search"] field
  ([ff736d92](https://github.com/angular/angular.dart/commit/ff736d92a16bc06b848d0be4282dbf8f80b831c5),
   [#466](https://github.com/angular/angular.dart/issues/466))
- **ngRepeat:** add track by support
  ([07566457](https://github.com/angular/angular.dart/commit/07566457720c1fc9631808432a2cb39c2edeccb8),
   [#277](https://github.com/angular/angular.dart/issues/277), [#507](https://github.com/angular/angular.dart/issues/507))
- **routing:** new DSL and deferred module loading
  ([3db9ddd3](https://github.com/angular/angular.dart/commit/3db9ddd3d2ab9aa97dfe2d0bdd5631190f6c6a56))
- **sanitization:** make NodeValidator injectable
  ([47ab48ad](https://github.com/angular/angular.dart/commit/47ab48adf5cbcba6e7a2c8607b1ce1be29014a83),
   [#490](https://github.com/angular/angular.dart/issues/490), [#498](https://github.com/angular/angular.dart/issues/498))
- **scope:**
  - add scope digest stat collection
  ([c066923d](https://github.com/angular/angular.dart/commit/c066923d8be4198e0692b22c83b11aee81fed3ee),
   [#609](https://github.com/angular/angular.dart/issues/609))
  - add internal streams consistency checks
  ([65213c30](https://github.com/angular/angular.dart/commit/65213c30e2e34ed39577f0785f3c80a297829c43))
  - Experimental: Watch once, watch not null expressions
  ([84762b10](https://github.com/angular/angular.dart/commit/84762b1028ef7e334519a5b322adf768dacd00c9))
  - Allow expressions on non-scope context
  ([e4dfb469](https://github.com/angular/angular.dart/commit/e4dfb469c5e322ad9b90bad0ec40ce54626a24c0))
- **scope2:** Basic implementation of Scope v2
  ([3bde820e](https://github.com/angular/angular.dart/commit/3bde820e6cf0819d02434afb41479552487323e7))
- **scripts:** robust authors.sh
  ([ffe43c6c](https://github.com/angular/angular.dart/commit/ffe43c6cceafcdd8c6ced170e99bbd7b50ec40fb),
   [#586](https://github.com/angular/angular.dart/issues/586))
- **zone:** Allow escaping of auto-digest mechanism.
  ([2df2660d](https://github.com/angular/angular.dart/commit/2df2660d876ee3cc60047eb806704edc99c41dbf),
   [#557](https://github.com/angular/angular.dart/issues/557))


## Performance Improvements

- **change-detection:** optimize DirtyCheckingChangeDetector.collectChanges()
  ([4453e3e8](https://github.com/angular/angular.dart/commit/4453e3e8a5602e6095cecc899d8a32594ea48b4e),
   [#693](https://github.com/angular/angular.dart/issues/693))
- **scope:**
  - optim createChild() which always append at the end
  ([78f0c826](https://github.com/angular/angular.dart/commit/78f0c82680123f146b4e430db46bb2f59b214be1),
   [#626](https://github.com/angular/angular.dart/issues/626))
  - misc optimizations
  ([7f36a8e1](https://github.com/angular/angular.dart/commit/7f36a8e1557cd55e7379b1750fd4029e7eddd91b),
   [#610](https://github.com/angular/angular.dart/issues/610))


## BREAKING CHANGES

0.9.9 contains a major overhaul to the change-detection algorithm which is used behind the scenes
during scope digests. As a result, much of the scope API has changed to facilitate this new feature.

The biggest change is how scope properties are assigned on the scope. With earlier versions of
AngularDart, the scope object itself was treated like a map and any property accessed using square
brackets would either set or get the associated value. With 0.9.9 this will not produce the same
effect. Instead all scope property getter and setter operations are to be facilitated within the
scope.context member. So in other words, all the scope property reading and writing that was done
in earlier versions is now done the same way, but on the `scope.context` member.

```dart
// < 0.9.9
scope['prop'] = 'value'; //set
scope['prop']; //get

// >= 0.9.9
scope.context['prop'] = 'value'; //set
scope.context['prop']; //get
```

### Breaking Changes to the Scope API

#### 1. scope.$watch() is now scope.watch()
```dart
//old code
scope.$watch('a.b.c', () {});

//new code (no more $ prefixing)
scope.watch('a.b.c', (value, previous) {});
```

#### 2. scope context changes
```dart
//old code
scope.$watch(() => o.foo; () {});

//new code (notice the context property)
scope.watch('foo', (value, _) {}, context: o);
```

#### 3. watch de-registration
```dart
//old code
var stopWatch = scope.$watch(...);
stopWatch();

//new code
Watch watch = scope.watch(...);
watch.remove();
```

#### 4. Replace scope-level digests
```dart
//old code
scope.$digest();

//new code
scope.rootScope.apply();

//Digest is now split between digest/flush so we need apply to call them both.
```

#### 5. Changes to scope event listeners
```dart
//old code
scope.$on('foo', (e, data) {});

//new code
scope.on('foo').listen((e) {var data = e.data;});


//old code
scope.$on('foo', (e, a, b, c) {});

//new code
scope.on('foo').listen((e) {MyEvent data = e.data;});


//old code
scope.$emit('foo', [a]);

//new code
scope.emit('foo', a);


//old code
scope.$emit('foo', [a, b ,c]);

//new code
scope.emit('foo', new MyEvent(a, b, c));
```

#### 6. Creating new scopes
```dart
//old code
scope.$new();

//new code
scope.createChild(new PrototypeMap(scope.context)));

//We have plans to allow any object to be the context.
//The PrototypeMap is a way to maintain consistent behavior.
```

#### 7. EvalAsync
```dart
//old code
scope.$evalAsync(() => null);

//new code
scope.runAsync(() => null);


//old code
scope.$evalAsync(
    () => null,
    outsideDigest: true);

//new code
scope.domRead(() => null);
```

#### 8. scope.$$verifyDigestWillRun() has been removed
There is currently no replacement. We feel that we have the zone under control and there is no need for this method any more.

#### 9. scope.$disabled has been removed
There is currently no replacement.

#### 10. Watching collections
```dart
//old code
scope.$watchSet(['ctrl.foo', 'ctrl.bar'], (values) {...});

//new code
scope.watch('[ctrl.foo, ctrl.bar]', (vars, _) {
  var ctrlFoo = vars[0];
  var ctrlBar = vars[1];
});
```



<a name="v0.9.8"></a>
# v0.9.8 cozy-porcupine (2014-02-19)


## Bug Fixes

- **DateFilter:** fix a wrong type
  ([cec3edad](https://github.com/angular/angular.dart/commit/cec3edad1944a8411882b0a87ea6193c25513392),
   [#579](https://github.com/angular/angular.dart/issues/579))
- **compiler:** support filters in attribute expressions
  ([8f020f99](https://github.com/angular/angular.dart/commit/8f020f998e8a4b7d5b595e5c44086fa2628fe8b3),
   [#571](https://github.com/angular/angular.dart/issues/571), [#580](https://github.com/angular/angular.dart/issues/580))
- **di:** Upgrade dependency of package di preventing problems with dart sdk 1.1 resolves #408
  ([1f85a8ce](https://github.com/angular/angular.dart/commit/1f85a8cee164d85d6eed43e7604a0190d1542d84),
   [#408](https://github.com/angular/angular.dart/issues/408), [#583](https://github.com/angular/angular.dart/issues/583))
- **doc-gen:** dartbug.com/16752
  ([9a1ef31d](https://github.com/angular/angular.dart/commit/9a1ef31d66f151f22b79893e11251a6780605257))
- **generator:** remove invalid sort on elements
  ([e2a00abe](https://github.com/angular/angular.dart/commit/e2a00abe371bb2d9d3c1d3c19849e075a32e92e4),
   [#554](https://github.com/angular/angular.dart/issues/554))
- **ng-attr:** remove camel-cased dom attributes
  ([b5e45117](https://github.com/angular/angular.dart/commit/b5e45117c17fdd07d5db659815eb49c2dca17b84),
   [#567](https://github.com/angular/angular.dart/issues/567))
- **ng-pluralize:** use ${..} to interpolate
  ([a630487d](https://github.com/angular/angular.dart/commit/a630487d302e396a920e02c8db5d256a81d3dd1a),
   [#572](https://github.com/angular/angular.dart/issues/572))
- **ng-value:** Add ng-value support for checked/radio/option
  ([8fc2c0f4](https://github.com/angular/angular.dart/commit/8fc2c0f49aabc53ee6240ad8063ecf6c9c8b8a1f))
- **ngModel:**
  - ensure checkboxes and radio buttons are flagged as dirty when changed
  ([5766a6a1](https://github.com/angular/angular.dart/commit/5766a6a173dc1d65b9293fd5bd0bcbc21b0791ec),
   [#569](https://github.com/angular/angular.dart/issues/569), [#585](https://github.com/angular/angular.dart/issues/585))
  - process input type=number according to convention, using valueAsNumber
  ([cf0160b8](https://github.com/angular/angular.dart/commit/cf0160b8c316a39ac9d0fcce843c6f764429a1d4),
   [#574](https://github.com/angular/angular.dart/issues/574), [#577](https://github.com/angular/angular.dart/issues/577))
  - ensure validation occurs when the model value changes upon digest
  ([f34e0b31](https://github.com/angular/angular.dart/commit/f34e0b31a6f2f42457a6d1a1b5b5aaa7e2ef86fe))
- **ngShow:** Add/remove ng-hide class instead of ng-show class
  ([0b88d2e8](https://github.com/angular/angular.dart/commit/0b88d2e8102db8b89f38b00c277b9023b260285e),
   [#521](https://github.com/angular/angular.dart/issues/521))
- **package.json:** add repo, licenses and switch to devDependencies
  ([d099db59](https://github.com/angular/angular.dart/commit/d099db5944e2287fbf97a13b1aa73f8082652e09),
   [#544](https://github.com/angular/angular.dart/issues/544), [#545](https://github.com/angular/angular.dart/issues/545))
- **scope:** Use Iterable instead of List
  ([951fa178](https://github.com/angular/angular.dart/commit/951fa1783afa65f410a2b82249850eed458ed294),
   [#565](https://github.com/angular/angular.dart/issues/565))


## Features

- **forms:**
  - generate ng-submit-valid / ng-submit-invalid CSS classes upon form submission
  ([4bf9447c](https://github.com/angular/angular.dart/commit/4bf9447cc64650d6c73b66c844fb5396b4a2ae27))
  - provide support for reseting forms, fieldsets and models
  ([c75202d5](https://github.com/angular/angular.dart/commit/c75202d5d7ecabd01366f2198e0c0c3b5c087e59))
- **ngModel:** Treat the values of number and range inputs as numbers
  ([e703bd1b](https://github.com/angular/angular.dart/commit/e703bd1bc75f4d6420afad0bbb975b3e23672ff8),
   [#527](https://github.com/angular/angular.dart/issues/527))


## Breaking Changes
- **ng-attr**
  - Due to ([b5e45117](https://github.com/angular/angular.dart/commit/b5e45117c17fdd07d5db659815eb49c2dca17b84),
    mappings in annotations must use snake-case-names instead of
    camelCaseNames.   To migrate your code, follow the example below:

	Before:

        @NgComponent(
            // …
            map: const {
              'domAttributeName': '=>fieldSetter'
            }
        )
        class MyComponent { …

	After:

        @NgComponent(
            // …
            map: const {
              'dom-attribute-name': '=>fieldSetter'
            }
        )
        class MyComponent { …



<a name="v0.9.7"></a>
# v0.9.7 pachyderm-moisturization (2014-02-10)


## Bug Fixes

- **MetadataExtractor:** ignore typedefs
  ([37f1c321](https://github.com/angular/angular.dart/commit/37f1c32118383b250ba2db6f21adf1737beb2b0a),
   [#524](https://github.com/angular/angular.dart/issues/524))
- **NgAttrMustacheDirective:** support parsing of multiline attribute values
  ([a37e1576](https://github.com/angular/angular.dart/commit/a37e15761b5bbad2f32308ccd0f765bd977fb0ca))
- **NgComponent:**
  - Handle errors while loading CSS
  ([b5aa130f](https://github.com/angular/angular.dart/commit/b5aa130f68c589e2e4a8c6fad1dbd69078608be1),
   [#411](https://github.com/angular/angular.dart/issues/411))
  - Drop cssUrls, leaving cssUrl only
  ([92ed26fb](https://github.com/angular/angular.dart/commit/92ed26fb1a00a239c164428979a2f53226ae4b2c))
- **eval access:** Do not crash on null cached value
  ([bbcbd3e7](https://github.com/angular/angular.dart/commit/bbcbd3e70f289c1fcc232a38ac89038f83342d3c),
   [#424](https://github.com/angular/angular.dart/issues/424))
- **forms:** ensure fields, fieldsets & forms are marked as dirty when modified
  ([ad60d55a](https://github.com/angular/angular.dart/commit/ad60d55a2f8cdd6c7f0a246efdc79a5af85a833e))
- **generator:**
  - write files in sorted order for predictable tests
  ([79b7525a](https://github.com/angular/angular.dart/commit/79b7525a790ce73a50c2874e2f43110fbce61d16))
  - Write URI in sorted order to prevent SHA churn
  ([217839ef](https://github.com/angular/angular.dart/commit/217839ef3495506313a226681a6c10a52e71df0f))
- **input:** treat `<input>` with no type as type="text"
  ([8f0a8a7f](https://github.com/angular/angular.dart/commit/8f0a8a7fe87517a65b2c5ed2857c90ea87898a0b))
- **ng-class:** array syntax should not insert nulls
  ([b982e326](https://github.com/angular/angular.dart/commit/b982e326cd7d3fbd4e53fbe7b65ba9adc0f5cf64),
   [#513](https://github.com/angular/angular.dart/issues/513))
- **ngModel:** evaluate user input using onInput instead of onKeyDown
  ([64442974](https://github.com/angular/angular.dart/commit/64442974157211b49bad6f28182a15aedd652efd))
- **parser:**
  - disallow filters in a chain and inside expressions
  ([5bcea649](https://github.com/angular/angular.dart/commit/5bcea6492f6d0fd39ba316fa3b241c50bb94de8d))
  - Correctly distinguish NoSuchMethodError
  ([bde52abe](https://github.com/angular/angular.dart/commit/bde52abebd026d0226b90bd84380a24d7a8eab4e))
- **scope:** use correct filters when digesting scope tree
  ([95f6503f](https://github.com/angular/angular.dart/commit/95f6503f1390159eeedfe6d14ea60ec0d70b9381))
- **select:** Corrected NPE if select multiple nested in ng-if
  ([6228692b](https://github.com/angular/angular.dart/commit/6228692bbf0cc269999cb3cb77374bb815120a4b),
   [#428](https://github.com/angular/angular.dart/issues/428))
- **selector:** Allow two directives with the same selector
  ([467b935e](https://github.com/angular/angular.dart/commit/467b935ee93a87913cfc8a025973ffd00e31bf2d),
   [#471](https://github.com/angular/angular.dart/issues/471), [#481](https://github.com/angular/angular.dart/issues/481))


## Features

- **forms:** add a test for input type="search"
  ([87a60d1f](https://github.com/angular/angular.dart/commit/87a60d1f43b8a4f4e7e31ca179e9de8cd2d94ce9))
- **ngRepeat:** add track by support
  ([07566457](https://github.com/angular/angular.dart/commit/07566457720c1fc9631808432a2cb39c2edeccb8),
   [#277](https://github.com/angular/angular.dart/issues/277), [#507](https://github.com/angular/angular.dart/issues/507))
- **routing:** new DSL and deferred module loading
  ([3db9ddd3](https://github.com/angular/angular.dart/commit/3db9ddd3d2ab9aa97dfe2d0bdd5631190f6c6a56))
- **sanitization:** make NodeValidator injectable
  ([47ab48ad](https://github.com/angular/angular.dart/commit/47ab48adf5cbcba6e7a2c8607b1ce1be29014a83),
   [#490](https://github.com/angular/angular.dart/issues/490), [#498](https://github.com/angular/angular.dart/issues/498))


<a name="v0.9.6"></a>
# v0.9.6 fluffy-freezray (2014-02-03)

### WARNING

We reserve the right to change the APIs in v0.9.x versions.

## Bug Fixes

- **Directive:** remove publishAs from NgDirective to avoid confusion."
  ([7ee587f6](https://github.com/angular/angular.dart/commit/7ee587f6f959d89cfdd87b0f615510405d693db9),
   [#396](https://github.com/angular/angular.dart/issues/396))
- **NgAttachAware:** revert to original behavior and define stronger test
  ([500446d1](https://github.com/angular/angular.dart/commit/500446d1f6d548bbc007957017cf7cae74c7f30c))
- **NgComponent:** attach method was called earlier rathe then later.
  ([3c594130](https://github.com/angular/angular.dart/commit/3c594130589f43a6f82374a87bf498f2d5645ab5))
- **doc:** Using a consistent name for the library
  ([3f541fa4](https://github.com/angular/angular.dart/commit/3f541fa49a9543e8d3c7a6c416b04934c591bf74))
- **routing:** correctly scope routing to ng-app
  ([3ab250a7](https://github.com/angular/angular.dart/commit/3ab250a706c84542c9e618d9e98eea81d99a5d22))


## Features

- **change-detection:** Initial implementation of new change-detection algorithm.
  ([d0b2dd95](https://github.com/angular/angular.dart/commit/d0b2dd957b02215671f9b2b8d8f30c05879ad8c5))
- **ngModel:** support the input[type="search"] field
  ([ff736d92](https://github.com/angular/angular.dart/commit/ff736d92a16bc06b848d0be4282dbf8f80b831c5),
   [#466](https://github.com/angular/angular.dart/issues/466))


<a name="v0.9.5"></a>
# v0.9.5 badger-magic (2014-01-27)

### WARNING

We reserve the right to change the APIs in v0.9.x versions.

## Bug Fixes

- **Directive:** remove publishAs from NgDirective to avoid confusion.
  ([c48433e0](https://github.com/angular/angular.dart/commit/c48433e0350d4b374614eef8a0c9036805535dcb))
- **directive:** call attach method ofter all bindings execute
  ([11b38bae](https://github.com/angular/angular.dart/commit/11b38bae4bd45631c178adf4e0b26b1272f7d289))
- **directives:** cssUrl in NgComponent
  ([952496b0](https://github.com/angular/angular.dart/commit/952496b00772d1984ebb8ae6c1490333cf6ba2f2))
- **docs:** correct typo
  ([4494ce70](https://github.com/angular/angular.dart/commit/4494ce708609c4ceb372d22ffacbe2652e9241b5))
- **expression_extractor:** implemented support for wildcard attr selector
  ([1e403447](https://github.com/angular/angular.dart/commit/1e403447d80ac748533075f654b9450f4590019c),
   [#447](https://github.com/angular/angular.dart/issues/447))
- **generator:** Avoid compile-time filter map querying when generating static parser.
  ([522ba49c](https://github.com/angular/angular.dart/commit/522ba49cdb371d2036a749ddef6fc8b07721a581))
- **ng-model:** Allow ng-required to work on non-strings.
  ([a7c3a8d8](https://github.com/angular/angular.dart/commit/a7c3a8d8da7daa4a4a46fbc7475ea412c5113c99))
- **parser:** Workaround dart2js bugs in latest version of Dart SDK 1.2.
  ([dddc3c83](https://github.com/angular/angular.dart/commit/dddc3c832489199444e068d966a928295a9d2512))
- **scope:** honor $skipAutoDigest on non-root scopes
  ([7265ef7a](https://github.com/angular/angular.dart/commit/7265ef7a897be00743db9e04523188969e9f0303))
- **todo:** Fixing some dart2js compilation issues for todo demo
  ([b8e97d9e](https://github.com/angular/angular.dart/commit/b8e97d9ec31e64a68d6d3d17687a233872f1e21b),
   [#453](https://github.com/angular/angular.dart/issues/453))


## Features

- **core:** provide support to define the same selector on multiple directives
  ([dd356539](https://github.com/angular/angular.dart/commit/dd356539eb9749156755c42333df51ee858bf174))
- **directive:** Add ng-attr-* interpolation support
  ([aeb5538e](https://github.com/angular/angular.dart/commit/aeb5538e2d4634b966467a4f90f0a5ac8b63dd4e))
- **directives:** Add support for contenteditable with ng-model
  ([715d3d1e](https://github.com/angular/angular.dart/commit/715d3d1ee856c961c697217f16c68bca74ef6d92))
- **expression_extractor:** Add source path to source crawler
  ([6597f73f](https://github.com/angular/angular.dart/commit/6597f73f6e944f1b2f5b171b911d094ba6600e2c))
- **forms:**
  - provide support for parent form communication
  ([6778b62e](https://github.com/angular/angular.dart/commit/6778b62e0c8c5cafa273f1fca68bf395870c9205))
  - add support for validation handling for multiple error types
  ([d3ed15cb](https://github.com/angular/angular.dart/commit/d3ed15cb7af5179962aa6cb9dfe572eb7451545f))
  - provide support for controls and state flags
  ([d1d86380](https://github.com/angular/angular.dart/commit/d1d863800c3fadb68750eefe2c9244ad68f6cc7e))
- **helloworld:** MirrorsUsed
  ([73b0dca8](https://github.com/angular/angular.dart/commit/73b0dca8dd82012a3396213bf7addf4143bba704))
- **js size:** Add a default @MirrorsUsed to Angular.
  ([1fd1bd07](https://github.com/angular/angular.dart/commit/1fd1bd07d5f202c8d96db511d76db0c3ff6d63ed),
   [#409](https://github.com/angular/angular.dart/issues/409))
- **mock:** support for JSON in HttpBackend
  ([9d09a162](https://github.com/angular/angular.dart/commit/9d09a1628b2c01836efe1d41c403d2a9464d3578),
   [#236](https://github.com/angular/angular.dart/issues/236))
- **ngModel:** provide support for custom validation handlers
  ([e01d5fd7](https://github.com/angular/angular.dart/commit/e01d5fd787fa0e62f9fa5c596c4fe63e429fd8dc))
- **parser:** Allow operator access to non-map, non-list objects
  ([51e167b8](https://github.com/angular/angular.dart/commit/51e167b84a5669a7268a833ed8328ddf8e1d263f),
   [#416](https://github.com/angular/angular.dart/issues/416))


<a name="0.9.4"></a>
# v0.9.4 supersonic-turtle (2014-1-13)

## Bug Fixes

- **di:** removed type parameters to accommodate di restriction
  ([7646df6d](https://github.com/angular/angular.dart/commit/7646df6dd00d1b6ea29d8930bd6d5d53d2bc2110))
- **doc:** NgShadowRoot => NgShadowRootAware
  ([303c12b8](https://github.com/angular/angular.dart/commit/303c12b8cc0956317a1b8f80846cb071835c228c))
- **docs:** typo
  ([06ab9e75](https://github.com/angular/angular.dart/commit/06ab9e75c8ea4746c2d183cbfbde3aea3d843582))
- **expression extractor:** Fix and test
  ([ff737732](https://github.com/angular/angular.dart/commit/ff7377321fa52f2c90c6b144ee3a14293a39addf))
- **expression_extractor:** fixed package roots
  ([6b2c9921](https://github.com/angular/angular.dart/commit/6b2c9921411c383475099790667431dd2ab2e2ab))
- **http_backend:** don't swallow http request errors.
  ([8cc26533](https://github.com/angular/angular.dart/commit/8cc26533c8f681a509633adf02e80d36833b82d0))
- **input:** corrected NPE when input goes away
  ([e97b9d07](https://github.com/angular/angular.dart/commit/e97b9d07f66ad4a2639868a0c22aa1b876af0dc4),
   [#392](https://github.com/angular/angular.dart/issues/392))
- **introspection:** Search our shadowRoot as well
  ([6549c982](https://github.com/angular/angular.dart/commit/6549c98211b58edfc4204bb814f5f8983727546c))
- **ng_model:** Disable a test that did not pass in content_shell
  ([a3da7310](https://github.com/angular/angular.dart/commit/a3da731082d745ec2b078a0b1f28a8fc9702b4b1))
- **parser:** pass analyzer v1.1.0
  ([e61e0375](https://github.com/angular/angular.dart/commit/e61e0375e1f8cc5fea9df2e662fb561d15380c10))
- **scope:**
  - fix $properties not visible using []
  ([4345857b](https://github.com/angular/angular.dart/commit/4345857bb0e2dd82561e7486e974c69ba5fb4976))
  - Also check for UnimplementedError when reflecting on source
  ([1d870ba4](https://github.com/angular/angular.dart/commit/1d870ba4c0f8f6d01318b35820a049f16ccbb435))
- **sdk:** Add support for Dart SDK 1.1
  ([9d6914ec](https://github.com/angular/angular.dart/commit/9d6914ec72677a4ae5c6ad9cb88c8e5e96c1efb0))
- **selector:** the required attribute should properly work with ng-required
  ([472d764e](https://github.com/angular/angular.dart/commit/472d764e83102c523cacebf22a3d366fc4803f9a))


## Features

- **NodeAttrs:**
  - implement the keys getter and containsKey()
  ([1a7d4a42](https://github.com/angular/angular.dart/commit/1a7d4a429e0cfc8f2e8f1bb559297a0f210babf3))
  - Implement forEach to iterate over attributes
  ([5c415135](https://github.com/angular/angular.dart/commit/5c4151359d483032fb2e89f387c3252ab059dd13))
- **compiler:**
  - A better error message for invalid selectors
  ([99eab544](https://github.com/angular/angular.dart/commit/99eab544fe1a026b66b438f0f6df199bdbd2ba83))
  - Throw a useful error message on a missing NgComponenet selector
  ([42692a14](https://github.com/angular/angular.dart/commit/42692a143568fdf30e4c8aa6f1b5a73cc2a6d870))
- **events:** add missing ng-events
  ([97bd4bc2](https://github.com/angular/angular.dart/commit/97bd4bc29ace2c4262ffaa9e8c655450dc49416b),
   [#386](https://github.com/angular/angular.dart/issues/386))
- **ng-pluralize:** Implement the ng-pluralize directive
  ([51d951e3](https://github.com/angular/angular.dart/commit/51d951e37e7c4ec8690eae860bc682ebf940d511))
- **scripts:** automatic way of generating changelog.MD
  ([11af25c8](https://github.com/angular/angular.dart/commit/11af25c8a5c12a5958441df8bdf6eb941a1ed79c))
- **template_cache_generator:** simple template cache generator
  ([32e073b7](https://github.com/angular/angular.dart/commit/32e073b74fe62a118d017d62ee378f7f114798a2))
- **travis:** add travis support
  ([fa3727f8](https://github.com/angular/angular.dart/commit/fa3727f823af42a0e672dbb2b0ffa5f236efedf4))


## Performance Improvements

- **NodeAttrs:** Remove one unnecessary call to snakecase
  ([ad2a7d54](https://github.com/angular/angular.dart/commit/ad2a7d54e86d681a976737c63a30b91a3fca1de7))
- **bracket:** Optimize calling methods on objects.
  ([12f5f672](https://github.com/angular/angular.dart/commit/12f5f672f880cbfae726139cf48b6ba80c408ff0))
- **parser:**
  - Add new AST based parser
  ([f2651d42](https://github.com/angular/angular.dart/commit/f2651d4259ed8f69663bac084240d38e0efd4fcf))
  - Faster lexer rewrite
  ([c279fac2](https://github.com/angular/angular.dart/commit/c279fac254e2a4c8396669050cc2770c0c8649cd))
  - Use a switch statement for unescaping.
  ([28b68d1f](https://github.com/angular/angular.dart/commit/28b68d1fccad4d7f71d62ccad55f8e78fb1f079a))
  - Faster character tests.
  ([ae8be929](https://github.com/angular/angular.dart/commit/ae8be929acd3f8c0682bd6e12c178fc698540a7d))
- **scope:**
  - Compute perf counters as part of the fast dirty check if possible.
  ([1932110c](https://github.com/angular/angular.dart/commit/1932110cd94b92214469d5ea645edbc1bb69702d))
  - Make the digest loop easier to optimize by splitting it into smaller and simpler methods.
  ([46123637](https://github.com/angular/angular.dart/commit/4612363746a5f4ffed15370eac3fc79570987f56))


<a name="0.9.3"></a>
# v0.9.3 reverse-telekinesis (2013-12-16)

### WARNING

We reserve the right to change the APIs in v.0.9.x versions.

## Bug Fixes

- **expression_extractor:**
  - support for inline templates
  ([898ec6d8](https://github.com/angular/angular.dart/commit/898ec6d89acb5ff64991a0c641e8874791d378dc),
   [#186](https://github.com/angular/angular.dart/issues/186))
  - do not fail when source file doesn't exist
  ([887e1bff](https://github.com/angular/angular.dart/commit/887e1bffab6a7f3810e2bb23b556cdc2e0a79ed5))
- **ng-repeat:** ng-repeat support for Iterable
  ([080bb0a6](https://github.com/angular/angular.dart/commit/080bb0a6062efe00dc393b3a8d0a19a3968d9ec8),
   [#292](https://github.com/angular/angular.dart/issues/292))
- **ng_model:** do not save/restore selection unnecessarily
  ([3c805483](https://github.com/angular/angular.dart/commit/3c805483e45cc6a344b5a34c3ca4ccac509e2349),
   [#264](https://github.com/angular/angular.dart/issues/264))
- **scope:**
  - log firing expressions in the watchLog
  ([cfa97d68](https://github.com/angular/angular.dart/commit/cfa97d685c8b12976ef1be407f4610e5641482c1),
   [#258](https://github.com/angular/angular.dart/issues/258))
  - remove GC pressure created by watchCollection getter
  ([a435a8f2](https://github.com/angular/angular.dart/commit/a435a8f2867b5b7440a3769da4ea441fc0198832))
- **todo demo:** Return the correct CSS class for TODO items in the demo.
  ([217a57ec](https://github.com/angular/angular.dart/commit/217a57ecfe7a897a1bb79eef686dcfb9a7b6498e))


## Features

- **NgComponent:** Support multiple css files
  ([6c6151cf](https://github.com/angular/angular.dart/commit/6c6151cf2ad45c4891ea14669cbfe942f79655d6))
- **cookies:** Basic Cookies service/wrapper over BrowserCookies
  ([6efde83e](https://github.com/angular/angular.dart/commit/6efde83edf5df79f9c7fa6ccf21ae51933c72938))
- **mocks:** provide support for child scope parameters in compile
  ([2d2c5219](https://github.com/angular/angular.dart/commit/2d2c521981ed04789f82fd182c0248abd89ebd79))
- **ng-model:** implemented support for input[type=password]
  ([058c8ee4](https://github.com/angular/angular.dart/commit/058c8ee4017f45c46017c99d64fc192e6fab0137))


## Performance Improvements

- **bracket:** Optimize calling methods on objects.
  ([525eeadb](https://github.com/angular/angular.dart/commit/525eeadbe00c23a68ce5b616199df40c40ddb492))
- **digest:** Use linked list for watchers
  ([7b6b0e5d](https://github.com/angular/angular.dart/commit/7b6b0e5dedb53c73fff668ca02909a2f709d4c29))


# v0.9.2 limited-omnipotence (2013-12-02)

### WARNING

We reserve the right to change the APIs in v.0.9.x versions.

## Bug Fixes

- **expression_extractor:** support extracting expresions from attr mapping annotations
  ([76fbac8c](https://github.com/angular/angular.dart/commit/76fbac8c87827c7b995d3097ad1993552089f6ec),
   [#291](https://github.com/angular/angular.dart/issues/291))
- **filters:** Fix filters in the code-gen parser
  ([8b2c3b62](https://github.com/angular/angular.dart/commit/8b2c3b629a739b246c0b2b44476691993968c1f2))
- **ng-class:** exportExpressionAttrs for ng-class, ng-class-odd, ng-class-even
  ([cecf3b6d](https://github.com/angular/angular.dart/commit/cecf3b6da1868f045cc54d3a989b5c5df39c27d5))
- **parser:**
  - Add ternary support to the static parser
  ([e37bd8f7](https://github.com/angular/angular.dart/commit/e37bd8f777acb8160c7723a1e68797b2dcb62e60))
  - Add caching to the dynamic parser.
  ([9cdd77a5](https://github.com/angular/angular.dart/commit/9cdd77a5f7e04609f2fa91d41090c8e93c4d56a6))
- **static parser:** Allow newlines in expressions.
  ([d21817ff](https://github.com/angular/angular.dart/commit/d21817ff961d2aec27b385fcc7da2579bf87e3d2),
   [#297](https://github.com/angular/angular.dart/issues/297))
- **syntax:** warnings in directive code
  ([1f3e3f72](https://github.com/angular/angular.dart/commit/1f3e3f72292c91dc21e3482726be5f61561752b5))


## Features

- **parse:**
  - support the integer division operator
  ([b29dff93](https://github.com/angular/angular.dart/commit/b29dff93fd5d2688735e5001e977b2c0cc98a5ea),
   [#233](https://github.com/angular/angular.dart/issues/233))
  - support the ternary/conditional operator
  ([e38da6f5](https://github.com/angular/angular.dart/commit/e38da6f542aa3a0c3e29b614ed444feee3e8ef4c),
   [#272](https://github.com/angular/angular.dart/issues/272))
- **di:** introduced @NgInjectableService to make di codegen easier
  ([54328d78](https://github.com/angular/angular.dart/commit/54328d785e9293f38fd5752cb13ff2eb3bc6e01c))
- **interpolate:** use $watchSet to remove memory pressure
  ([283ea257](https://github.com/angular/angular.dart/commit/283ea257309f8c91f80942c894ec4193b60fd725))
- **ngForm:** introduce basic support for the form directive
  ([26ca46d8](https://github.com/angular/angular.dart/commit/26ca46d8ed7de4f19e77b15cc6b1a1e99fd4bcc3))
- **parser_generator:** allow specifying output file
  ([0615456e](https://github.com/angular/angular.dart/commit/0615456ef7836b215dc56bd2dc3abc09806e6859))
- **probe:**
  - add ngQuery which can cross shadow root boundaries
  ([20897917](https://github.com/angular/angular.dart/commit/20897917525febec6572cb00cb1729b48da4cbee))
  - Access injector, scope, directives from REPL
  ([70c3e8d3](https://github.com/angular/angular.dart/commit/70c3e8d3e44fa35adcb739225abf1e6349101d8c),
   [#305](https://github.com/angular/angular.dart/issues/305))
- **repeater:**
  - implement shallow repeater
  ([c6e38afd](https://github.com/angular/angular.dart/commit/c6e38afd6927d15f64a80821a5aa511b34ba70cf),
  [99670fb8](https://github.com/angular/angular.dart/commit/99670fb8e8792b522f4ec375d882dbc92bbcd8d1))
- **scope:**
  - early exit of digest loop
  ([929e564b](https://github.com/angular/angular.dart/commit/929e564bac20bcc1a40de6906fbd21d5dd8d0e9f))
  - add $watchSet API
  ([a3c31ce1](https://github.com/angular/angular.dart/commit/a3c31ce1dddb4423faa316cb144568f3fc28b1a9))
  - implement scope.$disabled
  ([7e6e32dc](https://github.com/angular/angular.dart/commit/7e6e32dcffa1eefe0a9466f7742c9c91c303bc8a))
  - Implement lazy scope digest
  ([1d9e2575](https://github.com/angular/angular.dart/commit/1d9e2575f8dbf26676f1ff87b7f0d4274e6f5004))
  - add support to skip auto digest in a turn
  ([82da8e5d](https://github.com/angular/angular.dart/commit/82da8e5d9bdda7f042d5d52ae658db83e5666b73),
   [#235](https://github.com/angular/angular.dart/issues/235))


<a name="0.9.1"></a>
# v0.9.1 elemental-mimicry (2013-11-18)

### WARNING

We reserve the right to change the APIs in v.0.9.x versions.

## Bug Fixes

- don't create watchers for <=> => and =>! attributes if attribute is not specified on the element
  ([6ea6af8b](https://github.com/angular/angular.dart/commit/eb6ba0d76dcb62c95f67bda08a643aa7),
   [#265](https://github.com/angular/angular.dart/issues/265))
- ng-view does not clear template when route is deactivated
  ([6acb2c32](https://github.com/angular/angular.dart/commit/681e7dd72c9edeed8c11aca8424bf4ae6acb2c32),
   [#245](https://github.com/angular/angular.dart/issues/245))

## Features
- allow specifying attribute mappings using annotations
  ([68f7b233](https://github.com/angular/angular.dart/commit/50585ebe65698e4edcbf2f53134da84e68f7b233),
   [#227](https://github.com/angular/angular.dart/issues/227))
- simplified routing API
  ([a2eeb4e0](https://github.com/angular/angular.dart/commit/6ef8e828f43b0ef25f095bea2b063ad4a2eeb4e0),
   [#255](https://github.com/angular/angular.dart/issues/255))


<a name="0.9.0"></a>
# v0.9.0 static-animation (2013-11-04)

Initial beta release of AngularDart available for public testing.


### WARNING

We reserve the right to change the APIs in v.0.9.x versions.


## Features

- **Notable Directives**: `input`, `ng-bind`, `ng-class`, `ng-`events, `ng-if`, `ng-include`,
   `ng-model`, `ng-show\hide`, `ng-switch`, `ng-template`.

- **Notable Services**: `Compiler`, `Cookies`, `Http`, `ExceptionHandler`, `Scope`.

- **Notable Filters**: `currency`, `date`, `filter`, `json`, `limitTo`, `number`, `orderBy`


## Missing Features

- **Forms / Validation**: has not made it into AngularDart yet.


# Semantic Version Conventions

http://semver.org/

- *Stable*:  All even numbered minor versions are considered API stable:
  i.e.: v1.0.x, v1.2.x, and so on.
- *Development*: All odd numbered minor versions are considered API unstable:
  i.e.: v0.9.x, v1.1.x, and so on.

