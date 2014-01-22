<a name="0.9.4"></a>
# v0.9.4 supersonic-turtle (2014-1-13)

### WARNING

We reserve the right to change the APIs in v.0.9.x versions.


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

