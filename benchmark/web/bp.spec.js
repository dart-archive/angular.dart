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


    it('should set the runState to 10 samples and -1 iterations', function() {
      var spy = spyOn(bp, 'setRunState');
      bp.runState.iterations = 0;
      bp.loopBenchmark();
      expect(spy).toHaveBeenCalledWith(10, -1);
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


    it('should set the runState to 20 samples and 25 iterations', function() {
      var spy = spyOn(bp, 'setRunState');
      bp.twentyFiveBenchmark();
      expect(spy).toHaveBeenCalledWith(20, 25);
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


  describe('.setRunState()', function() {
    it('should set provided arguments to runState object', function() {
      bp.runState = {};
      bp.setRunState(10, 15, 5);
      expect(bp.runState.numSamples).toBe(10);
      expect(bp.runState.iterations).toBe(15);
      expect(bp.runState.ignoreCount).toBe(5);
    });
  });


  describe('.resetRunState()', function() {
    it('should set runState object to defaults', function() {
      bp.runState = {
        numSamples: 99,
        iterations: 100,
        ignoreCount: 25,
        recentTimePerStep: {
          fakeStep: 2
        },
        timesPerAction: {
          fakeStep: {
            times: [5]
          }
        }
      }

      bp.resetRunState();
      expect(bp.runState.numSamples).toBe(0);
      expect(bp.runState.iterations).toBe(0);
      expect(bp.runState.ignoreCount).toBe(0);
      expect(bp.runState.timesPerAction).toEqual({});
      expect(bp.runState.recentTimePerStep).toEqual({});
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
      expect(typeof bp.runTimedTest(mockStep, times)).toBe('number');
    });
  });


  describe('.padName()', function() {
    it('should return a left-side padded name to total 10 characters', function() {
      expect(bp.padName('Jeff')).toBe('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Jeff');
      expect(bp.padName('Robertoooo')).toBe('Robertoooo');
    });


    it('should not pad if input is greater than 10 characters', function() {
      expect(bp.padName('Robertooooo')).toBe('Robertooooo');
    });
  });


  describe('.runAllTests()', function() {
    beforeEach(function() {
      bp.steps = [mockStep];
      bp.infoDiv = document.createElement('div');
    });

    it('should call resetRunState before calling done', function() {
      var spy = spyOn(bp, 'resetRunState');
      bp.runState.iterations = 0;
      bp.runAllTests();
      expect(spy).toHaveBeenCalled();
    });


    it('should call done after running for the appropriate number of iterations', function() {
      var spy = spyOn(mockStep, 'fn');
      var doneSpy = jasmine.createSpy('done');

      runs(function() {
        bp.setRunState(5, 5);
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
      var resetSpy = spyOn(bp, 'resetRunState');
      runs(function() {
        bp.setRunState(8, 10);
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


  describe('.getAverage()', function() {
    it('should return the average of a set of numbers', function() {
      expect(bp.getAverage([100,0,50,75,25])).toBe(50);
    });


    it('should trim the first parts of a set if trim argument provided', function() {
      expect(bp.getAverage([100,100,100,5,5], {
        ignoreCount: 3
      })).toBe(5);
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
        timesPerAction: {
          fakeStep: {
            times: [3,7],
            fmtTimes: ['3', '7'],
            nextEntry: 2
          },
        }
      };
    });

    it('should call generateReportPartial() with the correct info', function() {
      var spy = spyOn(bp, 'generateReportPartial');
      bp.calcStats();
      expect(spy).toHaveBeenCalledWith('fakeStep', 5, ['3','7','5']);
    });


    it('should call getAverage() with the correct info', function() {
      var spy = spyOn(bp, 'getAverage');
      bp.calcStats();
      expect(spy).toHaveBeenCalledWith([3,7,5], bp.runState);
    });


    it('should set the most recent time for each step to the next entry', function() {
      bp.calcStats();
      expect(bp.runState.timesPerAction.fakeStep.times[2]).toBe(5);
      bp.runState.recentTimePerStep.fakeStep = 25;
      bp.calcStats();
      expect(bp.runState.timesPerAction.fakeStep.times[3]).toBe(25);
    });


    it('should set the nextEntry of the tpa to 0 if one less than numSamples', function() {
      bp.runState.timesPerAction.fakeStep.nextEntry = 4;
      bp.calcStats();
      expect(bp.runState.timesPerAction.fakeStep.nextEntry).toBe(0);
    });


    it('should return an string report', function() {
      expect(typeof bp.calcStats()).toBe('string');
    });
  });


  describe('.generateReportPartial()', function() {
    it('should return an html string with provided values', function() {
      bp.runState.numSamples = 9;
      expect(bp.generateReportPartial('foo', 10, [9,11])).
        toBe('<div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;foo: avg-9:<b>10ms</b> [9, 11]ms</div>')
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
      var infoSpy = spyOn(bp, 'addInfo');

      bp.onDOMContentLoaded();
      expect(linksSpy).toHaveBeenCalled();
      expect(buttonSpy.callCount).toBe(3);
      expect(infoSpy).toHaveBeenCalled();
    });
  });
});