var bp = window.bp = {};
bp.steps = window.benchmarkSteps = [];
bp.timesPerAction = {};
bp.running = false;
bp.numSamples = 10;

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

bp.loopBenchmark = function loopBenchmark() {
  if (bp.running) {
    bp.loopBtn.innerText = 'Loop';
    bp.running = false;
  } else {
    window.requestAnimationFrame(function() {
      bp.loopBtn.innerText = 'Pause';
      bp.running = true;
      var loopB = function() {
        if (bp.running) {
          window.requestAnimationFrame(function() {
            if (bp.running) bp.runBenchmarkSteps(loopB);
          });
        }
      };
      loopB();
    });
  }
};

bp.onceBenchmark = function() {
  var btn = bp.onceBtn;
  window.requestAnimationFrame(function() {
    btn.innerText = '...';
    window.requestAnimationFrame(function() {
      bp.runBenchmarkSteps(function() {
        btn.innerText = 'Once';
      });
    });
  });
};

bp.runBenchmarkSteps = function runBenchmarkSteps(done) {
  // Run all the steps;
  var times = {};
  bp.steps.forEach(function(bs) {
    if (typeof window.gc === 'function') {
      window.gc();
    }
    var startTime = bp.numMilliseconds();
    bs.fn();
    times[bs.name] = bp.numMilliseconds() - startTime;
  });
  bp.calcStats(times);

  done();
};

bp.calcStats = function calcStats(times) {
  var iH = '';
  bp.steps.forEach(function(bs) {
    var tpa = bp.timesPerAction[bs.name];
    if (!tpa) {
      tpa = bp.timesPerAction[bs.name] =  {
        times: [], // circular buffer
        fmtTimes: [],
        nextEntry: 0
      }
    }
    tpa.fmtTimes[tpa.nextEntry] = ('' + times[bs.name]).substr(0,6);
    tpa.times[tpa.nextEntry++] = times[bs.name];
    tpa.nextEntry %= bp.numSamples;
    var avg = 0;
    tpa.times.forEach(function(x) { avg += x; });
    avg /= Math.min(bp.numSamples, tpa.times.length);
    avg = ('' + avg).substr(0,6);
    iH += '<div>' + ('         ' + bs.name).slice(-10).replace(/ /g, '&nbsp;') + ': avg-' + bp.numSamples + ':<b>' + avg + 'ms</b> [' + tpa.fmtTimes.join(', ') + ']ms</div>';
  });
  bp.infoDiv.innerHTML = iH;
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
    linkHtml += [
      '<a class=bpLink href=',
      link[0],
      '>',
      link[1],
      '</a>'
    ].join('');
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

  bp.addInfo();
};

window.addEventListener('DOMContentLoaded', bp.onDOMContentLoaded);
