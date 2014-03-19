library hop_runner;

import 'dart:async';
import 'dart:io';
import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';

void main(List<String> args) {
  
  //
  // Build
  //
  addTask('build_debug', _build('debug'));
  addTask('build_release', _build('release'));
  
  //
  // Analyzer
  //
  addTask('analyze_libs', createAnalyzerTask(_getLibs));

  //
  //  Run all tasks
  //
  addChainedTask('all_debug', ['build_debug', 'analyze_libs']);
  addChainedTask('all_release', ['build_release', 'analyze_libs']);
  
  runHop(args);
}

Future<List<String>> _getLibs() {
  return new Directory('lib').list()
      .where((FileSystemEntity fse) => fse is File)
      .map((File file) => file.path)
      .toList();
}

Task _build(String mode) {
    return new Task((TaskContext ctx) {
      var args = ['build', '--mode', mode];

    return startProcess(ctx, 'pub', args);
    });
}
