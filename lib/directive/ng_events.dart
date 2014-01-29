part of angular.directive;

// NOTE(deboer): onXX functions are now typed as 'var' instead of 'Getter'
// to work-around https://code.google.com/p/dart/issues/detail?id=13519

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
 * - [ng-blur]
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
@NgDirective(selector: '[ng-abort]',            map: const {'ng-abort':            '&onAbort'})
@NgDirective(selector: '[ng-beforecopy]',       map: const {'ng-beforecopy':       '&onBeforeCopy'})
@NgDirective(selector: '[ng-beforecut]',        map: const {'ng-beforecut':        '&onBeforeCut'})
@NgDirective(selector: '[ng-beforepaste]',      map: const {'ng-beforepaste':      '&onBeforePaste'})
@NgDirective(selector: '[ng-blur]',             map: const {'ng-blur':             '&onBlur'})
@NgDirective(selector: '[ng-change]',           map: const {'ng-change':           '&onChange'})
@NgDirective(selector: '[ng-click]',            map: const {'ng-click':            '&onClick'})
@NgDirective(selector: '[ng-contextmenu]',      map: const {'ng-contextmenu':      '&onContextMenu'})
@NgDirective(selector: '[ng-copy]',             map: const {'ng-copy':             '&onCopy'})
@NgDirective(selector: '[ng-cut]',              map: const {'ng-cut':              '&onCut'})
@NgDirective(selector: '[ng-doubleclick]',      map: const {'ng-doubleclick':      '&onDoubleClick'})
@NgDirective(selector: '[ng-drag]',             map: const {'ng-drag':             '&onDrag'})
@NgDirective(selector: '[ng-dragend]',          map: const {'ng-dragend':          '&onDragEnd'})
@NgDirective(selector: '[ng-dragenter]',        map: const {'ng-dragenter':        '&onDragEnter'})
@NgDirective(selector: '[ng-dragleave]',        map: const {'ng-dragleave':        '&onDragLeave'})
@NgDirective(selector: '[ng-dragover]',         map: const {'ng-dragover':         '&onDragOver'})
@NgDirective(selector: '[ng-dragstart]',        map: const {'ng-dragstart':        '&onDragStart'})
@NgDirective(selector: '[ng-drop]',             map: const {'ng-drop':             '&onDrop'})
@NgDirective(selector: '[ng-error]',            map: const {'ng-error':            '&onError'})
@NgDirective(selector: '[ng-focus]',            map: const {'ng-focus':            '&onFocus'})
@NgDirective(selector: '[ng-fullscreenchange]', map: const {'ng-fullscreenchange': '&onFullscreenChange'})
@NgDirective(selector: '[ng-fullscreenerror]',  map: const {'ng-fullscreenerror':  '&onFullscreenError'})
@NgDirective(selector: '[ng-input]',            map: const {'ng-input':            '&onInput'})
@NgDirective(selector: '[ng-invalid]',          map: const {'ng-invalid':          '&onInvalid'})
@NgDirective(selector: '[ng-keydown]',          map: const {'ng-keydown':          '&onKeyDown'})
@NgDirective(selector: '[ng-keypress]',         map: const {'ng-keypress':         '&onKeyPress'})
@NgDirective(selector: '[ng-keyup]',            map: const {'ng-keyup':            '&onKeyUp'})
@NgDirective(selector: '[ng-load]',             map: const {'ng-load':             '&onLoad'})
@NgDirective(selector: '[ng-mousedown]',        map: const {'ng-mousedown':        '&onMouseDown'})
@NgDirective(selector: '[ng-mouseenter]',       map: const {'ng-mouseenter':       '&onMouseEnter'})
@NgDirective(selector: '[ng-mouseleave]',       map: const {'ng-mouseleave':       '&onMouseLeave'})
@NgDirective(selector: '[ng-mousemove]',        map: const {'ng-mousemove':        '&onMouseMove'})
@NgDirective(selector: '[ng-mouseout]',         map: const {'ng-mouseout':         '&onMouseOut'})
@NgDirective(selector: '[ng-mouseover]',        map: const {'ng-mouseover':        '&onMouseOver'})
@NgDirective(selector: '[ng-mouseup]',          map: const {'ng-mouseup':          '&onMouseUp'})
@NgDirective(selector: '[ng-mousewheel]',       map: const {'ng-mousewheel':       '&onMouseWheel'})
@NgDirective(selector: '[ng-paste]',            map: const {'ng-paste':            '&onPaste'})
@NgDirective(selector: '[ng-reset]',            map: const {'ng-reset':            '&onReset'})
@NgDirective(selector: '[ng-scroll]',           map: const {'ng-scroll':           '&onScroll'})
@NgDirective(selector: '[ng-search]',           map: const {'ng-search':           '&onSearch'})
@NgDirective(selector: '[ng-select]',           map: const {'ng-select':           '&onSelect'})
@NgDirective(selector: '[ng-selectstart]',      map: const {'ng-selectstart':      '&onSelectStart'})
//@NgDirective(selector: '[ng-speechchange]',     map: const {'ng-speechchange':     '&onSpeechChange'})
@NgDirective(selector: '[ng-submit]',           map: const {'ng-submit':           '&onSubmit'})
@NgDirective(selector: '[ng-toucheancel]',      map: const {'ng-touchcancel':      '&onTouchCancel'})
@NgDirective(selector: '[ng-touchend]',         map: const {'ng-touchend':         '&onTouchEnd'})
@NgDirective(selector: '[ng-touchenter]',       map: const {'ng-touchenter':       '&onTouchEnter'})
@NgDirective(selector: '[ng-touchleave]',       map: const {'ng-touchleave':       '&onTouchLeave'})
@NgDirective(selector: '[ng-touchmove]',        map: const {'ng-touchmove':        '&onTouchMove'})
@NgDirective(selector: '[ng-touchstart]',       map: const {'ng-touchstart':       '&onTouchStart'})
@NgDirective(selector: '[ng-transitionend]',    map: const {'ng-transitionend':    '&onTransitionEnd'})

class NgEventDirective {
  // Is it better to use a map of listeners or have 29 properties on this
  // object?  One would pretty much only assign to one or two of those
  // properties.  I'm opting for the map since it's less boilerplate code.
  var listeners = {};
  final dom.Element element;
  final Scope scope;

  NgEventDirective(this.element, this.scope);

  // NOTE: Do not use the element.on['some_event'].listen(...) syntax.  Doing so
  //     has two downsides:
  //     - it loses the event typing
  //     - some DOM events may have multiple platform-dependent event names
  //       under the covers.  The standard Stream getters you will get the
  //       platform specific event name automatically but you're on your own if
  //       you use the on[] syntax.  This also applies to $dom_addEventListener.
  //     Ref: http://api.dartlang.org/docs/releases/latest/dart_html/Events.html
  initListener(var stream, var handler) {
    int key = stream.hashCode;
    if (!listeners.containsKey(key)) {
      listeners[key] = handler;
      stream.listen((event) => scope.$apply(() {handler({r"$event": event});}));
    }
  }

  set onAbort(value)             => initListener(element.onAbort,            value);
  set onBeforeCopy(value)        => initListener(element.onBeforeCopy,       value);
  set onBeforeCut(value)         => initListener(element.onBeforeCut,        value);
  set onBeforePaste(value)       => initListener(element.onBeforePaste,      value);
  set onBlur(value)              => initListener(element.onBlur,             value);
  set onChange(value)            => initListener(element.onChange,           value);
  set onClick(value)             => initListener(element.onClick,            value);
  set onContextMenu(value)       => initListener(element.onContextMenu,      value);
  set onCopy(value)              => initListener(element.onCopy,             value);
  set onCut(value)               => initListener(element.onCut,              value);
  set onDoubleClick(value)       => initListener(element.onDoubleClick,      value);
  set onDrag(value)              => initListener(element.onDrag,             value);
  set onDragEnd(value)           => initListener(element.onDragEnd,          value);
  set onDragEnter(value)         => initListener(element.onDragEnter,        value);
  set onDragLeave(value)         => initListener(element.onDragLeave,        value);
  set onDragOver(value)          => initListener(element.onDragOver,         value);
  set onDragStart(value)         => initListener(element.onDragStart,        value);
  set onDrop(value)              => initListener(element.onDrop,             value);
  set onError(value)             => initListener(element.onError,            value);
  set onFocus(value)             => initListener(element.onFocus,            value);
  set onFullscreenChange(value)  => initListener(element.onFullscreenChange, value);
  set onFullscreenError(value)   => initListener(element.onFullscreenError,  value);
  set onInput(value)             => initListener(element.onInput,            value);
  set onInvalid(value)           => initListener(element.onInvalid,          value);
  set onKeyDown(value)           => initListener(element.onKeyDown,          value);
  set onKeyPress(value)          => initListener(element.onKeyPress,         value);
  set onKeyUp(value)             => initListener(element.onKeyUp,            value);
  set onLoad(value)              => initListener(element.onLoad,             value);
  set onMouseDown(value)         => initListener(element.onMouseDown,        value);
  set onMouseEnter(value)        => initListener(element.onMouseEnter,       value);
  set onMouseLeave(value)        => initListener(element.onMouseLeave,       value);
  set onMouseMove(value)         => initListener(element.onMouseMove,        value);
  set onMouseOut(value)          => initListener(element.onMouseOut,         value);
  set onMouseOver(value)         => initListener(element.onMouseOver,        value);
  set onMouseUp(value)           => initListener(element.onMouseUp,          value);
  set onMouseWheel(value)        => initListener(element.onMouseWheel,       value);
  set onPaste(value)             => initListener(element.onPaste,            value);
  set onReset(value)             => initListener(element.onReset,            value);
  set onScroll(value)            => initListener(element.onScroll,           value);
  set onSearch(value)            => initListener(element.onSearch,           value);
  set onSelect(value)            => initListener(element.onSelect,           value);
  set onSelectStart(value)       => initListener(element.onSelectStart,      value);
//  set onSpeechChange(value)      => initListener(element.onSpeechChange,     value);
  set onSubmit(value)            => initListener(element.onSubmit,           value);
  set onTouchCancel(value)       => initListener(element.onTouchCancel,      value);
  set onTouchEnd(value)          => initListener(element.onTouchEnd,         value);
  set onTouchEnter(value)        => initListener(element.onTouchEnter,       value);
  set onTouchLeave(value)        => initListener(element.onTouchLeave,       value);
  set onTouchMove(value)         => initListener(element.onTouchMove,        value);
  set onTouchStart(value)        => initListener(element.onTouchStart,       value);
  set onTransitionEnd(value)     => initListener(element.onTransitionEnd,    value);
}
