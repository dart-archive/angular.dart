part of angular.directive;

/**
 * Allows you to specify custom behavior for DOM UI events such as mouse,
 * keyboard and touch events.
 *
 * The custom behavior is specified via an Angular binding expression specified
 * on the `ng-`*event* directive (e.g. `ng-click`).  This expression is evaluated
 * on the correct `scope` every time the event occurs.  The event is available
 * to the expression as `$event`.
 *
 * This is more secure than inline DOM handlers in HTML that execute arbitrary
 * JavaScript code and have access to globals instead of the scope without the
 * safety constraints of the Angular expression language.
 *
 * Example:
 *
 *     <button ng-click="lastEvent='Click'"
 *             ng-doubleclick="lastEvent='DblClick'">
 *         Button
 *     </button>
 *
 * The full list of supported handlers are:
 *
 * - [ng-abort]
 * - [ng-beforecopy]
 * - [ng-beforecut]
 * - [ng-beforepaste]
 * - [ng-blur]
 * - [ng-change]
 * - [ng-click]
 * - [ng-contextmenu]
 * - [ng-copy]
 * - [ng-cut]
 * - [ng-doubleclick]
 * - [ng-drag]
 * - [ng-dragend]
 * - [ng-dragenter]
 * - [ng-dragleave]
 * - [ng-dragover]
 * - [ng-dragstart]
 * - [ng-drop]
 * - [ng-error]
 * - [ng-focus]
 * - [ng-fullscreenchange]
 * - [ng-fullscreenerror]'
 * - [ng-input]
 * - [ng-invalid]
 * - [ng-keydown]
 * - [ng-keypress]
 * - [ng-keyup]
 * - [ng-load]
 * - [ng-mousedown]
 * - [ng-mouseenter]
 * - [ng-mouseleave]
 * - [ng-mousemove]
 * - [ng-mouseout]
 * - [ng-mouseover]
 * - [ng-mouseup]
 * - [ng-mousewheel]
 * - [ng-paste]
 * - [ng-reset]
 * - [ng-scroll]
 * - [ng-search]
 * - [ng-select]
 * - [ng-selectstart]
 * - [ng-speechchange] (documented in dart but not available)
 * - [ng-submit]
 * - [ng-toucheancel]
 * - [ng-touchend]
 * - [ng-touchenter]
 * - [ng-touchleave]
 * - [ng-touchmove]
 * - [ng-touchstart]
 * - [ng-transitionend]
 */
@Decorator(selector: '[ng-abort]',            map: const {'ng-abort':            '&onAbort'})
@Decorator(selector: '[ng-beforecopy]',       map: const {'ng-beforecopy':       '&onBeforeCopy'})
@Decorator(selector: '[ng-beforecut]',        map: const {'ng-beforecut':        '&onBeforeCut'})
@Decorator(selector: '[ng-beforepaste]',      map: const {'ng-beforepaste':      '&onBeforePaste'})
@Decorator(selector: '[ng-blur]',             map: const {'ng-blur':             '&onBlur'})
@Decorator(selector: '[ng-change]',           map: const {'ng-change':           '&onChange'})
@Decorator(selector: '[ng-click]',            map: const {'ng-click':            '&onClick'})
@Decorator(selector: '[ng-contextmenu]',      map: const {'ng-contextmenu':      '&onContextMenu'})
@Decorator(selector: '[ng-copy]',             map: const {'ng-copy':             '&onCopy'})
@Decorator(selector: '[ng-cut]',              map: const {'ng-cut':              '&onCut'})
@Decorator(selector: '[ng-doubleclick]',      map: const {'ng-doubleclick':      '&onDoubleClick'})
@Decorator(selector: '[ng-drag]',             map: const {'ng-drag':             '&onDrag'})
@Decorator(selector: '[ng-dragend]',          map: const {'ng-dragend':          '&onDragEnd'})
@Decorator(selector: '[ng-dragenter]',        map: const {'ng-dragenter':        '&onDragEnter'})
@Decorator(selector: '[ng-dragleave]',        map: const {'ng-dragleave':        '&onDragLeave'})
@Decorator(selector: '[ng-dragover]',         map: const {'ng-dragover':         '&onDragOver'})
@Decorator(selector: '[ng-dragstart]',        map: const {'ng-dragstart':        '&onDragStart'})
@Decorator(selector: '[ng-drop]',             map: const {'ng-drop':             '&onDrop'})
@Decorator(selector: '[ng-error]',            map: const {'ng-error':            '&onError'})
@Decorator(selector: '[ng-focus]',            map: const {'ng-focus':            '&onFocus'})
@Decorator(selector: '[ng-fullscreenchange]', map: const {'ng-fullscreenchange': '&onFullscreenChange'})
@Decorator(selector: '[ng-fullscreenerror]',  map: const {'ng-fullscreenerror':  '&onFullscreenError'})
@Decorator(selector: '[ng-input]',            map: const {'ng-input':            '&onInput'})
@Decorator(selector: '[ng-invalid]',          map: const {'ng-invalid':          '&onInvalid'})
@Decorator(selector: '[ng-keydown]',          map: const {'ng-keydown':          '&onKeyDown'})
@Decorator(selector: '[ng-keypress]',         map: const {'ng-keypress':         '&onKeyPress'})
@Decorator(selector: '[ng-keyup]',            map: const {'ng-keyup':            '&onKeyUp'})
@Decorator(selector: '[ng-load]',             map: const {'ng-load':             '&onLoad'})
@Decorator(selector: '[ng-mousedown]',        map: const {'ng-mousedown':        '&onMouseDown'})
@Decorator(selector: '[ng-mouseenter]',       map: const {'ng-mouseenter':       '&onMouseEnter'})
@Decorator(selector: '[ng-mouseleave]',       map: const {'ng-mouseleave':       '&onMouseLeave'})
@Decorator(selector: '[ng-mousemove]',        map: const {'ng-mousemove':        '&onMouseMove'})
@Decorator(selector: '[ng-mouseout]',         map: const {'ng-mouseout':         '&onMouseOut'})
@Decorator(selector: '[ng-mouseover]',        map: const {'ng-mouseover':        '&onMouseOver'})
@Decorator(selector: '[ng-mouseup]',          map: const {'ng-mouseup':          '&onMouseUp'})
@Decorator(selector: '[ng-mousewheel]',       map: const {'ng-mousewheel':       '&onMouseWheel'})
@Decorator(selector: '[ng-paste]',            map: const {'ng-paste':            '&onPaste'})
@Decorator(selector: '[ng-reset]',            map: const {'ng-reset':            '&onReset'})
@Decorator(selector: '[ng-scroll]',           map: const {'ng-scroll':           '&onScroll'})
@Decorator(selector: '[ng-search]',           map: const {'ng-search':           '&onSearch'})
@Decorator(selector: '[ng-select]',           map: const {'ng-select':           '&onSelect'})
@Decorator(selector: '[ng-selectstart]',      map: const {'ng-selectstart':      '&onSelectStart'})
//@Decorator(selector: '[ng-speechchange]',     map: const {'ng-speechchange':     '&onSpeechChange'})
@Decorator(selector: '[ng-submit]',           map: const {'ng-submit':           '&onSubmit'})
@Decorator(selector: '[ng-toucheancel]',      map: const {'ng-touchcancel':      '&onTouchCancel'})
@Decorator(selector: '[ng-touchend]',         map: const {'ng-touchend':         '&onTouchEnd'})
@Decorator(selector: '[ng-touchenter]',       map: const {'ng-touchenter':       '&onTouchEnter'})
@Decorator(selector: '[ng-touchleave]',       map: const {'ng-touchleave':       '&onTouchLeave'})
@Decorator(selector: '[ng-touchmove]',        map: const {'ng-touchmove':        '&onTouchMove'})
@Decorator(selector: '[ng-touchstart]',       map: const {'ng-touchstart':       '&onTouchStart'})
@Decorator(selector: '[ng-transitionend]',    map: const {'ng-transitionend':    '&onTransitionEnd'})
class NgEvent {
  // Is it better to use a map of listeners or have 29 properties on this object?  One would pretty
  // much only assign to one or two of those properties. I'm opting for the map since it's less
  // boilerplate code.
  var listeners = new HashMap<int, BoundExpression>();
  final dom.Element _element;
  final Scope _scope;

  NgEvent(this._element, this._scope);

  void _initListener(stream, BoundExpression handler) {
    int key = stream.hashCode;
    if (!listeners.containsKey(key)) {
      listeners[key] = handler;
      stream.listen((event) => handler({r"$event": event}));
    }
  }

  void set onAbort(value)             => _initListener(_element.onAbort,            value);
  void set onBeforeCopy(value)        => _initListener(_element.onBeforeCopy,       value);
  void set onBeforeCut(value)         => _initListener(_element.onBeforeCut,        value);
  void set onBeforePaste(value)       => _initListener(_element.onBeforePaste,      value);
  void set onBlur(value)              => _initListener(_element.onBlur,             value);
  void set onChange(value)            => _initListener(_element.onChange,           value);
  void set onClick(value)             => _initListener(_element.onClick,            value);
  void set onContextMenu(value)       => _initListener(_element.onContextMenu,      value);
  void set onCopy(value)              => _initListener(_element.onCopy,             value);
  void set onCut(value)               => _initListener(_element.onCut,              value);
  void set onDoubleClick(value)       => _initListener(_element.onDoubleClick,      value);
  void set onDrag(value)              => _initListener(_element.onDrag,             value);
  void set onDragEnd(value)           => _initListener(_element.onDragEnd,          value);
  void set onDragEnter(value)         => _initListener(_element.onDragEnter,        value);
  void set onDragLeave(value)         => _initListener(_element.onDragLeave,        value);
  void set onDragOver(value)          => _initListener(_element.onDragOver,         value);
  void set onDragStart(value)         => _initListener(_element.onDragStart,        value);
  void set onDrop(value)              => _initListener(_element.onDrop,             value);
  void set onError(value)             => _initListener(_element.onError,            value);
  void set onFocus(value)             => _initListener(_element.onFocus,            value);
  void set onFullscreenChange(value)  => _initListener(_element.onFullscreenChange, value);
  void set onFullscreenError(value)   => _initListener(_element.onFullscreenError,  value);
  void set onInput(value)             => _initListener(_element.onInput,            value);
  void set onInvalid(value)           => _initListener(_element.onInvalid,          value);
  void set onKeyDown(value)           => _initListener(_element.onKeyDown,          value);
  void set onKeyPress(value)          => _initListener(_element.onKeyPress,         value);
  void set onKeyUp(value)             => _initListener(_element.onKeyUp,            value);
  void set onLoad(value)              => _initListener(_element.onLoad,             value);
  void set onMouseDown(value)         => _initListener(_element.onMouseDown,        value);
  void set onMouseEnter(value)        => _initListener(_element.onMouseEnter,       value);
  void set onMouseLeave(value)        => _initListener(_element.onMouseLeave,       value);
  void set onMouseMove(value)         => _initListener(_element.onMouseMove,        value);
  void set onMouseOut(value)          => _initListener(_element.onMouseOut,         value);
  void set onMouseOver(value)         => _initListener(_element.onMouseOver,        value);
  void set onMouseUp(value)           => _initListener(_element.onMouseUp,          value);
  void set onMouseWheel(value)        => _initListener(_element.onMouseWheel,       value);
  void set onPaste(value)             => _initListener(_element.onPaste,            value);
  void set onReset(value)             => _initListener(_element.onReset,            value);
  void set onScroll(value)            => _initListener(_element.onScroll,           value);
  void set onSearch(value)            => _initListener(_element.onSearch,           value);
  void set onSelect(value)            => _initListener(_element.onSelect,           value);
  void set onSelectStart(value)       => _initListener(_element.onSelectStart,      value);
//  void set onSpeechChange(value)      => initListener(element.onSpeechChange,     value);
  void set onSubmit(value)            => _initListener(_element.onSubmit,           value);
  void set onTouchCancel(value)       => _initListener(_element.onTouchCancel,      value);
  void set onTouchEnd(value)          => _initListener(_element.onTouchEnd,         value);
  void set onTouchEnter(value)        => _initListener(_element.onTouchEnter,       value);
  void set onTouchLeave(value)        => _initListener(_element.onTouchLeave,       value);
  void set onTouchMove(value)         => _initListener(_element.onTouchMove,        value);
  void set onTouchStart(value)        => _initListener(_element.onTouchStart,       value);
  void set onTransitionEnd(value)     => _initListener(_element.onTransitionEnd,    value);
}
