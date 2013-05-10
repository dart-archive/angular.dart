part of angular;

class ExceptionHandler {
  call(error, stack, [reason]){
    throw "$error \nORIGINAL STACKTRACE:\n $stack";
  }
}
