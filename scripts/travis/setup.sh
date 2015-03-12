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
  driver = true
  recursive = text
EOF
  git rebase --onto upstream/g3v1x upstream/g3v1x-master
fi

echo =============================================================================
. ./scripts/env.sh
$DART --version
PUBSPEC_HASH=$(shasum pubspec.lock)
$PUB install
if [[ $(shasum pubspec.lock) != "$PUBSPEC_HASH" ]]; then
  if [ "$USE_G3" = "YES" ]; then
    echo ERROR: This commit causes pubspec.lock for g3v1x to change.  g3v1x
    echo uses dependency overrides to tests against specific versions of packages.
    echo Please ensure that these updated packages are available for g3v1x, update
    echo the dependency overrides and the pubspec.lock for g3v1x and push that.  You
    echo may test this job again after that.  Until then, this is considered a
    echo failure for the USE_G3=YES jobs.
  else
    echo ERROR: This commit causes pubspec.lock to change.  Please include the
    echo pubspec.lock changes in this commit and re-run this test.
  fi
  exit 1
fi

# Record dart version for tests.
echo $'import "dart:js";\n\nmain() {\n  context["DART_VERSION"] = \''"$($DART --version 2>&1)"$'\';\n}' > test/dart_version.dart
