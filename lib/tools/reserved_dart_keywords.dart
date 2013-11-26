library reserved_dart_keywords;

// From https://www.dartlang.org/docs/spec/latest/dart-language-specification.html#h.huusvrzea3q
List<String> RESERVED_DART_KEYWORDS = [
    "assert", "break", "case", "catch", "class", "const", "continue",
    "default", "do", "else", "enum", "extends", "false", "final",
    "finally", "for", "if", "in", "is", "new", "null", "rethrow",
    "return", "super", "switch", "this", "throw", "true", "try",
    "var", "void", "while", "with"];
isReserved(String key) => RESERVED_DART_KEYWORDS.contains(key);
