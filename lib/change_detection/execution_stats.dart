library angular.change_detection.execution_stats;

import 'package:angular/core/annotation_src.dart';

@Injectable()
class ExecutionStats {
  final ExecutionStatsConfig config;
  final ExecutionStatsEmitter emitter;
  List<ExecutionEntry> _dirtyCheckStats;
  List<ExecutionEntry> _dirtyWatchStats;
  List<ExecutionEntry> _evalStats;
  int _evalsCount = 0;
  int _dirtyWatchCount = 0;
  int _dirtyCheckCount = 0;

  int get _capacity => config.maxEntries;

  ExecutionStats(this.emitter, this.config) {
    reset();
  }

  void addDirtyCheckEntry(ExecutionEntry entry) {
    if( ++_dirtyCheckCount >= _capacity) _shrinkDirtyCheck();
    _dirtyCheckStats[_dirtyCheckCount] = entry;
  }

  void addDirtyWatchEntry(ExecutionEntry entry) {
    if( ++_dirtyWatchCount >= _capacity) _shrinkDirtyWatch();
    _dirtyWatchStats[_dirtyWatchCount] = entry;
  }

  void addEvalEntry(ExecutionEntry entry) {
    if( ++_evalsCount >= _capacity) _shrinkEval();
    _evalStats[_evalsCount] = entry;
  }

  void showEvalStats() {
    emitter.showEvalStats(this);
  }

  void showReactionFnStats() {
    emitter.showReactionFnStats(this);
  }

  void showDirtyCheckStats() {
    emitter.showDirtyCheckStats(this);
  }

  Iterable<ExecutionEntry> get dirtyCheckStats {
    _shrinkDirtyWatch();
    return _dirtyCheckStats.getRange(0, _capacity).where((e) => e.time > 0);
  }

  Iterable<ExecutionEntry> get evalStats {
    _shrinkDirtyWatch();
    return _evalStats.getRange(0, _capacity).where((e) => e.time > 0);
  }

  Iterable<ExecutionEntry> get reactionFnStats {
    _shrinkDirtyWatch();
    return _dirtyWatchStats.getRange(0, _capacity).where((e) => e.time > 0);
  }

  void enable() {
    config.enabled = true;
  }

  void disable() {
    config.enabled = false;
  }

  void reset() {
    _dirtyCheckStats = new List.filled(3 * _capacity, new ExecutionEntry(0, null));
    _dirtyWatchStats = new List.filled(3 * _capacity, new ExecutionEntry(0, null));
    _evalStats = new List.filled(3 * _capacity, new ExecutionEntry(0, null));
    _evalsCount = 0;
    _dirtyWatchCount = 0;
    _dirtyCheckCount = 0;
  }

  void _shrinkDirtyCheck() {
    _dirtyCheckStats.sort((ExecutionEntry x, ExecutionEntry y) => y.time.compareTo(x.time));
    for(int i = _capacity; i < 3 * _capacity; i++) _dirtyCheckStats[i] = new ExecutionEntry(0, null);
    _dirtyCheckCount = _capacity;
  }

  void _shrinkDirtyWatch() {
    _dirtyWatchStats.sort((ExecutionEntry x, ExecutionEntry y) => x.time.compareTo(y.time) * -1);
    for(int i = _capacity; i < 3 * _capacity; i++) _dirtyWatchStats[i] = new ExecutionEntry(0, null);
    _dirtyWatchCount = _capacity;
  }

  void _shrinkEval() {
    _evalStats.sort((ExecutionEntry x, ExecutionEntry y) => x.time.compareTo(y.time) * -1);
    for(int i = _capacity; i < 3 * _capacity; i++) _evalStats[i] = new ExecutionEntry(0, null);
    _evalsCount = _capacity;
  }
}

@Injectable()
class ExecutionStatsEmitter {
  void showDirtyCheckStats(ExecutionStats fnStats) {
    _printLine('Time (us)', 'Field');
    fnStats.dirtyCheckStats.forEach((ExecutionEntry entry) =>
    _printLine('${entry.time}', '${entry.value}'));
  }

  void showEvalStats(ExecutionStats fnStats) {
    _printLine('Time (us)', 'Name');
    fnStats.evalStats.forEach((ExecutionEntry entry) =>
        _printLine('${entry.time}', '${entry.value}'));
  }

  void showReactionFnStats(ExecutionStats fnStats) {
    _printLine('Time (us)', 'Expression');
    fnStats.reactionFnStats.forEach((ExecutionEntry entry) =>
        _printLine('${entry.time}', '${entry.value}'));
  }

  _printLine(String first, String second) {
    var timesColLength = 10;
    var expressionsColPrefix = 5;
    var timesCol = ' ' * (timesColLength - first.length);
    var expressionsCol = ' ' * expressionsColPrefix;
    print('${timesCol + first}${expressionsCol + second}');
  }

}

class ExecutionEntry {
  final num time;
  final dynamic value; //Record or Watch

  ExecutionEntry(this.time, this.value);
}

class ExecutionStatsConfig {
  bool enabled;
  int threshold;
  int maxEntries;

  ExecutionStatsConfig({this.enabled: false, this.threshold, this.maxEntries: 15});
}