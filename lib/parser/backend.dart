part of parser_library;

class BoundExpression {
  var _context;
  Expression expression;

  BoundExpression(this._context, Expression this.expression);

  call([locals]) => expression.eval(_context, locals);
  assign(value, [locals]) => expression.assign(_context, value, locals);
}

class Expression implements ParserAST {
  ParsedGetter eval;
  ParsedSetter assign;
  String exp;
  List parts;

  Expression(ParsedGetter this.eval, [ParsedSetter this.assign]);

  bind(context) => new BoundExpression(context, this);

  get assignable => assign != null;
}

var undefined_ = const Symbol("UNDEFINED");

class ParserBackend {
  static Expression ZERO = new Expression((_, [_x]) => 0);

  static getter(String path) {
    List<String> keys = path.split('.');
    List<Symbol> symbols = keys.map((key) => new Symbol(key)).toList();

    if (keys.isEmpty) {
      return (self, [locals]) => self;
    } else {
      return (dynamic self, [Map locals]) {
        if (self == null) {
          return null;
        }

        // Cache for local closure access
        List<String> _keys = keys;
        List<Symbol> _symbols = symbols;
        var _pathKeysLength = _keys.length;

        num i = 0;
        if (locals != null) {
          dynamic selfNext = locals[_keys[0]];
          if (selfNext == null) {
            if (locals.containsKey(_keys[0])) {
              return null;
            }
          } else {
            i++;
            self = selfNext;
          }
        }
        for (; i < _pathKeysLength; i++) {
          if (self is Map) {
            self = self[_keys[i]];
          } else {
            self = reflect(self).getField(_symbols[i]).reflectee;
          }
          if (self == null) {
            return null;
          }
        }
        return self;
      };
    }
  }

  static setter(String path) {
    List<String> keys = path.split('.');
    List<Symbol> symbols = keys.map((key) => new Symbol(key)).toList();
    return (dynamic self, dynamic value, [Map locals]) {
      num i = 0;
      List<String> _keys = keys;
      List<Symbol> _symbols = symbols;
      var keyLengthLessOne = _keys.length - 1;

      dynamic selfNext;
      if (locals != null && i < keyLengthLessOne) {
        selfNext = locals[_keys[0]];
        if (selfNext == null) {
          if (locals.containsKey(_keys[0])) {
            return null;
          }
        } else {
          i++;
          self = selfNext;
        }
      }

      for (; i < keyLengthLessOne; i++) {
        if (self is Map) {
          selfNext = self[_keys[i]];
        } else {
          selfNext = reflect(self).getField(_symbols[i]).reflectee;
        }

        if (selfNext == null) {
          selfNext = {};
          if (self is Map) {
            self[_keys[i]] = selfNext;
          } else {
            reflect(self).setField(_symbols[i], selfNext);
          }
        }
        self = selfNext;
      }
      if (self is Map) {
        self[_keys[keyLengthLessOne]] = value;
      } else {
        reflect(self).setField(_symbols[keyLengthLessOne], value);
      }
      return value;
    };
  }

  _op(opKey) => OPERATORS[opKey];

  Expression binaryFn(Expression left, String op, Expression right) =>
      new Expression((self, [locals]) => _op(op)(self, locals, left, right));

  Expression unaryFn(String op, Expression right) =>
      new Expression((self, [locals]) => _op(op)(self, locals, right, null));

  Expression assignment(Expression left, Expression right, evalError) =>
      new Expression((self, [locals]) {
        try {
          return left.assign(self, right.eval(self, locals), locals);
        } catch (e, s) {
          throw evalError('Caught $e', s);
        }
      });

  Expression multipleStatements(statements) =>
      new Expression((self, [locals]) {
        var value;
        for ( var i = 0; i < statements.length; i++) {
          var statement = statements[i];
          if (statement != null)
            value = statement.eval(self, locals);
        }
        return value;
      });

  Expression functionCall(fn, fnName, argsFn, evalError) =>
      new Expression((self, [locals]){
        List args = [];
        for ( var i = 0; i < argsFn.length; i++) {
          args.add(argsFn[i].eval(self, locals));
        }
        var userFn = safeFunctionCall(fn.eval(self, locals), fnName, evalError);

        return relaxFnApply(userFn, args);
      });

  Expression arrayDeclaration(elementFns) =>
      new Expression((self, [locals]){
        var array = [];
        for ( var i = 0; i < elementFns.length; i++) {
          array.add(elementFns[i].eval(self, locals));
        }
        return array;
      });

  Expression objectIndex(obj, indexFn, evalError) =>
      new Expression((self, [locals]) {
        var i = indexFn.eval(self, locals);
        var o = obj.eval(self, locals),
        v, p;

        v = objectIndexGetField(o, i, evalError);

        return v;
      }, (self, value, [locals]) =>
          objectIndexSetField(obj.eval(self, locals),
              indexFn.eval(self, locals), value, evalError)
      );

  Expression fieldAccess(object, field) {
    var setterFn = setter(field);
    var getterFn = getter(field);
    return new Expression(
        (self, [locals]) => getterFn(object.eval(self, locals)),
        (self, value, [locals]) => setterFn(object.eval(self, locals), value));
  }

  Expression object(keyValues) =>
      new Expression((self, [locals]){
        var object = {};
        for ( var i = 0; i < keyValues.length; i++) {
          var keyValue = keyValues[i];
          var value = keyValue["value"].eval(self, locals);
          object[keyValue["key"]] = value;
        }
        return object;
      });

  Expression profiled(value, _perf, text) {
    var wrappedGetter = (s, [l]) =>
    _perf.time('angular.parser.getter', () => value.eval(s, l), text);
    var wrappedAssignFn = null;
    if (value.assign != null) {
      wrappedAssignFn = (s, v, [l]) =>
      _perf.time('angular.parser.assign',
          () => value.assign(s, v, l), text);
    }
    return new Expression(wrappedGetter, wrappedAssignFn);
  }

  Expression fromOperator(String op) =>
      new Expression((s, [l]) => OPERATORS[op](s, l, null, null));

  Expression getterSetter(key) =>
      new Expression(getter(key), setter(key));

  Expression value(v) =>
      new Expression((self, [locals]) => v);

  zero() => ZERO;
}
