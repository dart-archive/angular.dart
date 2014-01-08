#!/bin/sh

. $(dirname $0)/env.sh

mkdir -p gen

cat test/core/parser/generated_functions.dart | sed -e 's/_template;/_generated;/' | grep -v REMOVE > gen/generated_functions.dart
$DART bin/parser_generator_for_spec.dart >> gen/generated_functions.dart

cat test/core/parser/generated_getter_setter.dart  | sed -e 's/_template;/_generated;/' | grep -v REMOVE  > gen/generated_getter_setter.dart
$DART bin/parser_generator_for_spec.dart getter_setter >> gen/generated_getter_setter.dart
