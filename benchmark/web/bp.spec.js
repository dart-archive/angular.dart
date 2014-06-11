//ugly
if (typeof bp !== 'undefined') {
  window.removeEventListener('DOMContentLoaded', bp.onDOMContentLoaded);
}

describe('bp', function() {
  var bp = window.bp,
      mockStep = {
        fn: function() {},
        name: 'fakeStep'
      };

  beforeEach(function() {
    bp._container = document.createElement('div');

    var sampleRange = document.createElement('input');
    sampleRange.setAttribute('type', 'range');
    sampleRange.setAttribute('min', '1');
    sampleRange.setAttribute('max', '100');
    sampleRange.setAttribute('id', 'sampleRange');
    bp._container.appendChild(sampleRange);

    var sampleRangeValue = document.createElement('span')
    sampleRangeValue.setAttribute('id', 'sampleRangeValue');
    bp._container.appendChild(sampleRangeValue);

    bp.runState = {
      numSamples: 10,
      recentTimePerStep: {},
      recentGCTimePerStep: {},
      timesPerAction: {}
    };
  });

  describe('.loopBenchmark()', function() {
    var runAllTestsSpy, btn;
    beforeEach(function() {
      runAllTestsSpy = spyOn(bp, 'runAllTests');
      bp.loopBtn = document.createElement('button');
    });

    it('should call runAllTests if iterations does not start at greater than -1', function() {
      bp.runState.iterations = 0;
      bp.loopBenchmark();
      expect(runAllTestsSpy).toHaveBeenCalled();
      expect(runAllTestsSpy.callCount).toBe(1);
    });


    it('should not call runAllTests if iterations is already -1', function() {
      runs(function() {
        bp.runState.iterations = -1;
        bp.loopBenchmark();
      });

      waits(1);

      runs(function() {
        expect(runAllTestsSpy).not.toHaveBeenCalled();
      });
    });


    it('should not call runAllTests if iterations is less than -1', function() {
      runs(function() {
        bp.runState.iterations = -50;
        bp.loopBenchmark();
      });

      waits(1);

      runs(function() {
        expect(runAllTestsSpy).not.toHaveBeenCalled();
      });
    });


    it('should set the button text to "Pause" while iterating', function() {
      bp.runState.iterations = 0;
      bp.loopBenchmark();
      expect(bp.loopBtn.innerText).toBe('Pause');
    });


    it('should set the button text to "Loop" while iterating', function() {
      bp.runState.iterations = -1;
      bp.loopBenchmark();
      expect(bp.loopBtn.innerText).toBe('Loop');
    });


    it('should set the runState -1 iterations', function() {
      var spy = spyOn(bp, 'setIterations');
      bp.runState.iterations = 0;
      bp.loopBenchmark();
      expect(spy).toHaveBeenCalledWith(-1);
    });


    it('should set the iterations to 0 if iterations is already -1', function() {
      bp.runState.iterations = -1;
      bp.loopBenchmark();
      expect(bp.runState.iterations).toBe(0);
    });
  });


  describe('.onceBenchmark()', function() {
    var runAllTestsSpy;
    beforeEach(function() {
      bp.onceBtn = document.createElement('button');
      runAllTestsSpy = spyOn(bp, 'runAllTests');
    });

    it('should call runAllTests', function() {
      expect(runAllTestsSpy.callCount).toBe(0);
      bp.onceBenchmark();
      expect(runAllTestsSpy).toHaveBeenCalled();
    });


    it('should set the button text to "..."', function() {
      expect(runAllTestsSpy.callCount).toBe(0);
      bp.onceBenchmark();
      expect(bp.onceBtn.innerText).toBe('...');
    });


    it('should set the text back to Once when done running test', function() {
      expect(bp.onceBtn.innerText).not.toBe('Once');
      bp.onceBenchmark();
      var done = runAllTestsSpy.calls[0].args[0];
      done();
      expect(bp.onceBtn.innerText).toBe('Once');
    });
  });


  describe('.twentyFiveBenchmark()', function() {
    var runAllTestsSpy;
    beforeEach(function() {
      bp.twentyFiveBtn = document.createElement('button');
      runAllTestsSpy = spyOn(bp, 'runAllTests');
    });


    it('should set the runState to25 iterations', function() {
      var spy = spyOn(bp, 'setIterations');
      bp.twentyFiveBenchmark();
      expect(spy).toHaveBeenCalledWith(25);
    });


    it('should change the button text to "Looping..."', function() {
      expect(bp.twentyFiveBtn.innerText).not.toBe('Looping...');
      bp.twentyFiveBenchmark();
      expect(bp.twentyFiveBtn.innerText).toBe('Looping...');
    });


    it('should call runAllTests', function() {
      bp.twentyFiveBenchmark();
      expect(runAllTestsSpy).toHaveBeenCalled();
    });


    it('should pass runAllTests a third argument specifying times to ignore', function() {
      bp.twentyFiveBenchmark();
      expect(runAllTestsSpy.calls[0].args[1]).toBe(5);
    });
  });


  describe('.container()', function() {
    it('should return bp._container if set', function() {
      bp._container = 'fooelement';
      expect(bp.container()).toBe('fooelement');
    });


    it('should query the document for #benchmarkContainer if no _container', function() {
      var spy = spyOn(document, 'querySelector');
      bp._container = null;
      bp.container();
      expect(spy).toHaveBeenCalled();
    });
  });


  describe('.addSampleRange()', function() {
    it('should set the default value to the current numSamples', function() {
      bp.runState.numSamples = 10;
      bp.addSampleRange();
      expect(bp.sampleRange.value).toBe('10');
    });
  });


  describe('.onSampleRangeChanged()', function() {
    beforeEach(function() {
      bp.resetIterations();
    });


    it('should change the numSamples property', function() {
      expect(bp.runState.numSamples).toBe(10);
      bp.onSampleRangeChanged({target: {value: '80'}});
      expect(bp.runState.numSamples).toBe(80);
    });
  });


  describe('.addButton()', function() {

  });


  describe('.addLinks()', function() {

  });


  describe('.addInfo()', function() {

  });


  describe('.interpolateHtml', function() {
    it('should render a list of values into a string', function() {
      expect(bp.interpolateHtml('<div>%0</div><a>%1</a>', ['Hello', 'Jeff'])).
        toBe('<div>Hello</div><a>Jeff</a>');
    });


    it('should replace multiple instances of a token', function() {
      expect(bp.interpolateHtml('<div>%0</div><a>%0</a>', ['Hello'])).
        toBe('<div>Hello</div><a>Hello</a>');
    });
  });


  describe('.setIterations()', function() {
    it('should set provided arguments to runState object', function() {
      bp.runState = {numSamples: 10};
      bp.setIterations(15);
      expect(bp.runState.numSamples).toBe(10);
      expect(bp.runState.iterations).toBe(15);
    });
  });


  describe('.resetIterations()', function() {
    it('should set runState object to defaults', function() {
      bp.runState = {
        numSamples: 99,
        iterations: 100,
        recentTimePerStep: {
          fakeStep: 2
        },
        timesPerAction: {
          fakeStep: {
            times: [5]
          }
        }
      }

      bp.resetIterations();
      expect(bp.runState.numSamples).toBe(99);
      expect(bp.runState.iterations).toBe(0);
      expect(bp.runState.timesPerAction).toEqual({fakeStep: {times: [5]}});
      expect(bp.runState.recentTimePerStep).toEqual({fakeStep: 2});
    });
  });


  describe('.runTimedTest()', function() {
    it('should call gc if available', function() {
      window.gc = window.gc || function() {};
      var spy = spyOn(window, 'gc');
      bp.runTimedTest(mockStep, {});
      expect(spy).toHaveBeenCalled();
    });


    it('should return the time required to run the test', function() {
      var times = {};
      expect(typeof bp.runTimedTest(mockStep, times).time).toBe('number');
    });
  });


  describe('.runAllTests()', function() {
    beforeEach(function() {
      bp.steps = [mockStep];
      bp.infoDiv = document.createElement('div');
    });

    it('should call resetIterations before calling done', function() {
      var spy = spyOn(bp, 'resetIterations');
      bp.runState.iterations = 0;
      bp.runAllTests();
      expect(spy).toHaveBeenCalled();
    });


    it('should call done after running for the appropriate number of iterations', function() {
      var spy = spyOn(mockStep, 'fn');
      var doneSpy = jasmine.createSpy('done');

      runs(function() {
        bp.setIterations(5, 5);
        bp.runAllTests(doneSpy);
      });

      waitsFor(function() {
        return doneSpy.callCount;
      }, 'done to be called', 200);

      runs(function() {
        expect(spy.callCount).toBe(5);
      });
    });


    it('should add as many times to timePerStep as are specified by numSamples', function() {
      var doneSpy = jasmine.createSpy('done');
      var resetSpy = spyOn(bp, 'resetIterations');
      runs(function() {
        bp.runState.numSamples = 8;
        bp.setIterations(10);
        bp.runAllTests(doneSpy);
      });

      waitsFor(function() {
        return doneSpy.callCount;
      }, 'done to be called', 200);

      runs(function() {
        expect(bp.runState.timesPerAction.fakeStep.times.length).toBe(8);
      });
    });
  });


  describe('.rightSizeTimes()', function() {
    it('should make remove the left side of the input if longer than numSamples', function() {
      bp.runState.numSamples = 3;
      expect(bp.rightSizeTimes([0,1,2,3,4,5,6])).toEqual([4,5,6]);
    });


    it('should return the whole list if shorter than or equal to numSamples', function() {
      bp.runState.numSamples = 7;
      expect(bp.rightSizeTimes([0,1,2,3,4,5,6])).toEqual([0,1,2,3,4,5,6]);
      expect(bp.rightSizeTimes([0,1,2,3,4,5])).toEqual([0,1,2,3,4,5]);
    });
  });


  describe('.getAverage()', function() {
    it('should return the average of a set of numbers', function() {
      expect(bp.getAverage([100,0,50,75,25], [2,4,2,4,3])).toEqual({
        gcTime: 3,
        time: 50
      });
    });
  });


  describe('.calcStats()', function() {
    beforeEach(function() {
      bp.steps = [mockStep];
      bp.runState = {
        numSamples: 5,
        iterations: 5,
        recentTimePerStep: {
          fakeStep: 5
        },
        recentGCTimePerStep: {
          fakeStep: 2
        },
        timesPerAction: {
          fakeStep: {
            times: [3,7],
            fmtTimes: ['3', '7'],
            fmtGCTimes: ['1','3'],
            gcTimes: [1,3],
            nextEntry: 2
          },
        }
      };
    });


    it('should call generateReportPartial() with the correct info', function() {
      var spy = spyOn(bp, 'generateReportPartial');
      bp.calcStats();
      expect(spy).toHaveBeenCalledWith('fakeStep', {time: 5, gcTime: 2}, ['3','7','5'], ['1','3','2'])
      expect(spy.calls[0].args[0]).toBe('fakeStep');
      expect(spy.calls[0].args[1].gcTime).toBe(2);
      expect(spy.calls[0].args[1].time).toBe(5);
      expect(spy.calls[0].args[2]).toEqual(['3','7', '5']);
    });


    it('should call getAverage() with the correct info', function() {
      var spy = spyOn(bp, 'getAverage').andCallThrough();
      bp.calcStats();
      expect(spy).toHaveBeenCalledWith([ 3, 7, 5 ], [ 1, 3, 2 ]);
    });


    it('should set the most recent time for each step to the next entry', function() {
      bp.calcStats();
      expect(bp.runState.timesPerAction.fakeStep.times[2]).toBe(5);
      bp.runState.recentTimePerStep.fakeStep = 25;
      bp.calcStats();
      expect(bp.runState.timesPerAction.fakeStep.times[3]).toBe(25);
    });


    it('should return an string report', function() {
      expect(typeof bp.calcStats()).toBe('string');
    });
  });


  describe('.generateReportPartial()', function() {
    it('should return an html string with provided values', function() {
      bp.runState.numSamples = 9;
      expect(bp.generateReportPartial('foo', {time: 10, gcTime: 5}, ['9', '11'], ['4','6'])).
        toBe('<tr><td>foo</td><td class="average">test:10ms<br>gc:5ms<br>combined: 15ms</td><td>9<br>11</td><td>4<br>6</td></tr>')
    });
  });


  describe('.writeReport()', function() {
    it('should write the report to the infoDiv', function() {
      bp.infoDiv = document.createElement('div');
      bp.writeReport('report!');
      expect(bp.infoDiv.innerHTML).toBe('report!');
    });
  });


  describe('.onDOMContentLoaded()', function() {
    it('should call methods to write to the dom', function() {
      var linksSpy = spyOn(bp, 'addLinks');
      var buttonSpy = spyOn(bp, 'addButton');
      var rangeSpy = spyOn(bp, 'addSampleRange');
      var infoSpy = spyOn(bp, 'addInfo');

      bp.onDOMContentLoaded();
      expect(linksSpy).toHaveBeenCalled();
      expect(buttonSpy.callCount).toBe(3);
      expect(rangeSpy).toHaveBeenCalled();
      expect(infoSpy).toHaveBeenCalled();
    });
  });
});