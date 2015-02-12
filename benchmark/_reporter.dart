library _reporter;

import 'dart:io';
import 'dart:convert' show UTF8, JSON;


String getBaseUrl() {
  String ngDashBaseUrl = Platform.environment["NGDASH_BASE_URL"];
  if (ngDashBaseUrl == null || ngDashBaseUrl.isEmpty) {
    ngDashBaseUrl = "http://ng-dash.gae.localhost";
  }
  return ngDashBaseUrl;
}


class ResultData {
  final String name;
  final String description;
  final Map<String, dynamic> dimensions = {};
  final Map<String, dynamic> metrics = {};
  final List<ResultData> children = [];

  ResultData(this.name, this.description);

  ResultData newChild(String name, String description) {
    ResultData child = new ResultData(name, description);
    children.add(child);
    return child;
  }

  toJson() => {
    "name": name,
    "description": description,
    "dimensions_json": JSON.encode(dimensions),
    "metrics_json": JSON.encode(metrics),
    "children": children.map((i) => i.toJson()).toList(),
  };
}


Map<String, String> getTravisDimension() {
  if (Platform.environment["TRAVIS"] != "true") {
    throw "getTravisDimension(): Not called on TRAVIS";
  }
  Map<String, String> result = {};
  // Ref: http://docs.travis-ci.com/user/ci-environment/
  for (String envVar in const [
    "TRAVIS_BRANCH",       // The name of the branch currently being built.
    "TRAVIS_BUILD_ID",     // The id of the current build that Travis CI uses internally.
    "TRAVIS_BUILD_NUMBER", // The number of the current build (for example, "4").
    "TRAVIS_COMMIT",       // The commit that the current build is testing.
    "TRAVIS_COMMIT_RANGE", // The range of commits that were included in the push or pull request.
    "TRAVIS_JOB_ID",       // The id of the current job that Travis CI uses internally.
    "TRAVIS_JOB_NUMBER",   // The number of the current job (for example, "4.1").
    "TRAVIS_PULL_REQUEST", // The pull request number if the current job is a pull request, "false" if it's not a pull request.
    "TRAVIS_REPO_SLUG",    // "owner_name/repo_name" (e.g. "travis-ci/travis-build").
    "TRAVIS_OS_NAME",      // Name of the operating system built on. (e.g. linux or osx)
    "TRAVIS_TAG",          // (optional) tag name for current build if relevant.
    ]) {
      String value = Platform.environment[envVar];
      if (value != null && value.isNotEmpty) {
        result[envVar.substring("TRAVIS_".length).toLowerCase()] = value;
      }
  }
  return result;
}


String getOsType() {
  if (Platform.isMacOS) {
    return "OSX";
  } else if (Platform.isLinux) {
    return "Linux";
  } else if (Platform.isWindows) {
    return "Windows";
  } else if (Platform.isAndroid) {
    return "Android";
  }
}


class Reporter {
  ResultData data = new ResultData("", "");
  final String baseUrl = getBaseUrl();
  String commitSha = "";
  String treeSha = "";
  String reportId = null;
  List<Cookie> cookies;

  bool _saveToServer = false;
  // Must have NGDASH_USER_EMAIL and NGDASH_USER_SECRET for AngularDart branches on Travis.
  bool get _requireCredentials => Platform.environment["TRAVIS_SECURE_ENV_VARS"] == "true";


  Reporter() {
    var dimensions = data.dimensions;
    dimensions["project"] = "AngularDart";
    dimensions["dart"] = {
      "full_version": Platform.version,
      "version": Platform.version.split(" ")[0],
    };
    dimensions["os"] = {
      "type": getOsType(),
    };
    if (Platform.environment["TRAVIS"] == "true") {
      dimensions["travis"] = getTravisDimension();
      commitSha = dimensions["travis"]["commit"];
    }

    // Auth cookies
    var user_email = Platform.environment["NGDASH_USER_EMAIL"];
    var user_secret = Platform.environment["NGDASH_USER_SECRET"];
    if (user_email != null && user_email.isNotEmpty &&
        user_secret != null && user_secret.isNotEmpty) {
      cookies = [new Cookie("user_email", user_email),
                 new Cookie("user_secret", user_secret)];
      _saveToServer = true;
      if (commitSha.isEmpty) {
        throw "Could not detect the commit SHA.  (non-travis detection not implemented yet.)";
      }
    } else if (_requireCredentials) {
      throw "Please set NGDASH_USER_EMAIL and NGDASH_USER_SECRET credentials.";
    }
  }


  // The following machinery is there just to serialize saving to the server.
  // If we're already in the process of saving the results, then just mark that
  // we need to save again.  This is also particularly important because the
  // first time, we create a new report, and in all subsequent calls, we update
  // that same report using the report ID that was received when we created it.
  var _messageQueue = [];
  var _isQueueProcessing = true;

  _sendNextMessage() {
    if (_messageQueue.isEmpty) {
      _isQueueProcessing = true;
      return;
    }

    String requestData = JSON.encode(_messageQueue.removeAt(0));
    _isQueueProcessing = false;
    Function onRequest = (HttpClientRequest request) {
      request
        ..headers.contentType = ContentType.JSON
        ..cookies.addAll(cookies)
        ..write(requestData);
      return request.close();
    };

    if (reportId == null) {
      new HttpClient().postUrl(Uri.parse("${baseUrl}/api/run"))
          .then(onRequest)
          .then((HttpClientResponse response) {
              List<String> parts = [];
              response.transform(UTF8.decoder).listen(parts.add, onDone: () {
                // Extract reportId to use in future requests.
                reportId = JSON.decode(parts.join(""))["id"];
                _sendNextMessage();
              });
          });
    } else {
      new HttpClient().putUrl(Uri.parse("${baseUrl}/api/run/id=$reportId"))
          .then(onRequest)
          .then((HttpClientResponse response) {
            response.transform(UTF8.decoder).listen(null, onDone: _sendNextMessage);
          });
    }
  }


  void saveReport() {
    if (_saveToServer) {
      _messageQueue.add(this);
      if (_isQueueProcessing) {
        _sendNextMessage();
      }
    }
  }


  toJson() => {
    "commit_sha": commitSha,
    "tree_sha": treeSha,
    "data": data.toJson(),
  };
}
