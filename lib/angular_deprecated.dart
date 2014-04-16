/**
 * Because we have restricted which types we export there are projects which fail. This re-exports
 * everything under a different import file. Once the projects clean up their imports it is safe
 * to remove this import.
 *
 * SEE: https://github.com/angular/angular.dart/commit/2f186e4a1f7ebbbb599ffaff86203a6fc37a2cf0
 */
library angular.deprecated;


export 'package:angular/core/module_internal.dart';
export 'package:angular/core/annotation_src.dart';
export 'package:angular/core_dom/module_internal.dart';
export 'package:angular/core/parser/parser.dart';
export 'package:angular/core/parser/lexer.dart';

export 'package:route_hierarchical/client.dart' show childRoute;
