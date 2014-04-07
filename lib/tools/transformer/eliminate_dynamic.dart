library angular.tools.transformer.eliminate_dynamic;

import 'dart:async';

import 'package:analyzer/analyzer.dart';
import 'package:analyzer/src/generated/ast.dart';
import 'package:barback/barback.dart';
import 'package:source_maps/refactor.dart' show TextEditTransaction;
import 'package:source_maps/span.dart' show SourceFile;

/// Removes references to 'angular_dynamic.dart' from Angular.dart, assuming
/// that the compiled application will be static.
class EliminateDynamic extends Transformer {

  Future<bool> isPrimary(Asset input) =>
      input.id.package == 'angular' && input.id.path == 'lib/angular.dart';

  Future apply(Transform transform) {
    var asset = transform.primaryInput;
    return asset.readAsString().then((contents) {
      var compilationUnit =
          parseCompilationUnit(contents, suppressErrors: true);

      var transaction = new TextEditTransaction(contents,
          new SourceFile.text('package:angular/angular.dart', contents));

      var dynamicImport = compilationUnit.directives
          .where((d) => d is ExportDirective)
          .where((d) =>
              d.uri.stringValue == 'package:angular/angular_dynamic.dart' ||
              d.uri.stringValue == '/packages/angular/angular_dynamic.dart')
          .single;

      transaction.edit(dynamicImport.beginToken.offset,
          dynamicImport.endToken.offset + 2, '');

      var printer = transaction.commit();
      printer.build('package:angular/angular.dart');
      transform.addOutput(new Asset.fromString(asset.id, printer.text));
    });
  }
}
