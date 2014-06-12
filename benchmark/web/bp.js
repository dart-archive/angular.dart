var bp = window.bp = {};
bp.steps = window.benchmarkSteps = [];
bp.runState = {
  numSamples: 20,
  recentTimePerStep: {},
  recentGCTimePerStep: {},
  recentGarbagePerStep: {},
  recentRetainedMemoryPerStep: {},
  timesPerAction: {}
};

bp.setIterations = function (iterations) {
  bp.runState.iterations = iterations;
};

bp.resetIterations = function() {
  bp.runState.iterations = 0;
};

bp.interpolateHtml = function(string, list) {
  list.forEach(function(item, i) {
    var exp = new RegExp('%' + i, ['g']);
    string = string.replace(exp, item);
  });
  return string;
}

bp.numMilliseconds = function() {
  if (window.performance != null && typeof window.performance.now == 'function') {
    return window.performance.now();
  } else if (window.performance != null && typeof window.performance.webkitNow == 'function') {
    return window.performance.webkitNow();
  } else {
    console.log('using Date.now');
    return Date.now();
  }
};

bp.loopBenchmark = function () {
  if (bp.runState.iterations <= -1) {
    //Time to stop looping
    bp.setIterations(0);
    bp.loopBtn.innerText = 'Loop';
    return;
  }
  bp.setIterations(-1);
  bp.loopBtn.innerText = 'Pause';
  bp.runAllTests();
};

bp.onceBenchmark = function() {
  bp.setIterations(1);
  bp.onceBtn.innerText = '...';
  bp.runAllTests(function() {
    bp.onceBtn.innerText = 'Once';
  });
};

bp.twentyFiveBenchmark = function() {
  var twentyFiveBtn = bp.twentyFiveBtn;
  bp.setIterations(25);
  twentyFiveBtn.innerText = 'Looping...';
  bp.runAllTests(function() {
    twentyFiveBtn.innerText = 'Loop 25x';
  }, 5);
};

bp.addSampleRange = function() {
  bp.sampleRange = bp.container().querySelector('#sampleRange');
  bp.sampleRange.value = Math.max(bp.runState.numSamples, 1);
  bp.sampleRange.addEventListener('input', bp.onSampleRangeChanged);
  bp.sampleRangeValue = bp.container().querySelector('#sampleRangeValue');
  bp.sampleRangeValue.innerText = bp.runState.numSamples;
};

bp.onSampleRangeChanged = function (evt) {
  var value = evt.target.value;
  bp.runState.numSamples = parseInt(value, 10);
  bp.sampleRangeValue.innerText = value;
};

bp.runTimedTest = function (bs) {
  var startTime,
      endTime,
      startGCTime,
      endGCTime,
      retainedDelta,
      garbage,
      beforeHeap,
      afterHeap,
      finalHeap;
  if (typeof window.gc === 'function') {
    window.gc();
  }

  beforeHeap = performance.memory.usedJSHeapSize;
  startTime = bp.numMilliseconds();
  bs.fn();
  endTime = bp.numMilliseconds() - startTime;
  afterHeap = performance.memory.usedJSHeapSize;

  startGCTime = bp.numMilliseconds();
  if (typeof window.gc === 'function') {
    window.gc();
  }
  endGCTime = bp.numMilliseconds() - startGCTime;

  finalHeap = performance.memory.usedJSHeapSize;
  garbage = Math.abs(finalHeap - afterHeap);
  retainedDelta = finalHeap - beforeHeap;
  return {
    time: endTime,
    gcTime: endGCTime,
    beforeHeap: beforeHeap,
    garbage: garbage,
    retainedDelta: retainedDelta
  };
};

bp.runAllTests = function (done) {
  if (bp.runState.iterations--) {
    bp.steps.forEach(function(bs) {
      var testResults = bp.runTimedTest(bs);
      bp.runState.recentTimePerStep[bs.name] = testResults.time;
      bp.runState.recentGCTimePerStep[bs.name] = testResults.gcTime;
      bp.runState.recentGarbagePerStep[bs.name] = testResults.garbage;
      bp.runState.recentRetainedMemoryPerStep[bs.name] = testResults.retainedDelta;
    });
    bp.report = bp.calcStats();
    bp.writeReport(bp.report);
    window.requestAnimationFrame(function() {
      bp.runAllTests(done);
    });
  }
  else {
    bp.writeReport(bp.report);
    bp.resetIterations();
    done && done();
  }
}

bp.generateReportModel = function (rawModel) {
  return {
    name: rawModel.name,
    avg: {
      time: ('' + rawModel.avg.time).substr(0,6),
      gcTime: ('' + rawModel.avg.gcTime).substr(0,6),
      garbage: ('' + rawModel.avg.garbage).substr(0,6),
      retained: ('' + rawModel.avg.retained).substr(0,6),
      combinedTime: ('' + (rawModel.avg.time + rawModel.avg.gcTime)).substr(0,6)
    },
    times: rawModel.times.join('<br>'),
    gcTimes: rawModel.gcTimes.join('<br>'),
    garbageTimes: rawModel.garbageTimes.join('<br>'),
    retainedTimes: rawModel.retainedTimes.join('<br>')
  };
};

bp.generateReportPartial = function(model) {
  return bp.infoTemplate(model);
};

bp.getAverage = function (times, gcTimes, garbageTimes, retainedTimes) {
  var timesAvg = 0;
  var gcAvg = 0;
  var garbageAvg = 0;
  var retainedAvg = 0;
  times.forEach(function(x) { timesAvg += x; });
  gcTimes.forEach(function(x) { gcAvg += x; });
  garbageTimes.forEach(function(x) { garbageAvg += x; });
  retainedTimes.forEach(function(x) { retainedAvg += x; });
  return {
    gcTime: gcAvg / gcTimes.length,
    time: timesAvg / times.length,
    garbage: garbageAvg / garbageTimes.length,
    retained: retainedAvg / retainedTimes.length
  };
};

bp.writeReport = function(reportContent) {
  bp.infoDiv.innerHTML = reportContent;
};

bp.getTimesPerAction = function(name) {
  var tpa = bp.runState.timesPerAction[name];
  if (!tpa) {
    tpa = bp.runState.timesPerAction[name] = {
      times: [], // circular buffer
      fmtTimes: [],
      gcTimes: [],
      fmtGCTimes: [],
      garbageTimes: [],
      fmtGarbageTimes: [],
      retainedTimes: [],
      fmtRetainedTimes: [],
      nextEntry: 0
    }
  }
  return tpa;
};

bp.rightSizeTimes = function(times) {
  var delta = times.length - bp.runState.numSamples;
  if (delta > 0) {
    return times.slice(delta);
  }

  return times;
};

bp.calcStats = function() {
  var report = '';
  bp.steps.forEach(function(bs) {
    var stepName = bs.name,
        timeForStep = bp.runState.recentTimePerStep[stepName],
        gcTimeForStep = bp.runState.recentGCTimePerStep[stepName],
        garbageTimeForStep = bp.runState.recentGarbagePerStep[stepName],
        retainedTimeForStep = bp.runState.recentRetainedMemoryPerStep[stepName],
        tpa = bp.getTimesPerAction(stepName),
        reportModel,
        avg;


    tpa.gcTimes[tpa.nextEntry] = gcTimeForStep;
    tpa.gcTimes = bp.rightSizeTimes(tpa.gcTimes);
    tpa.fmtGCTimes[tpa.nextEntry] = gcTimeForStep.toString().substr(0, 6);
    tpa.fmtGCTimes = bp.rightSizeTimes(tpa.fmtGCTimes);



    tpa.garbageTimes[tpa.nextEntry] = garbageTimeForStep / 1e3;
    tpa.garbageTimes = bp.rightSizeTimes(tpa.garbageTimes);
    tpa.fmtGarbageTimes[tpa.nextEntry] = (garbageTimeForStep / 1e3).toFixed(3).toString();
    tpa.fmtGarbageTimes = bp.rightSizeTimes(tpa.fmtGarbageTimes);

    tpa.retainedTimes[tpa.nextEntry] = retainedTimeForStep / 1e3;
    tpa.retainedTimes = bp.rightSizeTimes(tpa.retainedTimes);
    tpa.fmtRetainedTimes[tpa.nextEntry] = (retainedTimeForStep / 1e3).toFixed(3).toString();
    tpa.fmtRetainedTimes = bp.rightSizeTimes(tpa.fmtRetainedTimes);

    tpa.times[tpa.nextEntry] = timeForStep;
    tpa.times = bp.rightSizeTimes(tpa.times);
    tpa.fmtTimes[tpa.nextEntry] = timeForStep.toString().substr(0, 6);
    tpa.fmtTimes = bp.rightSizeTimes(tpa.fmtTimes);

    tpa.nextEntry++;
    tpa.nextEntry %= bp.runState.numSamples;
    avg = bp.getAverage(
        tpa.times,
        tpa.gcTimes,
        tpa.garbageTimes,
        tpa.retainedTimes);
    reportModel = bp.generateReportModel({
      name: stepName,
      avg: avg,
      times: tpa.fmtTimes,
      gcTimes: tpa.fmtGCTimes,
      garbageTimes: tpa.fmtGarbageTimes,
      retainedTimes: tpa.fmtRetainedTimes
    });
    report += bp.generateReportPartial(reportModel);
  });
  return report;
};

bp.container = function() {
  if (!bp._container) {
    bp._container = document.querySelector('#benchmarkContainer');
  }
  return bp._container;
}

bp.addButton = function(reference, handler) {
  var container = bp.container();
  bp[reference] = container.querySelector('button.' + reference);
  bp[reference].addEventListener('click', handler);
}

bp.addLinks = function() {
  // Add links to everything
  var linkDiv = bp.container().querySelector('.versionContent');
  var linkHtml = '';

  [
    // Add new benchmark suites here
    ['tree.html', 'TreeComponent']
  ].forEach((function (link) {
    linkHtml += bp.interpolateHtml('<a href=%0>%1</a>', link);
  }));

  linkDiv.innerHTML = linkHtml;
};

bp.addInfo = function() {
  bp.infoDiv = bp.container().querySelector('tbody.info');
  bp.infoTemplate = _.template(bp.container().querySelector('#infoTemplate').innerHTML);
  console.log(bp.infoTemplate)
};

bp.onDOMContentLoaded = function() {
  bp.addLinks();
  bp.addButton('loopBtn', bp.loopBenchmark);
  bp.addButton('onceBtn', bp.onceBenchmark);
  bp.addButton('twentyFiveBtn', bp.twentyFiveBenchmark);
  bp.addSampleRange();
  bp.addInfo();
};

window.addEventListener('DOMContentLoaded', bp.onDOMContentLoaded);
