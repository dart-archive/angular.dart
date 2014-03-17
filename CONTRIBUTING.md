# Contributing to AngularDart

We have set up a [milestone][communityMilestone] for issues that we believe are an excellent
place to start if you are interested in contributing to AngularDart.

We'd love for you to contribute to our source code and to make AngularDart even better than it is
today! Here are the guidelines we'd like you to follow:

 - [Code of Conduct](#coc)
 - [Question or Problem?](#question)
 - [Issues and Bugs](#issue)
 - [Feature Requests](#feature)
 - [Submission Guidelines](#submit)
 - [Coding Rules](#rules)
 - [Commit Message Guidelines](#commit)
 - [Signing the CLA](#cla)

## <a name="coc"></a> Code of Conduct
Help us keep Angular open and inclusive. Please read and follow our [Code of Conduct][coc].

## <a name="question"></a> Got a Question or Problem?

If you have questions about how to use AngularDart, please direct these to the [Google Group][groups]
discussion list or [StackOverflow][stackoverflow].

## <a name="issue"></a> Found an Issue?
If you find a bug in the source code or a mistake in the documentation, you can help us by
submitting and issue to our [GitHub Repository][github]. Even better you can submit a Pull Request
with a fix.

**Please see the Submission Guidelines below**.

## <a name="feature"></a> Want a Feature?
You can request a new feature by submitting an issue to our [GitHub Repository][github].  If you
would like to implement a new feature then consider what kind of change it is:

<!--
* **Major Changes** that you wish to contribute to the project should be discussed first on our
[dev mailing list][angular-dev] or [IRC][irc] so that we can better coordinate our efforts, prevent
duplication of work, and help you to craft the change so that it is successfully accepted into the
project.
-->
* **Small Changes** can be crafted and submitted to [GitHub Repository][github] as a Pull Request.


## <a name="docs"></a> Want a Doc Fix?
If you want to help improve the docs, it's a good idea to let others know what you're working on to
minimize duplication of effort. Before starting, check out the issue queue.

Comment on an issue to let others know what you're working on, or create a new issue if your work
doesn't fit within the scope of any of the existing doc fix projects.

For large fixes, please build and test the documentation before submitting the PR to be sure you haven't
accidentally introduced any layout or formatting issues. You should also make sure that your commit message
is labeled "docs:" and follows the **Git Commit Guidelines** outlined below.

## <a name="submit"></a> Submission Guidelines

### Submitting an Issue
Before you submit your issue search the archive, maybe your question was already answered.

If your issue appears to be a bug, and hasn't been reported, open a new issue.
Help us to maximize the effort we can spend fixing issues and adding new
features, by not reporting duplicate issues.  Providing the following information will increase the
chances of your issue being dealt with quickly:

* **Overview of the issue** - if an error is being thrown a non-minified stack trace helps
* **Motivation for or Use Case** - explain why this is a bug for you
* **Angular Version(s)** - is it a regression?
* **Browsers and Operating System** - is this a problem with all browsers or only IE8?
* **Reproduce the error** - provide a live example (using [Runnable][runnable]) or a unambiguous set of steps.
* **Related issues** - has a similar issue been reported before?
* **Suggest a Fix** - if you can't fix the bug yourself, perhaps you can point to what might be
  causing the problem (line of code or commit)

**If you get help, help others. Good karma rulez!**

### Submitting a Pull Request
Before you submit your pull request consider the following guidelines:

* Search [GitHub](https://github.com/angular/angular.dart/pulls) for an open or closed Pull Request
  that relates to your submission. You don't want to duplicate effort.
* Please sign our [Contributor License Agreement (CLA)](#signing-the-cla) before sending pull
  requests. We cannot accept code without this.
* Make your changes in a new git branch

     ```shell
     git checkout -b my-fix-branch master
     ```

* Create your patch, **including appropriate test cases**.
* Follow our [Coding Rules](#coding-rules).
* Run the full Angular test suite, as described in the [developer documentation][dev-doc],
  and ensure that all tests pass.
* Commit your changes using a descriptive commit message that follows our
  [commit message conventions](#commit-message-format) and passes our commit message presubmit hook
  `validate-commit-msg.js`. Adherence to the [commit message conventions](#commit-message-format)
  is required because release notes are automatically generated from these messages.

     ```shell
     git commit -a
     ```
  Note: the optional commit `-a` command line option will automatically "add" and "rm" edited files.

* Push your branch to GitHub:

    ```shell
    git push origin my-fix-branch
    ```

* In GitHub, send a pull request to `angular:master`.
* If we suggest changes then 
  * Make the required updates.
  * Re-run the AngularDart test suite to ensure tests are still passing.
  * Rebase your branch and force push to your GitHub repository (this will update your Pull Request):

    ```shell
    git rebase master -i
    git push -f
    ```

That's it! Thank you for your contribution!

#### After your pull request is merged

After your pull request is merged, you can safely delete your branch and pull the changes
from the main (upstream) repository:

* Delete the remote branch on GitHub either through the GitHub web UI or your local shell as follows:

    ```shell
    git push origin --delete my-fix-branch
    ```

* Check out the master branch:

    ```shell
    git checkout master -f
    ```

* Delete the local branch:

    ```shell
    git branch -D my-fix-branch
    ```

* Update your master with the latest upstream version:

    ```shell
    git pull --ff upstream master
    ```

## <a name="rules"></a> Coding Rules
To ensure consistency throughout the source code, keep these rules in mind as you are working:

  * All features or bug fixes **must be tested** by one or more [specs][unit-testing].
  * All public API methods **must be documented** with [doc comments][doc-comments].
  * With the exceptions listed below, we follow the rules contained in
  [Google's Dart Style Guide][dart-style-guide].

## <a name="commit"></a> Git Commit Guidelines

We have very precise rules over how our git commit messages can be formatted.  This leads to **more
readable messages** that are easy to follow when looking through the **project history**.  But also,
we use the git commit messages to **generate the AngularDart change log**.

### Commit Message Format
Each commit message consists of a **header**, a **body** and a **footer**.  The header has a special
format that includes a **type**, a **scope** and a **subject**:

```
<type>(<scope>): <subject>
<BLANK LINE>
<body>
<BLANK LINE>
<footer>
```

Any line of the commit message cannot be longer 100 characters! This allows the message to be easier
to read on github as well as in various git tools.

### Type
Must be one of the following:

* **feat**: A new feature
* **fix**: A bug fix
* **docs**: Documentation only changes
* **style**: Changes that do not affect the meaning of the code (white-space, formatting, missing
  semi-colons, etc)
* **refactor**: A code change that neither fixes a bug or adds a feature
* **perf**: A code change that improves performance
* **test**: Adding missing tests
* **chore**: Changes to the build process or auxiliary tools and libraries such as documentation
  generation

### Scope
The scope could be anything specifying place of the commit change. For example `$location`,
`$browser`, `$compile`, `$rootScope`, `ngHref`, `ngClick`, `ngView`, etc...

### Subject
The subject contains succinct description of the change:

* use the imperative, present tense: "change" not "changed" nor "changes"
* don't capitalize first letter
* no dot (.) at the end

###Body
Just as in the **subject**, use the imperative, present tense: "change" not "changed" nor "changes"
The body should include the motivation for the change and contrast this with previous behavior.

###Footer
The footer should contain any information about **Breaking Changes** and is also the place to
reference GitHub issues that this commit **Closes**.


A detailed explanation can be found in this [document][commit-message-format].

## <a name="cla"></a> Signing the CLA 

Please sign our Contributor License Agreement (CLA) before sending pull requests. For any code
changes to be accepted, the CLA must be signed. It's a quick process, we promise!

* For individuals we have a [simple click-through form][individual-cla].
* For corporations we'll need you to
  [print, sign and one of scan+email, fax or mail the form][corporate-cla].


[coc]: https://github.com/angular/code-of-conduct/blob/master/CODE_OF_CONDUCT.md
[commit-message-format]: https://docs.google.com/document/d/1QrDFcIiPjSLDn3EL15IJygNPiHORgU1_OOAqWjiDU5Y/edit#
[communityMilestone]: https://github.com/angular/angular.dart/issues?milestone=13&state=open
[corporate-cla]: http://code.google.com/legal/corporate-cla-v1.0.html
[dart-style-guide]: https://www.dartlang.org/articles/idiomatic-dart/
[dev-doc]: https://github.com/angular/angular.dart/blob/master/DEVELOPER.md
[doc-comments]: https://www.dartlang.org/articles/doc-comment-guidelines/
[github]: https://github.com/angular/angular.dart
[groups]: https://groups.google.com/forum/#!forum/angular-dart
[individual-cla]: http://code.google.com/legal/individual-cla-v1.0.html
[runnable]: http://runnable.com/
[stackoverflow]: http://stackoverflow.com/questions/tagged/angular.dart
[unit-testing]: https://www.dartlang.org/articles/dart-unit-tests/
