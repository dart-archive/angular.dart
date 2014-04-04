#!/bin/bash

set -e

(cd example; pub get)

rm -rf xxx.dart

OUT=$(mktemp XXX.dart)

dart --package-root=example/packages bin/expression_extractor.dart example/web/todo.dart example /dev/null /dev/null $OUT

if [[ -e $OUT ]]; then
  echo "Expression extractor created an output file"
  rm -rf $OUT
  exit;
fi;

# The file did not exist, exit with error.
exit 1
