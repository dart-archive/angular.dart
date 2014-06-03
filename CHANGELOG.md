<a name="v0.12.0"></a>
# v0.12.0 sprightly-argentinosaurus (2014-06-03)

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
- **router:** added vetoable preLeave event
  ([7329d471](https://github.com/angular/angular.dart/commit/7329d4714d04e7167bff2dbc4b5f3c4d1de93d35))
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

- **VmTurnZone:** due to [a8699da0](https://github.com/angular/angular.dart/commit/a8699da016c754e08502ae24034a86bd8d6e0d8e)
 

        `Zone.defaultOnScheduleMicrotask` is now named `Zone.onScheduleMicrotask`

- **compiler:** due to [0e129496](https://github.com/angular/angular.dart/commit/0e1294966d7daacc0aa7866fd9674e8e5695abb5)

        OneWayOneTime bindings will continue to accept value
        assignments until their stablized value is non-null. The
        assignment may occur multiple times.  Refer [issue
        1013](https://github.com/angular/angular.dart/issues/1013).

- **router:** due to [7329d471](https://github.com/angular/angular.dart/commit/7329d4714d04e7167bff2dbc4b5f3c4d1de93d35)

        Previously, vetoing was allowed on leave (RouteLeaveEvent) which caused
        issues because routes had no way to recover from other route vetoing a leave
        event.

        Now, similar to preEnter and enter, leave event was split into vetoable
        preLeave (RoutePreLeaveEvent) and non-vetoable leave (RouteLeaveEvent).

            views.configure({
              'foo': ngRoute(
                  path: '/foo',
                  preLeave: (RoutePreLeaveEvent e) {
                    e.allowLeave(new Future.value(false));
                  })
            });



<a name="v0.11.0"></a>
# v0.11.0 ungulate-funambulism (2014-05-06)


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

