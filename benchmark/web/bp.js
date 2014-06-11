var bp = window.bp = {};
bp.steps = window.benchmarkSteps = [];
bp.runState = {
  numSamples: 10,
  recentTimePerStep: {},
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
  if (typeof window.gc === 'function') {
    window.gc();
  }
  var startTime = bp.numMilliseconds();
  bs.fn();
  return bp.numMilliseconds() - startTime;
};

bp.runAllTests = function (done) {
  if (bp.runState.iterations--) {
    bp.steps.forEach(function(bs) {
      bp.runState.recentTimePerStep[bs.name] = bp.runTimedTest(bs);
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

bp.generateReportPartial = function(name, avg, times) {
  return bp.interpolateHtml(
      '<tr><td>%0</td><td class="average">%1ms</td><td>[%2]ms</td></tr>',
      [
        name,
        ('' + avg).substr(0,6),
        times.join(', ')
      ]);
};

bp.getAverage = function (times, runState) {
  var avg = 0;
  times.forEach(function(x) { avg += x; });
  return avg / times.length;
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
        tpa = bp.getTimesPerAction(stepName),
        avg;

    tpa.fmtTimes[tpa.nextEntry] = ('' + timeForStep).substr(0,6);
    tpa.fmtTimes = bp.rightSizeTimes(tpa.fmtTimes);
    tpa.times[tpa.nextEntry++] = timeForStep;
    tpa.times = bp.rightSizeTimes(tpa.times);
    tpa.nextEntry %= bp.runState.numSamples;
    avg = bp.getAverage(tpa.times, bp.runState);

    report += bp.generateReportPartial(stepName, avg, tpa.fmtTimes);
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
