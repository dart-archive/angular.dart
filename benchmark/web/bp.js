window.benchmarkSteps = [];

window.addEventListener('DOMContentLoaded', function() {
  var container = document.querySelector('#benchmarkContainer');

  // Add links to everything
  var linkDiv = document.createElement('div');
  linkDiv.style['margin-bottom'] = "1.5em";
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
  container.appendChild(linkDiv);


  // Benchmark runner
  var btn = document.createElement('button');
  btn.innerText = "Loop";
  var running = false;
  btn.addEventListener('click', loopBenchmark);
  
  container.appendChild(btn);

  function loopBenchmark() {
    if (running) {
      btn.innerText = "Loop";
      running = false;
    } else {
      window.requestAnimationFrame(function() {
        btn.innerText = "Pause";
        running = true;
        var loopB = function() {
          if (running) {
            window.requestAnimationFrame(function() {
              if (running) runBenchmarkSteps(loopB);
            });  
          }
        };
        loopB();  
      });
    }
  }


  var onceBtn = document.createElement('button');
  onceBtn.innerText = "Once";
  onceBtn.addEventListener('click', function() {
    window.requestAnimationFrame(function() {
      onceBtn.innerText = "...";
      window.requestAnimationFrame(function() {
        runBenchmarkSteps(function() {
          onceBtn.innerText = "Once";
        });
      });  
    });
  });
  container.appendChild(onceBtn);

  var infoDiv = document.createElement('div');
  infoDiv.style['font-family'] = 'monospace';
  container.appendChild(infoDiv);


  var numMilliseconds;
  var performance = window.performance;
  if (performance != null && typeof performance.now == "function") {
    numMilliseconds = function numMillisecondsWPN() {
      return performance.now();
    }
  } else if (performance != null && typeof performance.webkitNow == "function") {
    numMilliseconds = function numMillisecondsWebkit() {
      return performance.webkitNow();
    }
  } else {
    console.log('using Date.now');
    numMilliseconds = function numMillisecondsDateNow() {
      return Date.now();
    };
  }

  function runBenchmarkSteps(done) {
    // Run all the steps;
    var times = {};
    window.benchmarkSteps.forEach(function(bs) {
      var startTime = numMilliseconds();
      bs.fn();
      times[bs.name] = numMilliseconds() - startTime;
    });
    calcStats(times);

    done();
  }

  var timesPerAction = {};
   
  var NUM_SAMPLES = 10;
  function calcStats(times) {
    var iH = '';
    window.benchmarkSteps.forEach(function(bs) {
      var tpa = timesPerAction[bs.name];
      if (!tpa) {
        tpa = timesPerAction[bs.name] =  {
          times: [], // circular buffer
          fmtTimes: [],
          nextEntry: 0
        }
      }
      tpa.fmtTimes[tpa.nextEntry] = ('' + times[bs.name]).substr(0,6);
      tpa.times[tpa.nextEntry++] = times[bs.name];
      tpa.nextEntry %= NUM_SAMPLES;
      var avg = 0;
      tpa.times.forEach(function(x) { avg += x; });
      avg /= Math.min(NUM_SAMPLES, tpa.times.length);
      avg = ('' + avg).substr(0,6);
      iH += '<div>' + ('         ' + bs.name).slice(-10).replace(/ /g, '&nbsp;') + ': avg-' + NUM_SAMPLES + ':<b>' + avg + 'ms</b> [' + tpa.fmtTimes.join(', ') + ']ms</div>';
    });
    infoDiv.innerHTML = iH;
  }
});
