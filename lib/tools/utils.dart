library angular.tools.utils;

camelcase(String s) {
  var part = s.split('-').map((s) => s.toLowerCase());
  if (part.length <= 1) {
    return part.join();
  }
  return part.first + part.skip(1).map(capitalize).join();
}

capitalize(String s) => s.substring(0, 1).toUpperCase() + s.substring(1);

var SNAKE_CASE_REGEXP = new RegExp("[A-Z]");

snakecase(String name, [separator = '-']) =>
    name.replaceAllMapped(SNAKE_CASE_REGEXP, (Match match) =>
        (match.start != 0 ? separator : '') + match.group(0).toLowerCase());
