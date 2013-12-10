if dart2js perf/mirror_perf.dart -o perf/mirror_perf.dart.js > /dev/null ; then
	echo DART:
	dart perf/mirror_perf.dart
	echo JavaScript:
	node perf/mirror_perf.dart.js
fi