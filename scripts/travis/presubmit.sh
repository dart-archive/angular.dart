#!/bin/bash
set -e

#  If we're on the branch which name is of the form branch1-q-*
#  and all the tests have passed, push this branch as branch1. Note that
#  branch1-q-* would alreay have been rebased onto branch1 by this point.

echo '***************'
echo '** PRESUBMIT **'
echo '***************'


CHANNEL=`echo $JOB | cut -f 2 -d -`
SHA=`git rev-parse HEAD`

echo Current channel is: $CHANNEL
echo Current branch is: $TRAVIS_BRANCH
echo Test result is: $TRAVIS_TEST_RESULT

if [ "$TRAVIS_REPO_SLUG" = "angular/angular.dart" ]; then
  if [ $TRAVIS_TEST_RESULT -eq 0 ] && [[ $TRAVIS_BRANCH =~ ^(.*)-q-.*$ ]]; then
    echo "Pushing HEAD to ${BASH_REMATCH[2]}..."
    if git push upstream HEAD:${BASH_REMATCH[1]}; then
      echo "${BASH_REMATCH[0]} has been merged into ${BASH_REMATCH[1]}, deleting..."
      git push upstream :"${BASH_REMATCH[0]}"
    fi
  fi
fi
