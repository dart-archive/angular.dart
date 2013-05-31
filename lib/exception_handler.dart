part of angular;

class ExceptionHandler {
  call(error, stack, [reason]){
    throw "$error \nORIGINAL STACKTRACE:\n $stack";
  }
}

class LogExceptionHandler implements ExceptionHandler {
  List errors = [];

  call(error, stack, [reason]){
    errors.add(error);
  }
}
