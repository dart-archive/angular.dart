#!/bin/bash

#  If we're on the presubmit branch for the stable Dart release and all unit 
#  tests pass, merge the presubmit branch into master and push it. 


CHANNEL=`echo $JOB | cut -f 2 -d -`

echo Current channel is: $CHANNEL
echo Current branch is: $TRAVIS_BRANCH
echo Test result is: $TRAVIS_TEST_RESULT

if [ "$CHANNEL" = "stable" ]; then

    if [[ $TRAVIS_TEST_RESULT -eq 0 ] && [ "$TRAVIS_BRANCH"="presubmit" ]]; then

        git config credential.helper "store --file=.git/credentials"
        echo "https://${GITHUB_TOKEN_ANGULARDART}:@github.com" > .git/credentials
        git config user.name "travis@travis-ci.org"

		git checkout master
		git merge presubmit
		
		if [ $? -eq 0 ]; then
		    git branch -d presubmit
		    git push origin master
		fi
		
	fi
fi