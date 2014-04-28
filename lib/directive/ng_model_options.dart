part of angular.directive;

@Decorator(selector: 'input[ng-model-options]')
class NgModelOptions {
  int _debounceDefaultValue = 0;
  int _debounceBlurValue = null;
  int _debounceChangeValue = null;
  int _debounceInputValue = null;

  static const String DEBOUNCE_DEFAULT_KEY = "default";
  static const String DEBOUNCE_BLUR_KEY = "blur";
  static const String DEBOUNCE_CHANGE_KEY = "change";
  static const String DEBOUNCE_INPUT_KEY = "input";

  NgModelOptions(NodeAttrs attrs) {
    Map options = convert.JSON.decode(attrs["ng-model-options"].replaceFirst("debounce", "'debounce'").replaceAll("'", "\""));

    if (options["debounce"].containsKey(DEBOUNCE_DEFAULT_KEY)) _debounceDefaultValue = options["debounce"][DEBOUNCE_DEFAULT_KEY];
    _debounceBlurValue = options["debounce"][DEBOUNCE_BLUR_KEY];
    _debounceChangeValue = options["debounce"][DEBOUNCE_CHANGE_KEY];
    _debounceInputValue = options["debounce"][DEBOUNCE_INPUT_KEY];
  }

  async.Timer _blurTimer;
  void executeBlurFunc(func()) {
    var delay = _debounceBlurValue == null ? _debounceDefaultValue : _debounceBlurValue;
    _runFuncDebounced(delay, func, (timer)=>_blurTimer = timer,_blurTimer);
  }

  async.Timer _changeTimer;
  void executeChangeFunc(func()) {
    var delay = _debounceChangeValue == null ? _debounceDefaultValue : _debounceChangeValue;
    _runFuncDebounced(delay, func, (timer)=>_changeTimer = timer, _changeTimer);
  }

  async.Timer _inputTimer;
  void executeInputFunc(func()) {
    var delay = _debounceInputValue == null ? _debounceDefaultValue : _debounceInputValue;
    _runFuncDebounced(delay, func, (timer) => _inputTimer = timer, _inputTimer);
  }
  
  void _runFuncDebounced(int delay, func(), setTimer(async.Timer timer), async.Timer timer){
    if (timer != null && timer.isActive) timer.cancel();
    
    if(delay == 0){
      func();
    }      
    else{
      setTimer(new async.Timer(new Duration(milliseconds: delay), func));
    }
  }
}
