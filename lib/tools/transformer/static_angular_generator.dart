library angular.tools.transformer.static_angular_generator;

import 'dart:async';
import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:angular/tools/transformer/options.dart';
import 'package:code_transformers/resolver.dart';
import 'package:di/transformer/refactor.dart';
import 'package:barback/barback.dart';
import 'package:path/path.dart' as path;
import 'package:source_maps/refactor.dart' show TextEditTransaction;

class StaticAngularGenerator extends Transformer with ResolverTransformer {
  final TransformOptions options;

  StaticAngularGenerator(this.options, Resolvers resolvers) {
    this.resolvers = resolvers;
  }

  Future<bool> isPrimary(Asset input) => options.isDartEntry(input);

  void applyResolver(Transform transform, Resolver resolver) {
    var asset = transform.primaryInput;

    var id = asset.id;
    var lib = resolver.getLibrary(id);
    var transaction = resolver.createTextEditTransaction(lib);
    var unit = lib.definingCompilationUnit.node;

    _addImport(transaction, unit, 'package:angular/angular_static.dart',
        'angular_static');

    var dynamicToStatic = new _NgDynamicToStaticVisitor(transaction);
    unit.accept(dynamicToStatic);

    var generatedFilePrefix = '${path.url.basenameWithoutExtension(id.path)}';
    _addImport(transaction, unit,
        '${generatedFilePrefix}_static_expressions.dart',
        'generated_static_expressions');
    _addImport(transaction, unit,
        '${generatedFilePrefix}_static_metadata.dart',
        'generated_static_metadata');
    _addImport(transaction, unit,
        '${generatedFilePrefix}_static_injector.dart',
        'generated_static_injector');

    var printer = transaction.commit();
    var url = id.path.startsWith('lib/')
        ? 'package:${id.package}/${id.path.substring(4)}' : id.path;
    printer.build(url);
    transform.addOutput(new Asset.fromString(id, printer.text));
  }
}

/// Injects an import into the list of imports in the file.
void _addImport(TextEditTransaction transaction, CompilationUnit unit,
    String uri, String prefix) {
  var last = unit.directives.where((d) => d is ImportDirective).last;
  transaction.edit(last.end, last.end, '\nimport \'$uri\' as $prefix;');
}

class _NgDynamicToStaticVisitor extends GeneralizingAstVisitor {
  final TextEditTransaction transaction;
  _NgDynamicToStaticVisitor(this.transaction);

  visitMethodInvocation(MethodInvocation m) {
    if (m.methodName.name == 'dynamicApplication') {
      if (m.target is SimpleIdentifier) {
        // Include the prefix in the rename.
        transaction.edit(m.target.beginToken.offset, m.methodName.endToken.end,
            'angular_static.staticApplication');
      } else {
        transaction.edit(m.methodName.beginToken.offset,
            m.methodName.endToken.end, 'angular_static.staticApplication');
      }

      var args = m.argumentList;
      transaction.edit(args.beginToken.offset + 1, args.end - 1,
        'generated_static_injector.factories, '
        'generated_static_metadata.typeAnnotations, '
        'generated_static_expressions.getters, '
        'generated_static_expressions.setters, '
        'generated_static_expressions.symbols');
    }
    super.visitMethodInvocation(m);
  }
}
