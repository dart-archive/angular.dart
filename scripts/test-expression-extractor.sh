#!/bin/bash

set -e

(cd demo/todo; pub get)

OUT=$(mktemp XXX.dart)

dart bin/expression_extractor.dart demo/todo/main.dart demo/todo /dev/null /dev/null $OUT

if [[ -e $OUT ]]; then
  echo "Expression extractor created an output file"
  rm $OUT
  exit;
fi;

# The file did not exist, exit with error.
exit 1
