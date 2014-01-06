part of angular.core.parser;

typedef dynamic LocalsWrapper(dynamic context, dynamic locals);

class BoundExpression {
  var _context;
  LocalsWrapper _localsWrapper;
  Expression expression;

  BoundExpression(this._context, this.expression, this._localsWrapper);
  _localContext(locals) {
    if (locals != null) {
      if (_localsWrapper == null) {
          throw new StateError("Locals $locals provided, but no LocalsWrapper strategy.");
      }
      return _localsWrapper(_context, locals);
    }
    return _context;
  }

  call([locals]) => expression.eval(_localContext(locals));
  assign(value, [locals]) => expression.assign(_localContext(locals), value);
}

class Expression implements ParserAST {
  final ParsedGetter eval;
  final ParsedSetter assign;

  String exp;
  List parts;

  // Expressions that represent field accesses have a couple of
  // extra fields. We use that to generate an optimized closure
  // for calling fields of objects without having to load the
  // field separately.
  Expression fieldHolder;
  String fieldName;
  bool get isFieldAccess => fieldHolder != null;

  Expression(ParsedGetter this.eval, [ParsedSetter this.assign]);

  bind(context, [localsWrapper]) => new BoundExpression(context, this, localsWrapper);

  get assignable => assign != null;
}

@NgInjectableService()
class GetterSetter {
  static stripTrailingNulls(List l) {
    while (l.length > 0 && l.last == null) {
      l.removeLast();
    }
    return l;
  }

  static  _computeUseInstanceMembers() {
    try {
      reflect(Object).type.instanceMembers;
      return true;
    } catch (e) {
      return false;
    }
  }

   final bool _useInstanceMembers = _computeUseInstanceMembers();

  _containsKey(InstanceMirror instanceMirror, Symbol symbol) {
    dynamic type = (instanceMirror.type as dynamic);
    var members = _useInstanceMembers ? type.instanceMembers : type.members;
    return members.containsKey(symbol);
  }

  _maybeInvoke(instanceMirror, symbol) {
    if (_containsKey(instanceMirror, symbol)) {
      MethodMirror methodMirror = instanceMirror.type.members[symbol];
      return relaxFnArgs(([a0, a1, a2, a3, a4, a5]) {
        var args = stripTrailingNulls([a0, a1, a2, a3, a4, a5]);
        return instanceMirror.invoke(symbol, args).reflectee;
      });
    }
    return null;
  }

  Map<String, Function> _getter_cache = {};

  Function getter(String key) {
    var value = _getter_cache[key];
    if (value != null) return value;
    return _getter_cache[key] = _getter(key);
  }

  Function _getter(String key) {
    var symbol = new Symbol(key);
    Map<ClassMirror, Function> fieldCache = {};
    return (o) {
      InstanceMirror instanceMirror = reflect(o);
      ClassMirror classMirror = instanceMirror.type;
      Function fn = fieldCache[classMirror];
      if (fn == null) {
        try {
          return (fieldCache[classMirror] = (instanceMirror) => instanceMirror.getField(symbol).reflectee)(instanceMirror);
        } on NoSuchMethodError catch (e) {
          var value = (fieldCache[classMirror] = (instanceMirror) => _maybeInvoke(instanceMirror, symbol))(instanceMirror);
          if (value == null) { rethrow; }
          return value;
        } on UnsupportedError catch (e) {
          var value = (fieldCache[classMirror] = (instanceMirror) => _maybeInvoke(instanceMirror, symbol))(instanceMirror);
          if (value == null) { rethrow; }
          return value;
        }
      } else {
        return fn(instanceMirror);
      }
    };
  }

  Function setter(String key) {
    var symbol = new Symbol(key);
    return (o, v) {
      reflect(o).setField(symbol, v);
      return v;
    };
  }
}

var undefined_ = const Symbol("UNDEFINED");

@NgInjectableService()
class ParserBackend {
  GetterSetter _getterSetter;
  FilterMap _filters;

  ParserBackend(GetterSetter this._getterSetter, FilterMap this._filters);

  static Expression ZERO = new Expression((_, [_x]) => 0);

  getter(String path) {
    List<String> keys = path.split('.');
    List<Function> getters = keys.map(_getterSetter.getter).toList();

    if (getters.isEmpty) {
      return (self) => self;
    } else {
      return (dynamic self) {
        if (self == null) {
          return null;
        }

        // Cache for local closure access
        List<String> _keys = keys;
        List<Function> _getters = getters;
        var _gettersLength = _getters.length;

        num i = 0;
        for (; i < _gettersLength; i++) {
          if (self is Map) {
            self = self[_keys[i]];
          } else {
            self = _getters[i](self);
          }
          if (self == null) {
            return null;
          }
        }
        return self;
      };
    }
  }

  setter(String path) {
    List<String> keys = path.split('.');
    List<Function> getters = keys.map(_getterSetter.getter).toList();
    List<Function> setters = keys.map(_getterSetter.setter).toList();
    return (dynamic self, dynamic value) {
      num i = 0;
      List<String> _keys = keys;
      List<Function> _getters = getters;
      List<Function> _setters = setters;
      var setterLengthMinusOne = _keys.length - 1;

      dynamic selfNext;
      for (; i < setterLengthMinusOne; i++) {
        if (self is Map) {
          selfNext = self[_keys[i]];
        } else {
          selfNext = _getters[i](self);
        }

        if (selfNext == null) {
          selfNext = {};
          if (self is Map) {
            self[_keys[i]] = selfNext;
          } else {
            _setters[i](self, selfNext);
          }
        }
        self = selfNext;
      }
      if (self is Map) {
        self[_keys[setterLengthMinusOne]] = value;
      } else {
        _setters[i](self, value);
      }
      return value;
    };
  }

  List evalList(List<Expression> list, self) {
    int length = list.length;
    List result = new List(length);
    for (int i = 0; i < length; i++) {
      result[i] = list[i].eval(self);
    }
    return result;
  }

  _op(opKey) => OPERATORS[opKey];

  Expression ternaryFn(Expression cond, Expression _true, Expression _false) =>
      new Expression((self) => _op('?')(
          self, cond, _true, _false));

  Expression binaryFn(Expression left, String op, Expression right) =>
      new Expression((self) => _op(op)(self, left, right));

  Expression unaryFn(String op, Expression right) =>
      new Expression((self) => _op(op)(self, right, null));

  Expression assignment(Expression left, Expression right, evalError) =>
      new Expression((self) {
        try {
          return left.assign(self, right.eval(self));
        } catch (e, s) {
          throw evalError('Caught $e', s);
        }
      });

  Expression multipleStatements(statements) =>
      new Expression((self) {
        var value;
        for ( var i = 0; i < statements.length; i++) {
          var statement = statements[i];
          if (statement != null)
            value = statement.eval(self);
        }
        return value;
      });

  Expression functionCall(fn, fnName, argsFn, evalError) {
    if (fn.isFieldAccess) {
      Symbol key = new Symbol(fn.fieldName);
      return new Expression((self) {
        List args = evalList(argsFn, self);
        var holder = fn.fieldHolder.eval(self);
        InstanceMirror instanceMirror = reflect(holder);
        return instanceMirror.invoke(key, args).reflectee;
      });
    } else {
      return new Expression((self) {
        List args = evalList(argsFn, self);
        var userFn = safeFunctionCall(fn.eval(self), fnName, evalError);
        return relaxFnApply(userFn, args);
      });
    }
  }

  Expression arrayDeclaration(elementFns) =>
      new Expression((self){
        var array = [];
        for ( var i = 0; i < elementFns.length; i++) {
          array.add(elementFns[i].eval(self));
        }
        return array;
      });

  Expression objectIndex(obj, indexFn, evalError) =>
      new Expression((self) {
        var i = indexFn.eval(self);
        var o = obj.eval(self),
        v, p;

        v = objectIndexGetField(o, i, evalError);

        return v;
      }, (self, value) =>
          objectIndexSetField(obj.eval(self),
              indexFn.eval(self), value, evalError)
      );

  Expression fieldAccess(object, field) {
    var setterFn = setter(field);
    var getterFn = getter(field);
    return new Expression(
        (self) => getterFn(object.eval(self)),
        (self, value) => setterFn(object.eval(self), value))
            ..fieldHolder = object
            ..fieldName = field;
  }

  Expression object(keyValues) =>
      new Expression((self){
        var object = {};
        for ( var i = 0; i < keyValues.length; i++) {
          var keyValue = keyValues[i];
          var value = keyValue["value"].eval(self);
          object[keyValue["key"]] = value;
        }
        return object;
      });

  Expression profiled(value, _perf, text) {
    if (value is FilterExpression) return value;
    var wrappedGetter = (s) =>
    _perf.time('angular.parser.getter', () => value.eval(s), text);
    var wrappedAssignFn = null;
    if (value.assign != null) {
      wrappedAssignFn = (s, v) =>
      _perf.time('angular.parser.assign',
          () => value.assign(s, v), text);
    }
    return new Expression(wrappedGetter, wrappedAssignFn);
  }

  Expression fromOperator(String op) =>
      new Expression((s) => OPERATORS[op](s, null, null));

  Expression getterSetter(key) =>
      new Expression(getter(key), setter(key));

  Expression value(v) =>
      new Expression((self) => v);

  zero() => ZERO;

  Expression filter(String filterName,
                         Expression leftHandSide,
                         List<Expression> parameters,
                         Function evalError) {
    var filterFn = _filters(filterName);
    return new FilterExpression(filterFn, leftHandSide, parameters);
  }
}

class FilterExpression extends Expression {
  final Function filterFn;
  final Expression leftHandSide;
  final List<Expression> parameters;

  FilterExpression(Function this.filterFn,
                   Expression this.leftHandSide,
                   List<Expression> this.parameters): super(null);

  get eval => _eval;

  dynamic _eval(self) {
    var args = [leftHandSide.eval(self)];
    for ( var i = 0; i < parameters.length; i++) {
      args.add(parameters[i].eval(self));
    }
    return Function.apply(filterFn, args);
  }
}
