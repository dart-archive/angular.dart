library angular.mock.test_injection;

import 'package:angular/application_factory.dart';
import 'package:angular/mock/module.dart';
import 'package:di/di.dart';
import 'dart:mirrors';

_SpecInjector _currentSpecInjector = null;

class _SpecInjector {
  Injector moduleInjector;
  Injector injector;
  dynamic injectiorCreateLocation;
  final modules = <Module>[];
  final initFns = <Function>[];

  _SpecInjector() {
    var moduleModule = new Module()
      ..bind(Module, toFactory: () => addModule(new Module()));
    moduleInjector = new ModuleInjector([moduleModule]);
  }

  addModule(module) {
    if (injector != null) {
      throw ["Injector already created, can not add more modules."];
    }
    modules.add(module);
    return module;
  }

  module(fnOrModule, [declarationStack]) {
    if (injectiorCreateLocation != null) {
      throw "Injector already created at:\n$injectiorCreateLocation";
    }
    try {
      if (fnOrModule is Function) {
        var initFn = _invoke(moduleInjector, fnOrModule);
        if (initFn is Function) initFns.add(initFn);
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
        injectiorCreateLocation = declarationStack;
        injector = new ModuleInjector(modules); // Implicit injection is disabled.
        initFns.forEach((fn) {
          _invoke(injector, fn);
        });
      }
      _invoke(injector, fn);
    } catch (e, s) {
      throw "$e\n$s\nDECLARED AT:$declarationStack";
    }
  }

  reset() {
    injector = null;
    injectiorCreateLocation = null;
  }

  _invoke(Injector injector, Function fn) {
    ClosureMirror cm = reflect(fn);
    MethodMirror mm = cm.function;
    List args = mm.parameters.map((ParameterMirror parameter) {
      var metadata = parameter.metadata;
      Key key = new Key(
          (parameter.type as ClassMirror).reflectedType,
          metadata.isEmpty ? null : metadata.first.type.reflectedType);
      return injector.getByKey(key);
    }).toList();

    return cm.apply(args).reflectee;
  }
}

/**
 * Allows the injection of instances into a test. See [module] on how to install new
 * types into injector.
 *
 * NOTE: Calling inject creates an injector, which prevents any more calls to [module].
 *
 * NOTE: [inject] will never return the result of [fn]. If you need to return a [Future]
 * for unittest to consume, take a look at [async], [clockTick], and [microLeap] instead.
 *
 * Typical usage:
 *
 *     test('wrap whole test', inject((TestBed tb) {
 *       tb.compile(...);
 *     }));
 *
 *     test('wrap part of a test', () {
 *       module((Module module) {
 *         module.bind(Foo);
 *       });
 *       inject((TestBed tb) {
 *         tb.compile(...);
 *       });
 *     });
 *
 */
inject(Function fn) {
  try {
    throw '';
  } catch (e, stack) {
    return _currentSpecInjector == null
        ? () => _currentSpecInjector.inject(fn, stack)
        : _currentSpecInjector.inject(fn, stack);
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
 *       module.bind(Foo);
 *     });
 *
 *     test('foo', () {
 *       module((Module module) {
 *         module.bind(Foo);
 *       });
 *     });
 */
module(fnOrModule) {
  try {
    throw '';
  } catch(e, stack) {
    return _currentSpecInjector == null
        ? () => _currentSpecInjector.module(fnOrModule, stack)
        : _currentSpecInjector.module(fnOrModule, stack);
  }
}

/**
 * Call this method in your test harness [setUp] method to setup the injector.
 */
void setUpInjector() {
  _currentSpecInjector = new _SpecInjector();
  _currentSpecInjector.module((Module m) {
    m
      ..install(applicationFactory().ngModule)
      ..install(new AngularMockModule());
  });
}

/**
 * Call this method in your test harness [tearDown] method to cleanup the injector.
 */
void tearDownInjector() {
  _currentSpecInjector = null;
}
