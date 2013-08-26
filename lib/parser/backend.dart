part of parser_library;

class ParserBackend {
  static Expression ZERO = new Expression((_, [_x]) => 0);

  static stripTrailingNulls(List l) {
    while (l.length > 0 && l.last == null) {
      l.removeLast();
    }
    return l;
  }

  static _getterChild(value, childKey) {
    if (value is List && childKey is num) {
      if (childKey < value.length) {
        return value[childKey];
      }
    } else if (value is Map) {
      // TODO: We would love to drop the 'is Map' for a more generic 'is Getter'
      if (childKey is String && value.containsKey(childKey)) {
        return value[childKey];
      }
    } else {
      InstanceMirror instanceMirror = reflect(value);
      Symbol curSym = new Symbol(childKey);

      try {
        // maybe it is a member field?
        return instanceMirror.getField(curSym).reflectee;
      } on NoSuchMethodError catch (e) {
        // maybe it is a member method?
        if (instanceMirror.type.members.containsKey(curSym)) {
          MethodMirror methodMirror = instanceMirror.type.members[curSym];
          return relaxFnArgs(([a0, a1, a2, a3, a4, a5]) {
            var args = stripTrailingNulls([a0, a1, a2, a3, a4, a5]);
            return instanceMirror.invoke(curSym, args).reflectee;
          });
        }
        rethrow;
      }
    }
    return undefined_;
  }

  static getter(self, locals, path) {
    if (self == null) {
      return null;
    }

    List<String> pathKeys = path.split('.');
    var pathKeysLength = pathKeys.length;
    var value = undefined_;

    if (pathKeysLength == 0) { return self; }

    var currentValue = self;
    for (var i = 0; i < pathKeysLength; i++) {
      var curKey = pathKeys[i];
      if (locals == null) {
        currentValue = _getterChild(currentValue, curKey);
      } else {
        currentValue = _getterChild(locals, curKey);
        locals = null;
        if (currentValue == undefined_) {
          currentValue = _getterChild(self, curKey);
        }
      }
      if (currentValue == null || currentValue == undefined_) { return null; }
    }
    return currentValue;
  }

  static _setterChild(obj, childKey, value) {
    if (obj is List && childKey is num) {
      if (childKey < value.length) {
        return obj[childKey] = value;
      }
    } else if (obj is Map) {
      // TODO: We would love to drop the 'is Map' for a more generic 'is Getter'
      if (childKey is String) {
        return obj[childKey] = value;
      }
    } else {
      InstanceMirror instanceMirror = reflect(obj);
      Symbol curSym = new Symbol(childKey);
      // maybe it is a member field?
      return instanceMirror.setField(curSym, value).reflectee;
    }
    throw "Could not set $childKey value $value  obj:${obj is Map}";
  }

  static setter(obj, path, setValue) {
    var element = path.split('.');
    for (var i = 0; element.length > 1; i++) {
      var key = element.removeAt(0);
      var propertyObj = _getterChild(obj, key);
      if (propertyObj == null || propertyObj == undefined_) {
        propertyObj = {};
        _setterChild(obj, key, propertyObj);
      }
      obj = propertyObj;
    }
    return _setterChild(obj, element.removeAt(0), setValue);
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

  Expression fieldAccess(object, field) =>
      new Expression(
              (self, [locals]) =>
          getter(object.eval(self, locals), null, field),
              (self, value, [locals]) =>
          setter(object.eval(self, locals), field, value));

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
      new Expression(
          (self, [locals]) => getter(self, locals, key),
          (self, value, [locals]) => setter(self, key, value));

  Expression value(v) =>
      new Expression((self, [locals]) => v);

  zero() => ZERO;
}
