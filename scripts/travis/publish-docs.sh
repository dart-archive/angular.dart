#!/bin/bash

CHANNEL=`echo $JOB | cut -f 2 -d -`
SHA=`git rev-parse HEAD`

echo Current channel is: $CHANNEL
echo Current branch is: $TRAVIS_BRANCH
echo Test result is: $TRAVIS_TEST_RESULT

if [ "$CHANNEL" = "stable" ] && [ "$TRAVIS_REPO_SLUG" = "angular/angular.dart" ]; then

    if [ $TRAVIS_TEST_RESULT -eq 0 ] && [ "$TRAVIS_BRANCH" = "master" ]; then

            echo "Gettting current docs from docs.angulardart.org repo on Github"
            rm -Rf docs.angulardart.org
            git clone https://github.com/angular/docs.angulardart.org.git

            echo "Removing old stable docs..."
            rm -rf docs.angulardart.org/docs

            echo "Copying new docs into stable folder..."
            rsync -a dartdoc-viewer/client/build/web/* docs.angulardart.org/
            cd docs.angulardart.org/

            #.git folder needs to be in the *project* root
            git config credential.helper "store --file=.git/credentials"
            echo "https://${GITHUB_TOKEN_DOCS_ANGULARDART_ORG}:@github.com" > .git/credentials
            git config user.name "travis@travis-ci.org"

            echo "Adding files..."
            git add .
            git commit -m "Automated push of generated docs from SHA: $SHA"
            git push
    fi
fi


