# Travis-CI Setup Instructions

## Set Up Instructions

1. Go to https://travis-ci.org/ and 'Sign in with Github'
2. Visit https://travis-ci.org/profile to trigger a Github sync (this may take a minute)
3. Find your project and flip the switch. This would be "<yourname>/angular.dart"
4. Click the little wrench next to the switch, it will take you to github.
5. Scroll down to Travis and click it
6. Click the 'Test Hook' button.

## What does it do?

- Every time you push to your repo, Travis will grab the changes from your repo and run a
  build on it.
- The build runs on Chrome, Firefox and Dartium browsers.

## How does it work.

All scripts can be found in `.travis.yml` and `scripts/travis` folder.

1. Install the browsers (Chrome, Firefox and Dartium) 
2. Install Dart stable or dev channel (see `CHANNEL` in the `.travis.yml` matrix)
3. Run analyzer on the code
4. Run karma
5. Generate documentation
6. Merge "presubmit" branches into master when the build is successful

## What needs to be done

- Collect/publish the test runs/times to some dashboard/graphing service
