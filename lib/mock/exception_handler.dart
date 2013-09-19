part of angular.mock;

class RethrowExceptionHandler extends ExceptionHandler {
  call(error, stack, [reason]){
    throw "$error $reason \nORIGINAL STACKTRACE:\n $stack";
  }
}

class ExceptionWithStack {
  final dynamic error;
  final dynamic stack;
  ExceptionWithStack(dynamic this.error, dynamic this.stack);
  toString() => "$error\n$stack";
}

class LoggingExceptionHandler implements ExceptionHandler {
  final List<ExceptionWithStack> errors = [];

  call(error, stack, [reason]) {
    errors.add(new ExceptionWithStack(error, stack));
  }

  assertEmpty() {
    if (errors.length > 0) {
      throw new ArgumentError('Exception Log not empty:\n$errors');
    }
  }
}
