# Contributing to AngularDart

We have set up a [[milestone][communityMilestone]] for issues which we believe are an excellent
place to start if you are interested in contributing to AngularDart.

[communityMilestone]: https://github.com/angular/angular.dart/issues?milestone=13&state=open


### Submitting a Pull Request
Before you submit your pull request consider the following guidelines:

* Search [GitHub](https://github.com/angular/angular.js/pulls) for an open or closed Pull Request
  that relates to your submission. You don't want to duplicate effort.
* Please sign our [Contributor License Agreement (CLA)](#signing-the-cla) before sending pull
  requests. We cannot accept code without this.
* Make your changes in a new git branch

     ```shell
     git checkout -b my-fix-branch master
     ```

* Create your patch, including appropriate test cases.
* Follow our [Coding Rules](#coding-rules)
* Commit your changes and create a descriptive commit message (the
  commit message is used to generate release notes, please check out our
  [commit message conventions](#commit-message-format) and our commit message presubmit hook
  `validate-commit-msg.js`):

     ```shell
     git commit -a
     ```

* Build your changes locally to ensure all the tests pass

    ```shell
    grunt test
    ```

* Push your branch to Github:

    ```shell
    git push origin my-fix-branch
    ```

* In Github, send a pull request to `angular:master`.
* If we suggest changes then you can modify your branch, rebase and force a new push to your GitHub
  repository to update the Pull Request:

    ```shell
    git rebase master -i
    git push -f
    ```

That's it! Thank you for your contribution!

When the patch is reviewed and merged, you can safely delete your branch and pull the changes
from the main (upstream) repository:

* Delete the remote branch on Github:

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

### GitHub Pull Request Helper

We track Pull Requests by attaching labels and assigning to milestones.  For some reason GitHub
does not provide a good UI for managing labels on Pull Requests (unlike Issues).  We have developed
a simple Chrome Extension that enables you to view (and manage if you have permission) the labels
on Pull Requests.  You can get the extension from the Chrome WebStore -
[GitHub PR Helper][github-pr-helper]

## Coding Rules
To ensure consistency throughout the source code, keep these rules in mind as you are working:

* All features or bug fixes **must be tested** by one or more [specs][unit-testing].
* All public API methods **must be documented** with ngdoc, an extended version of jsdoc (we added
  support for markdown and templating via @ngdoc tag). To see how we document our APIs, please check
  out the existing ngdocs and see [this wiki page][ngDocs].
* With the exceptions listed below, we follow the rules contained in
  [Google's JavaScript Style Guide][js-style-guide]:
    * **Do not use namespaces**: Instead,  wrap the entire angular code base in an anonymous closure and
      export our API explicitly rather than implicitly.
    * Wrap all code at **100 characters**.
    * Instead of complex inheritance hierarchies, we **prefer simple objects**. We use prototypical
      inheritance only when absolutely necessary.
    * We **love functions and closures** and, whenever possible, prefer them over objects.
    * To write concise code that can be better minified, we **use aliases internally** that map to the
      external API. See our existing code to see what we mean.
    * We **don't go crazy with type annotations** for private internal APIs unless it's an internal API
      that is used throughout AngularJS. The best guidance is to do what makes the most sense.

## Git Commit Guidelines

We have very precise rules over how our git commit messages can be formatted.  This leads to **more
readable messages** that are easy to follow when looking through the **project history**.  But also,
we use the git commit messages to **generate the AngularJS change log**.

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

## Signing the CLA

Please sign our Contributor License Agreement (CLA) before sending pull requests. For any code
changes to be accepted, the CLA must be signed. It's a quick process, we promise!

* For individuals we have a [simple click-through form][individual-cla].
* For corporations we'll need you to
  [print, sign and one of scan+email, fax or mail the form][corporate-cla].
