<a name="v0.9.9"></a>
# v0.9.9 (2014-03-10)


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

