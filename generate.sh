#!/bin/sh

cp test/parser/generated_functions.dart gen/generated_functions.dart
dart bin/parser_generator_for_spec.dart >> gen/generated_functions.dart

cp test/parser/generated_getter_setter.dart gen/generated_getter_setter.dart
dart bin/parser_generator_for_spec.dart getter_setter >> gen/generated_getter_setter.dart
