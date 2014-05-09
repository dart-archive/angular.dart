#!/bin/bash
set -e

#  If we're on the presubmit branch, the dev Dart release, and all unit
#  tests pass, merge the presubmit branch into master and push it.

echo '***************'
echo '** PRESUBMIT **'
echo '***************'


CHANNEL=`echo $JOB | cut -f 2 -d -`
SHA=`git rev-parse HEAD`

echo Current channel is: $CHANNEL
echo Current branch is: $TRAVIS_BRANCH
echo Test result is: $TRAVIS_TEST_RESULT

if [ "$TRAVIS_REPO_SLUG" = "angular/angular.dart" ]; then
  if [ $TRAVIS_TEST_RESULT -eq 0 ] && [[ $TRAVIS_BRANCH == "presubmit-"* ]]; then
    git config credential.helper "store --file=.git/credentials"
    # travis encrypt GITHUB_TOKEN_ANGULAR_ORG=??? --repo=angular/angular.dart
    echo "https://${GITHUB_TOKEN_ANGULAR_ORG}:@github.com" > .git/credentials
    git config user.name "travis@travis-ci.org"

    echo "Pushing HEAD to master..."
    git remote add upstream https://github.com/angular/angular.dart.git
    git stash
    git fetch upstream master
    git rebase upstream/master
    if git push upstream HEAD:master; then
      echo "$TRAVIS_BRANCH has been merged into master, deleting..."
      git push upstream :"$TRAVIS_BRANCH"
    fi
  fi
fi
