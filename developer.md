# Building and Testing AngularDart

This document describes how to set up your development environment to build and test AngularDart, and
explains the basic mechanics of using `git`, `node`, and `npm`.

<!--, `grunt`, and `bower`-->

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

<!--
* [Java](http://www.java.com): We minify JavaScript using our
[Closure Tools](https://developers.google.com/closure/) jar. Make sure you have Java (version 6 or higher) installed
and included in your [PATH](http://docs.oracle.com/javase/tutorial/essential/environment/paths.html) variable.

* [Grunt](http://gruntjs.com): We use Grunt as our build system. Install the grunt command-line tool globally with:

  ```shell
  npm install -g grunt-cli
  ```

* [Bower](http://bower.io/): We use Bower to manage client-side packages for the docs. Install the `bower` command-line tool globally with:

  ```shell
  npm install -g bower
  ```

**Note:** You may need to use sudo (for OSX, *nix, BSD etc) or run your command shell as Administrator (for Windows) to install Grunt &amp;
Bower globally.
-->

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

You should also add the Dart SDK `bin` directory to your path and/or define `DART_SDK`; e.g.

```shell
# DART_SDK: path to a Dart SDK directory; e.g.,
export DART_SDK="$DART_EDITOR_DIR/dart-sdk"

# Update PATH to include the Dart SDK bin directory
PATH+=":$DART_SDK/bin"
```
## Installing NPM Modules and Dart Packages

Next, install the modules and packages needed to run AngularDart tests:

<!-- To build AngularDart, ... and use Grunt to generate the non-minified and minified AngularDart files: -->

```shell
# Install node.js dependencies:
npm install

# Install Dart packages
pub install
```

<!--
# Install bower components:
# bower install

# Build AngularDart:
# grunt package
-->
<!--
**Note:** If you're using Windows, you must use an elevated command prompt (right click, run as
Administrator). This is because `grunt package` creates some symbolic links.

**Note:** If you're using Linux, and npm install fails with the message 
'Please try running this command again as root/Administrator.', you may need to globally install grunt and bower:
    sudo npm install -g grunt-cli
    sudo npm install -g bower

The build output can be located under the `build` directory. It consists of the following files and
directories:

* `angular-<version>.zip` — The complete zip file, containing all of the release build
artifacts.

* `angular.js` — The non-minified `angular` script.

* `angular.min.js` —  The minified `angular` script.

* `angular-scenario.js` — The `angular` End2End test runner.

* `docs/` — A directory that contains all of the files needed to run `docs.angularjs.org`.

* `docs/index.html` — The main page for the documentation.

* `docs/docs-scenario.html` — The End2End test runner for the documentation application.
-->

## Running Tests Locally

NOTE: scripts are being written to embody the following steps.

To run base tests:

```shell
# Source a script to define yet more environment variables
. ./scripts/env.sh

# Run io tests:
$DART --checked test/io/all.dart

# Run expression extractor tests:
scripts/test-expression-extractor.sh

Run the Dart Analyzer:
./scripts/analyze.sh
```

To run Karma tests launch one shell window and execute the following (to
launch the Karma server):

```shell
. ./scripts/env.sh
node "node_modules/karma/bin/karma" start karma.conf \
    --reporters=junit,dots --port=8765 --runner-port=8766 \
    --browsers=Dartium

# [Chalin] Dartium works for me, but not Chrome
#   --browsers=Dartium,ChromeNoSandbox
# Or maybe
#   --browsers=Dartium,ChromeNoSandbox
#
# Is this really needed?
#   --report-slower-than 100
# And this?
# node_modules/jasmine-node/bin/jasmine-node playback_middleware/spec/
```

In another shell tab or window, launch the Karma tests proper by executing:
```shell
. ./scripts/env.sh
karma_run.sh
```

## Continuous Integration using Travis

See the instructions given [here](https://github.com/angular/angular.dart/blob/master/travis.md).

-----
