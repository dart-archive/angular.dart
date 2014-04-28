part of angular.directive;

@Decorator(selector: 'input[ng-model-options]')
class NgModelOptions {
  int _debounceDefaultValue = 0;
  int _debounceBlurValue = null;
  int _debounceChangeValue = null;
  int _debounceInputValue = null;

  static const String _debounceDefaultKey = "default";
  static const String _debounceBlurKey = "blur";
  static const String _debounceChangeKey = "change";
  static const String _debounceInputKey = "input";

  NgModelOptions(NodeAttrs attrs) {
    print("options: " + attrs["ng-model-options"].replaceFirst("debounce", "'debounce'").replaceAll("'", "\""));
    Map options = convert.JSON.decode(attrs["ng-model-options"].replaceFirst("debounce", "'debounce'").replaceAll("'", "\""));

    if (options["debounce"].containsKey(_debounceDefaultKey)) _debounceDefaultValue = options["debounce"][_debounceDefaultKey];
    if (options["debounce"].containsKey(_debounceBlurKey)) _debounceBlurValue = options["debounce"][_debounceBlurKey];
    if (options["debounce"].containsKey(_debounceChangeKey)) _debounceChangeValue = options["debounce"][_debounceChangeKey];
    if (options["debounce"].containsKey(_debounceInputKey)) _debounceInputValue = options["debounce"][_debounceInputKey];
  }

  async.Timer _blurTimer;
  void executeBlurFunc(func()) {
    if (_blurTimer != null && !_blurTimer.isActive) _blurTimer.cancel();
    
    var delay = _debounceBlurValue == null ? _debounceDefaultValue : _debounceBlurValue;
    _runFuncDebounced(delay, func, (timer)=>_blurTimer = timer);
  }

  async.Timer _changeTimer;
  void executeChangeFunc(func()) {
    if (_changeTimer != null && !_changeTimer.isActive) _changeTimer.cancel();
    
    var delay = _debounceChangeValue == null ? _debounceDefaultValue : _debounceChangeValue;
    _runFuncDebounced(delay, func, (timer)=>_changeTimer = timer);
  }

  async.Timer _inputTimer;
  void executeInputFunc(func()) {
    if (_inputTimer != null && _inputTimer.isActive) _inputTimer.cancel();
    
    var delay = _debounceInputValue == null ? _debounceDefaultValue : _debounceInputValue;
    _runFuncDebounced(delay, func, (timer) => _inputTimer = timer);
  }
  
  void _runFuncDebounced(int delay, func(), setTimer(async.Timer timer)){
    if(delay == 0)
      func();
    else
      setTimer(new async.Timer(new Duration(milliseconds: delay), func));
  }
}
