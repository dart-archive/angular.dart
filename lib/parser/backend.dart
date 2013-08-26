part of parser_library;

class ParserBackend {
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

  Expression objectIndex(obj, indexFn, evalError) {
    return new Expression((self, [locals]){
      var i = indexFn.eval(self, locals);
      var o = obj.eval(self, locals),
      v, p;

      v = objectIndexGetField(o, i, evalError);

      return v;
    }, (self, value, [locals]) =>
    objectIndexSetField(obj.eval(self, locals), indexFn.eval(self, locals), value, evalError)
    );
  }

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
