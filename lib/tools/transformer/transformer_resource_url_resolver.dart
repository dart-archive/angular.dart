library angular.tools.transformer.angular_file_resolver;

import 'package:analyzer/src/generated/element.dart';
import 'package:code_transformers/resolver.dart';
import 'package:barback/barback.dart';

/// Resolver used to find absolute resources when in Transformers by combining
/// AST element locations and relative URIs.
class TransformerResourceUrlResolver {
  final Resolver _resolver;
  final AssetId _primaryAsset;

  TransformerResourceUrlResolver(this._resolver, this._primaryAsset);

  Uri findUriOfElement(Element type) {
    var uri = _resolver.getImportUri(type.library, from: _primaryAsset);
    var acceptable = (
        (uri.isAbsolute && uri.scheme == 'package') ||
        (uri.toString() == uri.path));
    if (!acceptable) {
      var errMsg = 'ERROR: Type "$type" has unsupported URI $uri';
      throw errMsg;
    }
    if (uri.scheme != "package") {
      // this is guaranteed to be a relative URL (e.g. type defined in a path
      // imported file)
      var path = _primaryAsset.path;
      if (!path.startsWith('web/')) {
        var errMsg = 'ERROR: Type "$type" is imported as a path not under web.';
        throw errMsg;
      }
      uri = Uri.parse(path.substring('web/'.length)).resolve(uri.path);
    }
    return uri;
  }

  /// Given a AST [type] and [uri] if [uri] is relative combines it with the uri
  /// of the element to make an absolute location relative to types uri.
  /// Note: This logic should match [ResourceUrlResolver], but is separate as
  /// transformers and Mirrors have different APIs to identify elements, and
  /// calculate their URIs.
  String combineWithElement(Element type, String uri) {
    if (uri != null) {
      if (uri.startsWith("/")) return uri;
      if (uri.startsWith("packages/")) return "/" + uri;
    }

    var typeUri = findUriOfElement(type);

    if (uri == null) {
      uri = typeUri.path;
    }
    // If it's not absolute, then resolve it first
    Uri resolved = typeUri.resolve(uri);

    if (resolved.scheme == 'package') {
      return '/packages/${resolved.path}';
    } else {
      return resolved.toString();
    }
  }
}
