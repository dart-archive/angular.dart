library angular.html_parser;

import 'package:html5lib/parser.dart';
import 'package:html5lib/dom.dart';

import 'package:angular/tools/selector.dart';
import 'package:angular/tools/io.dart';
import 'package:angular/tools/common.dart';

typedef NodeVisitor(Node node);

RegExp _MUSTACHE_REGEXP = new RegExp(r'{{([^}]*)}}');
RegExp _NG_REPEAT_SYNTAX = new RegExp(r'^\s*(.+)\s+in\s+(.*?)\s*(\s+track\s+by\s+(.+)\s*)?$');

class HtmlExpressionExtractor {
  List<DirectiveInfo> directiveInfos;
  IoService ioService;

  HtmlExpressionExtractor(this.directiveInfos, this.ioService);

  Set<String> expressions = new Set<String>();

  void crawl(root) {
    ioService.visitFs(root, (String file) {
      if (!file.endsWith('.html')) return;

      _parseHtml(ioService.readAsStringSync(file));
    });
    for (DirectiveInfo directiveInfo in directiveInfos) {
      expressions.addAll(directiveInfo.expressions);
      if (directiveInfo.template != null) {
        _parseHtml(directiveInfo.template);
      }
    }
  }

  void _parseHtml(String html) {
    var document = parse(html);
    visitNodes([document], (Node node) {
      if (matchesNode(node, r'[*=/{{.*}}/]')) {
        node.attributes.forEach((attrName, attrValue) {
          _MUSTACHE_REGEXP.allMatches(attrValue).forEach((match) {
            expressions.add(match.group(1));
          });
        });
      }
      if (matchesNode(node, r':contains(/{{.*}}/)')) {
        _MUSTACHE_REGEXP.allMatches(node.value).forEach((match) {
          expressions.add(match.group(1));
        });
      }
      if (matchesNode(node, r'[ng-repeat]')) {
        var expr = _NG_REPEAT_SYNTAX.
            firstMatch(node.attributes['ng-repeat']).group(2);
        expressions.add(expr);
      }

      for (DirectiveInfo directiveInfo in directiveInfos) {
        if (matchesNode(node, directiveInfo.selector)) {
          directiveInfo.expressionAttrs.forEach((attr) {
            if (node.attributes[attr] != null && attr != 'ng-repeat') {
              expressions.add(node.attributes[attr]);
            }
          });
        }
      }
    });
  }

  visitNodes(List<Node> nodes, NodeVisitor visitor) {
    for (Node node in nodes) {
      visitor(node);
      if (node.nodes.length > 0) {
        visitNodes(node.nodes, visitor);
      }
    }
  }
}

