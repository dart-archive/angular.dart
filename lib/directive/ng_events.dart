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
  // Is it better to use a map of listeners or have 29 properties on this
  // object?  One would pretty much only assign to one or two of those
  // properties.  I'm opting for the map since it's less boilerplate code.
  var listeners = {};
  final dom.Element element;
  final Scope scope;
  final EventHandler eventHandler;

  NgEvent(this.element, this.scope, this.eventHandler);

  // NOTE: Do not use the element.on['some_event'].listen(...) syntax.  Doing so
  //     has two downsides:
  //     - it loses the event typing
  //     - some DOM events may have multiple platform-dependent event names
  //       under the covers.  The standard Stream getters you will get the
  //       platform specific event name automatically but you're on your own if
  //       you use the on[] syntax.  This also applies to $dom_addEventListener.
  //     Ref: http://api.dartlang.org/docs/releases/latest/dart_html/Events.html
  initListener(String name) {
    element.attributes['on-$name'] = element.attributes['ng-$name'];
    eventHandler.register(name);
  }

  set onAbort(value)             => initListener('abort');
  set onBeforeCopy(value)        => initListener('beforecopy');
  set onBeforeCut(value)         => initListener('beforecut');
  set onBeforePaste(value)       => initListener('beforepaste');
  set onBlur(value)              => initListener('blur');
  set onChange(value)            => initListener('change');
  set onClick(value)             => initListener('click');
  set onContextMenu(value)       => initListener('contextmenu');
  set onCopy(value)              => initListener('copy');
  set onCut(value)               => initListener('cut');
  set onDoubleClick(value)       => initListener('doubleclick');
  set onDrag(value)              => initListener('drag');
  set onDragEnd(value)           => initListener('dragend');
  set onDragEnter(value)         => initListener('dragenter');
  set onDragLeave(value)         => initListener('dragleave');
  set onDragOver(value)          => initListener('dragover');
  set onDragStart(value)         => initListener('dragstart');
  set onDrop(value)              => initListener('drop');
  set onError(value)             => initListener('error');
  set onFocus(value)             => initListener('focus');
  set onFullscreenChange(value)  => initListener('fullscreenchange');
  set onFullscreenError(value)   => initListener('fullscreenerror');
  set onInput(value)             => initListener('input');
  set onInvalid(value)           => initListener('invalid');
  set onKeyDown(value)           => initListener('keydown');
  set onKeyPress(value)          => initListener('keypress');
  set onKeyUp(value)             => initListener('keyup');
  set onLoad(value)              => initListener('load');
  set onMouseDown(value)         => initListener('mousedown');
  set onMouseEnter(value)        => initListener('mouseenter');
  set onMouseLeave(value)        => initListener('mouseleave');
  set onMouseMove(value)         => initListener('mousemove');
  set onMouseOut(value)          => initListener('mouseout');
  set onMouseOver(value)         => initListener('mouseover');
  set onMouseUp(value)           => initListener('mouseup');
  set onMouseWheel(value)        => initListener('mousewheel');
  set onPaste(value)             => initListener('paste');
  set onReset(value)             => initListener('reset');
  set onScroll(value)            => initListener('scroll');
  set onSearch(value)            => initListener('search');
  set onSelect(value)            => initListener('select');
  set onSelectStart(value)       => initListener('selectstart');
//  set onSpeechChange(value)      => initListener('speechchange');
  set onSubmit(value)            => initListener('submit');
  set onTouchCancel(value)       => initListener('touchcancel');
  set onTouchEnd(value)          => initListener('touchend');
  set onTouchEnter(value)        => initListener('touchenter');
  set onTouchLeave(value)        => initListener('touchleave');
  set onTouchMove(value)         => initListener('touchmove');
  set onTouchStart(value)        => initListener('touchstart');
  set onTransitionEnd(value)     => initListener('transitionend');
}
