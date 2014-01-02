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

