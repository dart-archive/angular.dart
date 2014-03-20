part of angular.filter;

/**
 * This filter returns its argument unchanged but, for `List` and `Map` 
 * arguments, it causes the argument contents to be observed (as opposed to
 * only its identity).
 *
 * Example:
 *
 *     {{ list | observe }}
 */
@NgFilter(name: 'observe')
class ObserveFilter implements Function {
  dynamic call(dynamic _) => _;
}

/**
 * This filter returns the argument's value of the named field. Use this only 
 * when the field get operation is known to be pure (side-effect free).
 *
 * Examples:
 *
 *     {{  map | field:'keys' }}
 *     {{  map | field:'values' }}
 *     {{ list | field:'reversed' }}
 */
@NgFilter(name: 'field')
class GetPureFieldFilter implements Function {
  dynamic call(Object o, String fieldName) =>
      o == null ? null :
        reflect(o).getField(new Symbol(fieldName)).reflectee;
}

/**
 * This filter returns the result of invoking the named method on the filter 
 * argument. Use this only when the method is known to be pure (side-effect free).
 *
 * Examples:
 *
 *     <span>{{ expression | method:'toString' }}</span>
 *     <ul><li ng-repeat="n in (names | method:'split':[','])">{{n}}</li></ul>
 * 
 * The first example is useful when _expression_ yields a new identity but its
 * string rendering is unchanged.
 */
@NgFilter(name: 'method')
class ApplyPureMethodFilter implements Function {
  dynamic call(Object o, String methodName, [args, Map<String,dynamic> namedArgs]) {
    if (o == null) return null;
        
    if (args is Map) {
      namedArgs = args;
      args = const [];
    } else if (args == null) {
      args = const [];
    }
    final Map<Symbol,dynamic> _namedArgs = namedArgs == null ?
        const <Symbol,dynamic>{} : <Symbol,dynamic>{};
    if (namedArgs != null) {
      namedArgs.forEach((k,v) => _namedArgs[new Symbol(k)] = v);
    }
    return reflect(o).invoke(new Symbol(methodName), args, _namedArgs).reflectee;
  }
}
