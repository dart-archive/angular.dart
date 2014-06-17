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
      numSamples: 20,
      recentTimePerStep: {},
      recentGCTimePerStep: {},
      recentGarbagePerStep: {},
      recentRetainedMemoryPerStep: {},
      timesPerAction: {}
    };
  });

  describe('.Statistics', function() {
    describe('.calculateConfidenceInterval()', function() {
      it('should provide the correct confidence interval', function() {
        expect(bp.Statistics.calculateConfidenceInterval(30, 1000)).toBe(1.859419264179007);
      });
    });


    describe('.calculateRelativeMarginOfError()', function() {
      expect(bp.Statistics.calculateRelativeMarginOfError(1.85, 5)).toBe(0.37);
    });


    describe('.getMean()', function() {
      it('should return the mean for a given sample', function() {
        expect(bp.Statistics.getMean([1,2,5,4])).toBe(3);
      });
    });


    describe('.calculateStandardDeviation()', function() {
      it('should provide the correct standardDeviation for the provided sample and mean', function() {
        expect(bp.Statistics.calculateStandardDeviation([
          2,4,4,4,5,5,7,9
        ], 5)).toBe(2.138089935299395);
      });


      it('should provide the correct standardDeviation for the provided sample and mean', function() {
        expect(bp.Statistics.calculateStandardDeviation([
          674.64,701.78,668.33,662.15,663.34,677.32,664.25,1233.00,1100.80,716.15,681.52,671.23,702.70,686.89,939.39,830.28,695.46,695.66,675.15,667.48], 750.38)).toBe(158.57877026559186);
      });
    });
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
      bp.runState.numSamples = 20;
      bp.addSampleRange();
      expect(bp.sampleRange.value).toBe('20');
    });
  });


  describe('.onSampleRangeChanged()', function() {
    beforeEach(function() {
      bp.resetIterations();
    });


    it('should change the numSamples property', function() {
      expect(bp.runState.numSamples).toBe(20);
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
      bp.runState = {numSamples: 20};
      bp.setIterations(15);
      expect(bp.runState.numSamples).toBe(20);
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
      bp.infoTemplate = jasmine.createSpy('infoTemplate');
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


  describe('.getAverages()', function() {
    it('should return the average of a set of numbers', function() {
      expect(bp.getAverages([100,0,50,75,25], [2,4,2,4,3], [1,2],[3,4])).toEqual({
        gcTime: 3,
        time: 50,
        garbage: 1.5,
        retained: 3.5
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
        recentGarbagePerStep: {
          fakeStep: 200
        },
        recentRetainedMemoryPerStep: {
          fakeStep: 100
        },
        timesPerAction: {
          fakeStep: {
            times: [3,7],
            fmtTimes: ['3', '7'],
            fmtGcTimes: ['1','3'],
            garbageTimes: [50,50],
            fmtGarbageTimes: ['50','50'],
            retainedTimes: [25,25],
            fmtRetainedTimes: ['25','25'],
            gcTimes: [1,3],
            nextEntry: 2
          },
        }
      };
    });


    xit('should call generateReportPartial() with the correct info', function() {
      var spy = spyOn(bp, 'generateReportPartial');
      bp.calcStats();
      expect(spy).toHaveBeenCalledWith('fakeStep', {time: 5, gcTime: 2}, ['3','7','5'], ['1','3','2'], [50,50,200], [25,25,100])
    });


    it('should call getAverages() with the correct info', function() {
      var spy = spyOn(bp, 'getAverages').andCallThrough();
      bp.calcStats();
      expect(spy).toHaveBeenCalledWith([ 3, 7, 5 ], [ 1, 3, 2 ], [50,50,0.2], [25,25,0.1]);
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


  describe('.generateReportModel()', function() {
    it('should return properly formatted data', function() {
      expect(bp.generateReportModel({
        name: 'Some Step',
        avg: {
          time: 1.234567,
          gcTime: 2.345678,
          garbage: 6.5,
          retained: 7.5
        },
        times: ['1','2'],
        gcTimes: ['4','5'],
        garbageTimes: ['6','7'],
        retainedTimes: ['7','8'],
        timesConfidenceInterval: 0.5555
      })).toEqual({
        name : 'Some Step',
        avg : {
          time : '1.2345',
          gcTime : '2.3456',
          garbage : '6.5',
          retained : '7.5',
          combinedTime : '3.5802'
        },
        times : '1<br>2',
        gcTimes : '4<br>5',
        garbageTimes : '6<br>7',
        retainedTimes : '7<br>8',
        timesConfidenceInterval: '0.56'
      });
    });
  });


  describe('.writeReport()', function() {
    it('should write the report to the infoDiv', function() {
      bp.infoDiv = document.createElement('div');
      bp.writeReport('report!');
      expect(bp.infoDiv.innerHTML).toBe('report!')
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