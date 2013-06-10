part of angular;

class ExceptionHandler {
  call(error, stack, [reason]){
    throw "$error \nORIGINAL STACKTRACE:\n $stack";
  }
}

class ExceptionWithStack {
  var error;
  var stack;
  ExceptionWithStack(this.error, this.stack);
  toString() => "$error\n$stack";
}

class LogExceptionHandler implements ExceptionHandler {
  List errors = [];

  call(error, stack, [reason]){
    errors.add(new ExceptionWithStack(error, stack));
  }

  assertEmpty() {
    if (errors.length > 0) {
      throw new ArgumentError('Exception Log not empty:\n$errors');
    }
  }
}
