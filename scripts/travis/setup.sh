#!/bin/bash

set -e -o pipefail

if [ "$USE_G3" = "YES" ]; then
  echo =============================================================================
  echo "Rebasing onto g3v1x branch"
  git config --global user.email "travis@travis"
  git config --global user.name "AngularDart on Travis"
  git remote add upstream https://github.com/angular/angular.dart.git
  git fetch upstream
  # Set up a custom merge driver so that top level pubspec.lock conflicts for
  # do not fail the rebase.
  echo $'pubspec.lock merge=merge_pubspec_lock\n' >> .git/info/attributes
  cat >> .git/config <<"EOF"
[merge "merge_pubspec_lock"]
  name = "Auto merge pubspec.lock conflicts by ignoring changes"
  driver = cp %O %A
  recursive = text
EOF
  git rebase --onto upstream/g3v1x upstream/g3v1x-master
fi

echo =============================================================================
. ./scripts/env.sh
$DART --version
$PUB install

# Record dart version for tests.
echo $'import "dart:js";\n\nmain() {\n  context["DART_VERSION"] = \''"$($DART --version 2>&1)"$'\';\n}' > test/dart_version.dart
