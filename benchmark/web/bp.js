var bp = window.bp = {
  steps: window.benchmarkSteps = [],
  Statistics: {
    //Taken from z-table where confidence is 95%
    criticalValue: 1.96
  },
  Runner: {
    runState: {
      iterations: 0,
      numSamples: 20,
      recentTimePerStep: {},
      recentGCTimePerStep: {},
      recentGarbagePerStep: {},
      recentRetainedMemoryPerStep: {}
    }
  },
  Document: {},
  Report: {
    timesPerAction: {}
  },
  Measure: {}
};

bp.Measure.numMilliseconds = function() {
  if (window.performance != null && typeof window.performance.now == 'function') {
    return window.performance.now();
  } else if (window.performance != null && typeof window.performance.webkitNow == 'function') {
    return window.performance.webkitNow();
  } else {
    console.log('using Date.now');
    return Date.now();
  }
};

bp.Statistics.getMean = function (sample) {
  var total = 0;
  sample.forEach(function(x) { total += x; });
  return total / sample.length;
};

bp.Statistics.calculateConfidenceInterval = function(standardDeviation, sampleSize) {
  var standardError = standardDeviation / Math.sqrt(sampleSize);
  return bp.Statistics.criticalValue * standardError;
};

bp.Statistics.calculateRelativeMarginOfError = function (marginOfError, mean) {
  /*
   * Converts absolute margin of error to a relative margin of error by
   * converting it to a percentage of the mean.
   */
  return (marginOfError / mean);
};

bp.Statistics.calculateStandardDeviation = function(sample, mean) {
  var deviation = 0;
  sample.forEach(function(x) {
    deviation += Math.pow(x - mean, 2);
  });
  deviation = deviation / (sample.length -1);
  deviation = Math.sqrt(deviation);
  return deviation;
};

bp.Runner.setIterations = function (iterations) {
  bp.Runner.runState.iterations = iterations;
};

bp.Runner.resetIterations = function() {
  bp.Runner.runState.iterations = 0;
};

bp.Runner.loopBenchmark = function () {
  if (bp.Runner.runState.iterations <= -1) {
    //Time to stop looping
    bp.Runner.setIterations(0);
    bp.Document.loopBtn.innerText = 'Loop';
    return;
  }
  bp.Runner.setIterations(-1);
  bp.Document.loopBtn.innerText = 'Pause';
  bp.Runner.runAllTests();
};

bp.Runner.onceBenchmark = function() {
  bp.Runner.setIterations(1);
  bp.Document.onceBtn.innerText = '...';
  bp.Runner.runAllTests(function() {
    bp.Document.onceBtn.innerText = 'Once';
  });
};

bp.Runner.twentyFiveBenchmark = function() {
  var twentyFiveBtn = bp.Document.twentyFiveBtn;
  bp.Runner.setIterations(25);
  twentyFiveBtn.innerText = 'Looping...';
  bp.Runner.runAllTests(function() {
    twentyFiveBtn.innerText = 'Loop 25x';
  }, 5);
};

bp.Runner.runAllTests = function (done) {
  if (bp.Runner.runState.iterations--) {
    bp.steps.forEach(function(bs) {
      var testResults = bp.Runner.runTimedTest(bs);
      bp.Runner.runState.recentTimePerStep[bs.name] = testResults.time;
      bp.Runner.runState.recentGCTimePerStep[bs.name] = testResults.gcTime;
      bp.Runner.runState.recentGarbagePerStep[bs.name] = testResults.garbage;
      bp.Runner.runState.recentRetainedMemoryPerStep[bs.name] = testResults.retainedDelta;
    });
    bp.Report.markup = bp.Report.calcStats();
    bp.Document.writeReport(bp.Report.markup);
    window.requestAnimationFrame(function() {
      bp.Runner.runAllTests(done);
    });
  }
  else {
    bp.Document.writeReport(bp.Report.markup);
    bp.Runner.resetIterations();
    done && done();
  }
};

bp.Runner.runTimedTest = function (bs) {
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
  startTime = bp.Measure.numMilliseconds();
  bs.fn();
  endTime = bp.Measure.numMilliseconds() - startTime;
  afterHeap = performance.memory.usedJSHeapSize;

  startGCTime = bp.Measure.numMilliseconds();
  if (typeof window.gc === 'function') {
    window.gc();
  }
  endGCTime = bp.Measure.numMilliseconds() - startGCTime;

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

bp.Report.generateReportModel = function (rawModel) {
  rawModel.avg = {
    time: ('' + rawModel.avg.time).substr(0,6),
    gcTime: ('' + rawModel.avg.gcTime).substr(0,6),
    garbage: ('' + rawModel.avg.garbage).substr(0,6),
    retained: ('' + rawModel.avg.retained).substr(0,6),
    combinedTime: ('' + (rawModel.avg.time + rawModel.avg.gcTime)).substr(0,6)
  };
  rawModel.times = rawModel.times.join('<br>'),
  rawModel.gcTimes = rawModel.gcTimes.join('<br>'),
  rawModel.garbageTimes = rawModel.garbageTimes.join('<br>'),
  rawModel.retainedTimes = rawModel.retainedTimes.join('<br>')
  rawModel.timesConfidenceInterval = (rawModel.timesConfidenceInterval || 0).toFixed(2);
  return rawModel;
};

bp.Report.generatePartial = function(model) {
  return bp.infoTemplate(model);
};

bp.Document.writeReport = function(reportContent) {
  bp.Document.infoDiv.innerHTML = reportContent;
};

bp.Report.getTimesPerAction = function(name) {
  var tpa = bp.Report.timesPerAction[name];
  if (!tpa) {
    tpa = bp.Report.timesPerAction[name] = {
      times: [], // circular buffer
      fmtTimes: [],
      gcTimes: [],
      fmtGcTimes: [],
      garbageTimes: [],
      fmtGarbageTimes: [],
      retainedTimes: [],
      fmtRetainedTimes: [],
      nextEntry: 0
    }
  }
  return tpa;
};

bp.Report.rightSizeTimes = function(times) {
  var delta = times.length - bp.Runner.runState.numSamples;
  if (delta > 0) {
    return times.slice(delta);
  }

  return times;
};

bp.Report.updateTimes = function(tpa, index, reference, recentTime) {
  var fmtKey = 'fmt' + reference.charAt(0).toUpperCase() + reference.slice(1);
  tpa[reference][index] = recentTime;
  tpa[reference] = bp.Report.rightSizeTimes(tpa[reference]);
  tpa[fmtKey][index] = recentTime.toString().substr(0, 6);
  tpa[fmtKey] = bp.Report.rightSizeTimes(tpa[fmtKey]);
};

bp.Report.calcStats = function() {
  var report = '';
  bp.steps.forEach(function(bs) {
    var stepName = bs.name,
        timeForStep = bp.Runner.runState.recentTimePerStep[stepName],
        gcTimeForStep = bp.Runner.runState.recentGCTimePerStep[stepName],
        garbageTimeForStep = bp.Runner.runState.recentGarbagePerStep[stepName],
        retainedTimeForStep = bp.Runner.runState.recentRetainedMemoryPerStep[stepName],
        tpa = bp.Report.getTimesPerAction(stepName),
        reportModel,
        avg,
        timesConfidenceInterval,
        timesStandardDeviation;

    bp.Report.updateTimes(tpa, tpa.nextEntry, 'gcTimes', gcTimeForStep);
    bp.Report.updateTimes(tpa, tpa.nextEntry, 'garbageTimes', garbageTimeForStep / 1e3);
    bp.Report.updateTimes(tpa, tpa.nextEntry, 'retainedTimes', retainedTimeForStep / 1e3);
    bp.Report.updateTimes(tpa, tpa.nextEntry, 'times', timeForStep);

    tpa.nextEntry++;
    tpa.nextEntry %= bp.Runner.runState.numSamples;
    avg = {
      gcTime: bp.Statistics.getMean(tpa.gcTimes),
      time: bp.Statistics.getMean(tpa.times),
      garbage: bp.Statistics.getMean(tpa.garbageTimes),
      retained: bp.Statistics.getMean(tpa.retainedTimes)
    };

    timesStandardDeviation = bp.Statistics.calculateStandardDeviation(tpa.times, avg.time);
    timesConfidenceInterval = bp.Statistics.calculateConfidenceInterval(
        timesStandardDeviation,
        tpa.times.length
    );

    reportModel = bp.Report.generateReportModel({
      name: stepName,
      avg: avg,
      times: tpa.fmtTimes,
      timesStandardDeviation: timesStandardDeviation,
      timesRelativeMarginOfError: bp.Statistics.calculateRelativeMarginOfError(timesConfidenceInterval, avg.time),
      gcTimes: tpa.fmtGcTimes,
      garbageTimes: tpa.fmtGarbageTimes,
      retainedTimes: tpa.fmtRetainedTimes
    });
    report += bp.Report.generatePartial(reportModel);
  });
  return report;
};

bp.Document.addSampleRange = function() {
  bp.Document.sampleRange = bp.Document.container().querySelector('#sampleRange');
  if (bp.Document.sampleRange) {
    bp.Document.sampleRange.value = Math.max(bp.Runner.runState.numSamples, 1);
    bp.Document.sampleRange.addEventListener('input', bp.Document.onSampleInputChanged);
    bp.Document.sampleRangeValue = bp.Document.container().querySelector('#sampleRangeValue');
    bp.Document.sampleRangeValue.innerText = bp.Runner.runState.numSamples;
  }

};

bp.Document.onSampleInputChanged = function (evt) {
  var value = evt.target.value;
  bp.Runner.runState.numSamples = parseInt(value, 10);
  if (bp.Document.sampleRangeValue) {
    bp.Document.sampleRangeValue.innerText = value;
  }
};

bp.Document.container = function() {
  if (!bp._container) {
    bp._container = document.querySelector('#benchmarkContainer');
  }
  return bp._container;
}

bp.Document.addButton = function(reference, handler) {
  var container = bp.Document.container();
  bp.Document[reference] = container.querySelector('button.' + reference);
  if (bp.Document[reference]) {
    bp.Document[reference].addEventListener('click', handler);
  }
}

bp.Document.addLinks = function() {
  // Add links to everything
  var linkDiv = bp.Document.container().querySelector('.versionContent');
  var linkHtml = '';

  [
    // Add new benchmark suites here
    ['tree.html', 'TreeComponent']
  ].forEach((function (link) {
    linkHtml += '<a href="'+ link[0] +'">'+ link[1] +'</a>';
  }));

  if (linkDiv) {
    linkDiv.innerHTML = linkHtml;
  }
};

bp.Document.addInfo = function() {
  bp.Document.infoDiv = bp.Document.container().querySelector('tbody.info');
  if (bp.Document.infoDiv) {
    bp.infoTemplate = _.template(bp.Document.container().querySelector('#infoTemplate').innerHTML);
  }
};

bp.Document.onDOMContentLoaded = function() {
  bp.Document.addLinks();
  bp.Document.addButton('loopBtn', bp.Runner.loopBenchmark);
  bp.Document.addButton('onceBtn', bp.Runner.onceBenchmark);
  bp.Document.addButton('twentyFiveBtn', bp.Runner.twentyFiveBenchmark);
  bp.Document.addSampleRange();
  bp.Document.addInfo();
};

window.addEventListener('DOMContentLoaded', bp.Document.onDOMContentLoaded);
