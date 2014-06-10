var bp = window.bp = {};
bp.steps = window.benchmarkSteps = [];
bp.runState = {};

bp.setRunState = function (samples, iterations, ignoreCount) {
  bp.runState.numSamples = samples;
  bp.runState.iterations = iterations;
  bp.runState.ignoreCount = ignoreCount;
  bp.runState.recentTimePerStep = {};
  bp.runState.timesPerAction = {};
};

bp.resetRunState = function() {
  bp.runState = {
    numSamples: 0,
    iterations: 0,
    ignoreCount: 0,
    recentTimePerStep: {},
    timesPerAction: {}
  };
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
    bp.setRunState(10, 0);
    bp.loopBtn.innerText = 'Loop';
    return;
  }
  bp.setRunState(10, -1);
  bp.loopBtn.innerText = 'Pause';
  bp.runAllTests();
};

bp.onceBenchmark = function() {
  bp.setRunState(10, 1);
  bp.onceBtn.innerText = '...';
  bp.runAllTests(function() {
    bp.onceBtn.innerText = 'Once';
  });
};

bp.twentyFiveBenchmark = function() {
  var twentyFiveBtn = bp.twentyFiveBtn;
  bp.setRunState(20, 25);
  twentyFiveBtn.innerText = 'Looping...';
  bp.runAllTests(function() {
    twentyFiveBtn.innerText = 'Loop 25x';
  }, 5);
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
    bp.resetRunState();
    done && done();
  }
}

bp.padName = function (name) {
  return name.length < 10 ?
    ('         ' + name).slice(-10).replace(/ /g, '&nbsp;') :
    name;
};

bp.generateReportPartial = function(name, avg, times) {
  return bp.interpolateHtml(
      '<div>%0: avg-%1:<b>%2ms</b> [%3]ms</div>',
      [
        bp.padName(name),
        bp.runState.numSamples,
        ('' + avg).substr(0,6),
        times.join(', ')
      ]);
};

bp.getAverage = function (times, runState) {
  var avg = 0, ignoreCount = (runState && runState.ignoreCount) || 0;
  times = times.slice(ignoreCount);
  times.forEach(function(x) { avg += x; });
  return avg / times.length;
};

bp.writeReport = function(reportContent) {
  bp.infoDiv.innerHTML = reportContent;
};

bp.getTimesPerAction = function(name) {
  var tpa = bp.runState.timesPerAction[name];
  if (!tpa) {
    tpa = bp.runState.timesPerAction[name] =  {
      times: [], // circular buffer
      fmtTimes: [],
      nextEntry: 0
    }
  }
  return tpa;
};

bp.calcStats = function() {
  var report = '';
  bp.steps.forEach(function(bs) {
    var stepName = bs.name,
        timeForStep = bp.runState.recentTimePerStep[stepName],
        tpa = bp.getTimesPerAction(stepName),
        avg;
    tpa.fmtTimes[tpa.nextEntry] = ('' + timeForStep).substr(0,6);
    tpa.times[tpa.nextEntry++] = timeForStep;
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

bp.addButton = function(reference, text, handler) {
  var container = bp.container();
  bp[reference] = document.createElement('button');
  bp[reference].innerText = text;

  bp[reference].addEventListener('click', handler);

  container.appendChild(bp[reference]);
}

bp.addLinks = function() {
  // Add links to everything
  var linkDiv = document.createElement('div');
  linkDiv.style['margin-bottom'] = '1.5em';
  var linkHtml = [
    '<style>',
    '.bpLink { background: lightblue; padding: 1em }',
    '</style>',
    '<span class=bpLink>Benchmark Versions: </span>'
  ].join('\n');

  [
    // Add new benchmark suites here
    ['tree.html', 'TreeComponent']
  ].forEach((function (link) {
    linkHtml += bp.interpolateHtml('<a class=bpLink href=%0>%1</a>', link);
  }));

  linkDiv.innerHTML = linkHtml;
  bp.container().appendChild(linkDiv);
};

bp.addInfo = function() {
  bp.infoDiv = document.createElement('div');
  bp.infoDiv.style['font-family'] = 'monospace';
  bp.container().appendChild(bp.infoDiv);
};

bp.onDOMContentLoaded = function() {
  bp.addLinks();
  bp.addButton('loopBtn', 'Loop', bp.loopBenchmark);
  bp.addButton('onceBtn', 'Once', bp.onceBenchmark);
  bp.addButton('twentyFiveBtn', 'Loop 25x', bp.twentyFiveBenchmark);
  bp.addInfo();
};

window.addEventListener('DOMContentLoaded', bp.onDOMContentLoaded);
