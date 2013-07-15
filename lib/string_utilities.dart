part of angular;

var SNAKE_CASE_REGEXP = new RegExp("[A-Z]");

snake_case(String name, [separator = '_']) =>
  name.replaceAllMapped(SNAKE_CASE_REGEXP, (Match match) =>
    (match.start != 0 ? separator : '') + match.group(0).toLowerCase());
