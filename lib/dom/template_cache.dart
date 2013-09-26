library angular.service.template_cache;

import '../cache.dart';
import 'http.dart';

/**
 * Infinite cache service for templates loaded from URLs.
 * 
 * All templates that are loaded from a URL are cached indefinitely in the
 * TemplateCache the first time they are needed.  This includes templates loaded
 * via `ng-include` or via the `templateUrl` field on components decorated with
 * [NgComponent].
 *
 * All attempts that require loading a template from a URL are first checked
 * against this cache.  Only when there is a cache miss is a network request
 * attempted.
 *
 * You are welcome to pre-load / seed the TemplateCache with templates for URLs
 * in advance to avoid the network hit on first load.
 *
 * Example:
 * 
 *     // main.dart
 *     class MainController {
 *       MainController(TemplateCache $templateCache, Scope scope) {
 *         $templateCache.put(
 *             'tpl.html', new HttpResponse(200, 'my name is {{name}}'));
 *         scope.name = "chirayu";
 *       }
 *     }
 *
 *     main() {
 *       bootstrapAngular([
 *           new AngularModule()..controller('Main', MainController)
 *       ]);
 *     }
 *
 * and
 *
 *     <!-- index.html -->
 *     <html ng-app>
 *       <head>
 *         <script src="packages/browser/dart.js"></script>
 *         <script src="main.dart" type="application/dart"></script>
 *       </head>
 *       <body ng-controller="Main">
 *         <div ng-include="tpl.html"></div>
 *       </body>
 *     </html>
 *
 * the `ng-include` above won't require a template hit and it won't matter if
 * your server serves the file `tpl.html` or not.
 */
class TemplateCache extends Cache<HttpResponse> {
}
