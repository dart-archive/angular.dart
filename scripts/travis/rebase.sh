#!/bin/bash
set -e

#  If we're on the branch which has the name of the form
#  branch1-q-* we rebase branch1-q-* onto branch1.
#  This will leave system in detached head state. After this
#  tests will be run. Pushing the code into appropriate
#  branch is done during in "after_success" phase.

echo '***************'
echo '**  REBASE   **'
echo '***************'


CHANNEL=`echo $JOB | cut -f 2 -d -`
SHA=`git rev-parse HEAD`

echo Current channel is: $CHANNEL
echo Current branch is: $TRAVIS_BRANCH

if [ "$TRAVIS_REPO_SLUG" = "angular/angular.dart" ]; then
  if [[ $TRAVIS_BRANCH =~ ^(.*)-q-.*$ ]]; then
    FROM=${BASH_REMATCH[0]}
    ONTO=${BASH_REMATCH[1]}
    git config credential.helper "store --file=.git/credentials"
    # travis encrypt GITHUB_TOKEN_ANGULAR_ORG=??? --repo=angular/angular.dart
    echo "https://${GITHUB_TOKEN_ANGULAR_ORG}:@github.com" > .git/credentials
    git config user.name "deploy-test@travis-ci.org"

    echo "Rebasing " ${FROM} " onto " ${ONTO}
    git remote add upstream https://github.com/${TRAVIS_REPO_SLUG}.git
    git fetch upstream $ONTO
    # Compare against branch1 and rebase branch2 onto branch1
    git rebase --onto upstream/$ONTO upstream/$ONTO $FROM
    if [ -d ".git/rebase-apply" ]; then
      echo "Failed. Cannot rebase cleanly."
      exit 1;
    fi
  fi
fi
