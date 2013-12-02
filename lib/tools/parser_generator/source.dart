library dart_code_gen_source;

import 'dart_code_gen.dart';

class SourceBuilder {
  static RegExp NON_WORDS = new RegExp(r'\W');

  Map<String, Code> refs = {};
  List<Code> codeRefs = [];

  String str(String s) => '\'' +
      s.replaceAll('\'', '\\\'')
        .replaceAll('\n', '\\n')
        .replaceAll(r'$', r'\$') + '\'';
  String ident(String s) => '_${s.replaceAll(NON_WORDS, '_')}_${s.hashCode}';

  String ref(Code code) {
    if (!refs.containsKey(code.id)) {
      refs[code.id] = code;
      code.toSource(this); // recursively expand;
      codeRefs.add(code);
    }
    return this.ident(code.id);
  }

  parens([p1, p2, p3, p4, p5, p6]) => new ParenthesisSource()..call(p1, p2, p3, p4, p5, p6);
  body([p1, p2, p3, p4, p5, p6]) => new BodySource()..call(p1, p2, p3, p4, p5, p6);
  stmt([p1, p2, p3, p4, p5, p6]) => new StatementSource()..call(p1, p2, p3, p4, p5, p6);

  call([p1, p2, p3, p4, p5, p6]) => new Source()..call(p1, p2, p3, p4, p5, p6);

}

class Source {
  static String NEW_LINE = '\n';
  List source = [];

  call([p1, p2, p3, p4, p5, p6]) {
    if (p1 != null) source.add(p1);
    if (p2 != null) source.add(p2);
    if (p3 != null) source.add(p3);
    if (p4 != null) source.add(p4);
    if (p5 != null) source.add(p5);
    if (p6 != null) source.add(p6);
  }

  toString([String indent='', newLine=false, sep='']) {
    var lines = [];
    var trailing = sep == ';';
    var _sep = '';
    source.forEach((s) {
      if (!trailing) lines.add(_sep);
      if (newLine) lines.add('\n' + indent);
      if (s is Source) {
        lines.add(s.toString(indent));
      } else {
        lines.add(s);
      }
      _sep = sep;
      if (trailing) lines.add(_sep);
    });
    return lines.join('');
  }
}


class ParenthesisSource extends Source {
  toString([String indent='']) {
    return '(' + super.toString(indent + '  ', true, ',') + ')';
  }
}

class MapSource extends Source {
  toString([String indent='']) {
    return '{' + super.toString(indent + '  ', true, ',') + '}';
  }
}

class BodySource extends Source {
  BodySource() {
    //this('');
  }
  toString([String indent='']) {
    return '{${super.toString(indent + '  ', true)}\n$indent}';
  }
}

class StatementSource extends Source {
  toString([String indent='']) {
    return '${super.toString(indent + '  ')};';
  }
}
