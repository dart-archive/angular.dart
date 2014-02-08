part of angular.mock;

_SpecInjector _currentSpecInjector = null;

class _SpecInjector {
  DynamicInjector moduleInjector;
  DynamicInjector injector;
  List<Module> modules = [];
  List<Function> initFns = [];

  _SpecInjector() {
    var moduleModule = new Module()
      ..factory(Module, (Injector injector) => addModule(new Module()));
    moduleInjector = new DynamicInjector(modules: [moduleModule]);
  }

  addModule(module) {
    if (injector != null) {
      throw ["Injector already crated, can not add more modules."];
    }
    modules.add(module);
    return module;
  }

  module(fnOrModule, [declarationStack]) {
    try {
      if (fnOrModule is Function) {
        var initFn = moduleInjector.invoke(fnOrModule);
        if (initFn is Function) {
          initFns.add(initFn);
        }
      } else if (fnOrModule is Module) {
        addModule(fnOrModule);
      } else {
        throw 'Unsupported type: $fnOrModule';
      }
    } catch (e, s) {
      throw "$e\n$s\nDECLARED AT:$declarationStack";
    }
  }

  inject(Function fn, [declarationStack]) {
    try {
      if (injector == null) {
        injector = new DynamicInjector(modules: modules); // Implicit injection is disabled.
        initFns.forEach((fn) {
          injector.invoke(fn);
        });
      }
      injector.invoke(fn);
    } catch (e, s) {
      throw "$e\n$s\nDECLARED AT:$declarationStack";
    }
  }

  reset() {
    injector = null;
  }
}

/**
 * Allows the injection of instances into a test. See [module] on how to install new
 * types into injector.
 *
 * NOTE: Calling inject creates an injector, which prevents any more calls to [module].
 *
 * Typical usage:
 *
 *     test('wrap whole test', inject((TestBed tb) {
 *       tb.compile(...);
 *     });
 *
 *     test('wrap part of a test', () {
 *       module((Module module) {
 *         module.type(Foo);
 *       });
 *       inject((TestBed tb) {
 *         tb.compile(...);
 *       });
 *     });
 *
 */
inject(Function fn) {
  try { throw ''; } catch (e, stack) {
    if (_currentSpecInjector == null ) {
      return () => _currentSpecInjector.inject(fn, stack);
    } else {
      return _currentSpecInjector.inject(fn, stack);
    }
  }
}

/**
 * Allows the installation of new types/modules into the current test injector.
 *
 * This method can be called in declaration or inline in test. The method can be called
 * repeatedly, as long as [inject] is not called. Invocation of [inject] creates the injector and
 * hence no more calls to [module] can be made.
 *
 *     setUp(module((Module model) {
 *       module.type(Foo);
 *     });
 *
 *     test('foo', () {
 *       module((Module module) {
 *         module.type(Foo);
 *       });
 *     });
 */
module(fnOrModule) {
  try { throw ''; } catch(e, stack) {
    if (_currentSpecInjector == null ) {
      return () => _currentSpecInjector.module(fnOrModule, stack);
    } else {
      return _currentSpecInjector.module(fnOrModule, stack);
    }
  }
}

/**
 * Call this method in your test harness [setUp] method to setup the injector.
 */
setUpInjector() {
  _currentSpecInjector = new _SpecInjector();
  _currentSpecInjector.module((Module m) {
    m.install(new AngularModule());
    m.install(new AngularMockModule());
  });
}

/**
 * Call this method in your test harness [tearDown] method to cleanup the injector.
 */
tearDownInjector() => _currentSpecInjector = null;
