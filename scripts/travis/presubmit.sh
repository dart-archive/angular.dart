#!/bin/bash

#  If we're on the presubmit branch, the stable Dart release, and all unit 
#  tests pass, merge the presubmit branch into master and push it. 


CHANNEL=`echo $JOB | cut -f 2 -d -`
SHA=`git rev-parse HEAD`

echo Current channel is: $CHANNEL
echo Current branch is: $TRAVIS_BRANCH
echo Test result is: $TRAVIS_TEST_RESULT

if [ "$CHANNEL" = "stable" ] && [ "$TRAVIS_REPO_SLUG" = "angular/angular.dart" ]; then
    
    if [ $TRAVIS_TEST_RESULT -eq 0 ] && [ "$TRAVIS_BRANCH" = "presubmit" ]; then
    
        rm -Rf angular.dart       
        git clone https://github.com/angular/angular.dart.git
        cd angular.dart
                
        git config credential.helper "store --file=.git/credentials"
        echo "https://${GITHUB_TOKEN_ANGULARDART}:@github.com" > .git/credentials
        git config user.name "travis@travis-ci.org"
        
        git fetch https://github.com/angular/angular.dart.git presubmit
        git checkout master
        git merge -q origin/presubmit 
        
        if [ $? -eq 0 ]; then
            git push
        fi
    fi
fi