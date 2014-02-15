# Building and Testing AngularDart

This document describes how to set up your development environment to build and test AngularDart, and
explains the basic mechanics of using `git`, `node`, and `npm`.

See the [contributing guidelines](https://github.com/angular/angular.dart/blob/master/CONTRIBUTING.md) for how to contribute your own code to 

1. [Prerequisite Software](#prerequisite-software)
2. [Getting the Sources](#getting-the-sources)
3. [Environment Variable Setup](#environment-variable-setup)
4. [Installing NPM Modules and Dart Packages](#installing-npm-modules-and-dart-packages)
5. [Running Tests Locally](#running-tests-locally)
6. [Continuous Integration using Travis](#continuous-integration-using-travis)

## Prerequisite Software

Before you can build and test AngularDart, you must install and configure the
following products on your development machine:

* [Dart](https://www.dartlang.org/): as can be expected, AngularDart requires
  an installation of the Dart-SDK and Dartium (a version of
  [Chromium](http://www.chromium.org) with native support for Dart through the
  Dart VM). One of the **simplest** ways to get both is to install the **Dart
  Editor bundle**, which includes the editor, sdk and Dartium. See the [Dart
  tools download page for
  instructions](https://www.dartlang.org/tools/download.html).

* [Git](http://git-scm.com/) and/or the **Github app** (for
  [Mac](http://mac.github.com/) or [Windows](http://windows.github.com/)): the
  [Github Guide to Installing
  Git](https://help.github.com/articles/set-up-git) is a good source of
  information.

* [Node.js](http://nodejs.org): We use Node to run a development web server,
  run tests, and generate distributable files. We also use Node's Package
  Manager (`npm`). Depending on your system, you can install Node either from
  source or as a pre-packaged bundle.

## Getting the Sources

Forking and Cloning the AngularDart repository:

1. Login to your Github account or create one by following the instructions given [here](https://github.com/signup/free).
Afterwards.
2. [Fork](http://help.github.com/forking) the [main AngularDart repository](https://github.com/angular/angular.dart).
3. Clone your fork of the AngularDart repository and define an `upstream` remote pointing back to the AngularDart repository that you forked in the first place:

```shell
# Clone your Github repository:
git clone git@github.com:<github username>/angular.dart.git

# Go to the AngularDart directory:
cd angular.dart

# Add the main AngularDart repository as an upstream remote to your repository:
git remote add upstream https://github.com/angular/angular.dart.git
```

## Environment Variable Setup


Define the environment variables listed below. These are mainly needed for the
test scripts. The notation shown here is for
[`bash`](http://www.gnu.org/software/bash/); adapt as appropriate for your
favorite shell. (Examples given below of possible values for initializing the
environment variables assume Mac OS X and that you have installed the Dart
Editor in the directory named by `$DART_EDITOR_DIR`. This is only for
illustrative purposes.)

```shell
# CHROME_BIN: path to a Chrome browser executable; e.g.,
export CHROME_BIN="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# CHROME_CANARY_BIN: path to a Dartium browser executable; e.g.,
export CHROME_CANARY_BIN="$DART_EDITOR_DIR/chromium/Chromium.app/Contents/MacOS/Chromium"
```
**Note**: the `$CHROME_CANARY_BIN` environment variable is used by karma to run your tests
in dartium instead of chromium. If you don't do this, the dart2js compile will make the tests
run extremely slow since it has to wait for a full js compile each time.

You should also add the Dart SDK `bin` directory to your path and/or define `DART_SDK`; e.g.

```shell
# DART_SDK: path to a Dart SDK directory; e.g.,
export DART_SDK="$DART_EDITOR_DIR/dart-sdk"

# Update PATH to include the Dart SDK bin directory
PATH+=":$DART_SDK/bin"
```
## Installing NPM Modules and Dart Packages

Next, install the modules and packages needed to run AngularDart tests:

```shell
# Install node.js dependencies:
npm install

# Install karma onto your command line (optional)
npm install karma -g

# Install Dart packages
pub install
```

## Running Tests Locally

NOTE: scripts are being written to embody the following steps.

To run base tests:

```shell
# Source a script to define yet more environment variables
. ./scripts/env.sh

# Run io tests:
dart --checked test/io/all.dart

# Run expression extractor tests:
scripts/test-expression-extractor.sh

Run the Dart Analyzer:
./scripts/analyze.sh
```

To run Karma tests over Dartium, execute the following shell commands (which
will launch the Karma server):

```shell
. ./scripts/env.sh
node "node_modules/karma/bin/karma" start karma.conf \
    --reporters=junit,dots --port=8765 --runner-port=8766 \
    --browsers=Dartium
```

In another shell window or tab, or from your favorite IDE, launch the Karma
tests proper by executing:

```shell
. ./scripts/env.sh
karma_run.sh
```

**Note:**: If the dart analyzer fails with warnings, the tests will not run.
You can manually run the tests if this happens: 

```shell
karma run --port=8765
```

## Debugging

In the dart editor you can configure a dartium launch target for the karma test runner debug page.
The menu option is under Run > Manage Launches > Create new Dartium Launch.

```
http://localhost:8765/debug.html
```

If you want to only run a single test you can alter the test you wish to run by changing `it` to `iit`
or `describe` to `ddescribe`. This will only run that individual test and make it much easier to debug.


## Continuous Integration using Travis

See the instructions given [here](https://github.com/angular/angular.dart/blob/master/travis.md).

-----
