/**
 * Bootstrapping for Angular applications via [app:dynamic](#angular-app-dynamic) for development,
 * or [app:static](#angular-app-static) for production.
 *
 * In your `main()` function, you bootstrap Angular by explicitly defining and adding a module for
 * your app:
 *
 *     import 'package:angular/angular.dart';
 *     import 'package:angular/angular_dynamic.dart';
 *
 *     class MyModule extends Module {
 *       MyModule() {
 *         type(HelloWorldController);
 *       }
 *     }
 *
 *     main() {
 *       dynamicApplication()
 *           .addModule(new MyModule())
 *           .run();
 *     }
 *
 * In the code above, we use [dynamicApplication](#angular-app-dynamic) to
 * take advantage of [dart:mirrors]
 * (https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart-mirrors) during
 * development. When you run the app in Dartium, you are using the implementation found under
 * [app:dynamic](#angular-app-dynamic). Note also that you must explicitly import both
 * `angular.dart` and `angular_dynamic.dart` at the start of your file.
 *
 * For production, transformers defined in your `pubspec.yaml` file convert the compiled code to
 * use the [app:static](#angular-app-static) implementation when you run `pub build`. Instead of
 * relying on mirrors, this automatically generates the getters, setters, annotations, and factories
 * needed by Dart for tree shaking in dart2js, ensuring that your final JavaScript code contains
 * only what is used by the root Injector that ngApp creates.
 *
 * Add the transformers rule shown below to your `pubspec.yaml`:
 *
 *     name: angular_dart_example
 *     version: 0.0.1
 *     dependencies:
 *       angular: '>= 0.9.11'
 *       browser: any
 *       unittest: any
 *
 *     transformers:
 *     - angular
 *
 * If your app structure makes use of directories for storing your templates,
 * you must also specify rules for `html_files` to ensure that the transformers pick up those
 * files. You only need to specify the HTML files; the parser will infer the correct `.dart` and
 * CSS files to include.
 *
 * For example:
 *
 *     transformers:
 *     - angular:
 *         html_files:
 *         - lib/_somelibrary/_some_component.html
 *
 * If you need a way to build your app without transformers, you can use
 * [staticApplication](#angular-app-static@id_staticApplication) directly, instead of
 * [dynamicApplication](#angular-app-dynamic@id_dynamicApplication). See the documentation for
 * the [app:static](#angular-app-static) library definition for more on this use case.
 */
library angular.app;

import 'dart:html' as dom;

import 'package:intl/date_symbol_data_local.dart';
import 'package:di/di.dart';
import 'package:angular/angular.dart';
import 'package:angular/perf/module.dart';
import 'package:angular/core/module_internal.dart';
import 'package:angular/core/registry.dart';
import 'package:angular/core_dom/module_internal.dart';
import 'package:angular/directive/module.dart';
import 'package:angular/filter/module.dart';
import 'package:angular/routing/module.dart';
import 'package:angular/introspection_js.dart';

/**
 * This is the top level module which describes all Angular components,
 * including services, filters and directives. When writing an Angular application,
 * AngularModule is automatically included.
 *
 * You can use AngularModule explicitly when creating a custom Injector that needs to know
 * about Angular services, filters, and directives. When writing tests, this is typically done for
 * you by the [SetUpInjector](#angular-mock@id_setUpInjector) method.
 *

 */
class AngularModule extends Module {
  AngularModule() {
    install(new NgCoreModule());
    install(new NgCoreDomModule());
    install(new NgDirectiveModule());
    install(new NgFilterModule());
    install(new NgPerfModule());
    install(new NgRoutingModule());

    type(MetadataExtractor);
    value(Expando, elementExpando);
  }
}

/**
 * Application is how you configure and run an Angular application. There are two
 * implementations for this abstract class:
 *
 * - [app:dynamic](#angular-app-dynamic) for development, which uses transformers to generate the
 * getters, setters, annotations, and factories needed by [dart:mirrors](https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart-mirrors) for tree shaking
 * - [app:static](#angular-app-static), for apps that explicitly specify their own getters,
 * setters, annotations, and factories and do not rely on transformation or  [dart:mirrors]
 * (https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart-mirrors)
 *
 */

abstract class Application {
  static _find(String selector, [dom.Element defaultElement]) {
    var element = dom.window.document.querySelector(selector);
    if (element == null) element = defaultElement;
    if (element == null) {
      throw "Could not find application element '$selector'.";
    }
    return element;
  }

  final zone = new NgZone();
  final ngModule = new AngularModule();
  final modules = <Module>[];
  dom.Element element;

  dom.Element selector(String selector) => element = _find(selector);

  Application(): element = _find('[ng-app]', dom.window.document.documentElement) {
    modules.add(ngModule);
    ngModule..value(NgZone, zone)
            ..value(Application, this)
            ..factory(dom.Node, (i) => i.get(Application).element);
  }

  Injector injector;

  Application addModule(Module module) {
    modules.add(module);
    return this;
  }

  Injector run() {
    publishToJavaScript();
    return zone.run(() {
      var rootElements = [element];
      Injector injector = createInjector();
      ExceptionHandler exceptionHandler = injector.get(ExceptionHandler);
      initializeDateFormatting(null, null).then((_) {
        try {
          var compiler = injector.get(Compiler);
          var viewFactory = compiler(rootElements, injector.get(DirectiveMap));
          viewFactory(injector, rootElements);
        } catch (e, s) {
          exceptionHandler(e, s);
        }
      });
      return injector;
    });
  }

  Injector createInjector();
}
