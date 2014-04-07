
import 'dart:io';
import 'dart:convert';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;

/// Utility to run 'pub build' and fail if any unexpected warnings occur.
main(args) {
  var cmds = Commands.parse(args);

  var initialDir = Directory.current;
  Directory.current = cmds.packageHome;

  var result = Process.runSync('pub', ['build', '--format=json']);
  if (result.exitCode != 0) {
    print('pub build failed:');
    print(result.stdout);
    print(result.stderr);
    exit(result.exitCode);
  }

  Directory.current = initialDir;

  var actual = JSON.decode(result.stdout);
  var entries = actual['log']
      .where((entry) => entry['level'] != 'Fine' && entry['level'] != 'Info')
      .map((entry) =>
          '${entry['assetId']['path']} from ${entry['transformer']['name']} :'
          '${entry['level']}: ${entry['message']}')
      .toList();

  entries.sort();

  if (cmds.reset) {
    var lines = entries.map((msg) => '  ${JSON.encode(msg)}');
    cmds.expectations.writeAsStringSync('[\n${lines.join(',\n')}\n]');
    return;
  }

  var expected = JSON.decode(cmds.expectations.readAsStringSync());
  var unexpected = entries.toSet()
    ..removeAll(expected);

  if (unexpected.isNotEmpty) {
    print('Encountered unexpected pub build messages:');
    print(unexpected.join('\n'));
    print(' ');
    print('This can be corrected by running:');
    print('  dart ${path.relative(Platform.script.path)} ${args.join(' ')} '
        '--reset');
    exit(-1);
  }
}

class Commands {
  Directory packageHome;
  File expectations;
  bool reset;

  static Commands parse(List<String> args) {
    var parser = new ArgParser()
    ..addOption('package_home', abbr: 'p',
        help: 'The root directory of the package to be built.',
        defaultsTo: '.')
    ..addOption('expectations', abbr: 'e',
        help: 'A JSON file containing the expected warning and error messages.')
    ..addFlag('reset', negatable: false,
        help: 'Regenerate the expectations with the results of the build.')
    ..addFlag('help', abbr: 'h',
        negatable: false, help: 'Displays this help and exit.');

    showUsage() {
      print('Usage: dart pub_build.dart [options]');
      print('\nThese are valid options expected by pub_build.dart:');
      print(parser.getUsage());
    }

    var cmds = new Commands();
    var res;
    try {
      res = parser.parse(args);
    } on FormatException catch (e) {
      print(e.message);
      showUsage();
      exit(1);
    }

    if (res['help']) {
      showUsage();
      exit(0);
    }

    cmds.packageHome = new Directory(res['package_home']);
    if (!cmds.packageHome.existsSync()) {
      print('Unable to find directory ${res['package_home']}');
      exit(-1);
    }

    cmds.expectations = new File(path.absolute(res['expectations']));
    if (!cmds.expectations.existsSync()) {
      print('Unable to open expectations file ${res['expectations']}');
      exit(-1);
    }

    cmds.reset = res['reset'];

    return cmds;
  }
}
