library angular.directive.ng_events;

import "dart:html" as dom;
import "../dom/directive.dart";
import "../parser/parser_library.dart";
import "../scope.dart";

/* All the directives in this file should look exactly the same except for the
 * name of the event itself.
 */

/**
 * The `ng-blur` directive allows you to specify custom behavior for the `Blur` event.
 *
 * Example:
 *
 *     <input ng-blur="lastEvent='Blur'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-blur]',
    map: const {'ng-blur': '&.onBlur'}
)
class NgBlurAttrDirective {
/**
   * Parsed expression from the `ng-blur` attribute.  On a `Blur`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onBlur;

  NgBlurAttrDirective(dom.Element element, Scope scope) {
    element.onBlur.listen((event) => scope.$apply(() {
      onBlur({r"$event": event});
    }));
  }
}


/**
 * The `ng-change` directive allows you to specify custom behavior for the `Change` event.
 *
 * Example:
 *
 *     <input ng-change="lastEvent='Change'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-change]',
    map: const {'ng-change': '&.onChange'}
)
class NgChangeAttrDirective {
/**
   * Parsed expression from the `ng-change` attribute.  On a `Change`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onChange;

  NgChangeAttrDirective(dom.Element element, Scope scope) {
    element.onChange.listen((event) => scope.$apply(() {
      onChange({r"$event": event});
    }));
  }
}


/**
 * The `ng-click` directive allows you to specify custom behavior for the `Click` event.
 *
 * Example:
 *
 *     <input ng-click="lastEvent='Click'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-click]',
    map: const {'ng-click': '&.onClick'}
)
class NgClickAttrDirective {
/**
   * Parsed expression from the `ng-click` attribute.  On a `Click`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onClick;

  NgClickAttrDirective(dom.Element element, Scope scope) {
    element.onClick.listen((event) => scope.$apply(() {
      onClick({r"$event": event});
    }));
  }
}


/**
 * The `ng-contextmenu` directive allows you to specify custom behavior for the `ContextMenu` event.
 *
 * Example:
 *
 *     <input ng-contextmenu="lastEvent='ContextMenu'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-contextmenu]',
    map: const {'ng-contextmenu': '&.onContextMenu'}
)
class NgContextMenuAttrDirective {
/**
   * Parsed expression from the `ng-contextmenu` attribute.  On a `ContextMenu`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onContextMenu;

  NgContextMenuAttrDirective(dom.Element element, Scope scope) {
    element.onContextMenu.listen((event) => scope.$apply(() {
      onContextMenu({r"$event": event});
    }));
  }
}


/**
 * The `ng-doubleclick` directive allows you to specify custom behavior for the `DoubleClick` event.
 *
 * Example:
 *
 *     <input ng-doubleclick="lastEvent='DoubleClick'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-doubleclick]',
    map: const {'ng-doubleclick': '&.onDoubleClick'}
)
class NgDoubleClickAttrDirective {
/**
   * Parsed expression from the `ng-doubleclick` attribute.  On a `DoubleClick`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onDoubleClick;

  NgDoubleClickAttrDirective(dom.Element element, Scope scope) {
    element.onDoubleClick.listen((event) => scope.$apply(() {
      onDoubleClick({r"$event": event});
    }));
  }
}


/**
 * The `ng-drag` directive allows you to specify custom behavior for the `Drag` event.
 *
 * Example:
 *
 *     <input ng-drag="lastEvent='Drag'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-drag]',
    map: const {'ng-drag': '&.onDrag'}
)
class NgDragAttrDirective {
/**
   * Parsed expression from the `ng-drag` attribute.  On a `Drag`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onDrag;

  NgDragAttrDirective(dom.Element element, Scope scope) {
    element.onDrag.listen((event) => scope.$apply(() {
      onDrag({r"$event": event});
    }));
  }
}


/**
 * The `ng-dragend` directive allows you to specify custom behavior for the `DragEnd` event.
 *
 * Example:
 *
 *     <input ng-dragend="lastEvent='DragEnd'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-dragend]',
    map: const {'ng-dragend': '&.onDragEnd'}
)
class NgDragEndAttrDirective {
/**
   * Parsed expression from the `ng-dragend` attribute.  On a `DragEnd`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onDragEnd;

  NgDragEndAttrDirective(dom.Element element, Scope scope) {
    element.onDragEnd.listen((event) => scope.$apply(() {
      onDragEnd({r"$event": event});
    }));
  }
}


/**
 * The `ng-dragenter` directive allows you to specify custom behavior for the `DragEnter` event.
 *
 * Example:
 *
 *     <input ng-dragenter="lastEvent='DragEnter'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-dragenter]',
    map: const {'ng-dragenter': '&.onDragEnter'}
)
class NgDragEnterAttrDirective {
/**
   * Parsed expression from the `ng-dragenter` attribute.  On a `DragEnter`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onDragEnter;

  NgDragEnterAttrDirective(dom.Element element, Scope scope) {
    element.onDragEnter.listen((event) => scope.$apply(() {
      onDragEnter({r"$event": event});
    }));
  }
}


/**
 * The `ng-dragleave` directive allows you to specify custom behavior for the `DragLeave` event.
 *
 * Example:
 *
 *     <input ng-dragleave="lastEvent='DragLeave'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-dragleave]',
    map: const {'ng-dragleave': '&.onDragLeave'}
)
class NgDragLeaveAttrDirective {
/**
   * Parsed expression from the `ng-dragleave` attribute.  On a `DragLeave`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onDragLeave;

  NgDragLeaveAttrDirective(dom.Element element, Scope scope) {
    element.onDragLeave.listen((event) => scope.$apply(() {
      onDragLeave({r"$event": event});
    }));
  }
}


/**
 * The `ng-dragover` directive allows you to specify custom behavior for the `DragOver` event.
 *
 * Example:
 *
 *     <input ng-dragover="lastEvent='DragOver'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-dragover]',
    map: const {'ng-dragover': '&.onDragOver'}
)
class NgDragOverAttrDirective {
/**
   * Parsed expression from the `ng-dragover` attribute.  On a `DragOver`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onDragOver;

  NgDragOverAttrDirective(dom.Element element, Scope scope) {
    element.onDragOver.listen((event) => scope.$apply(() {
      onDragOver({r"$event": event});
    }));
  }
}


/**
 * The `ng-dragstart` directive allows you to specify custom behavior for the `DragStart` event.
 *
 * Example:
 *
 *     <input ng-dragstart="lastEvent='DragStart'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-dragstart]',
    map: const {'ng-dragstart': '&.onDragStart'}
)
class NgDragStartAttrDirective {
/**
   * Parsed expression from the `ng-dragstart` attribute.  On a `DragStart`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onDragStart;

  NgDragStartAttrDirective(dom.Element element, Scope scope) {
    element.onDragStart.listen((event) => scope.$apply(() {
      onDragStart({r"$event": event});
    }));
  }
}


/**
 * The `ng-drop` directive allows you to specify custom behavior for the `Drop` event.
 *
 * Example:
 *
 *     <input ng-drop="lastEvent='Drop'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-drop]',
    map: const {'ng-drop': '&.onDrop'}
)
class NgDropAttrDirective {
/**
   * Parsed expression from the `ng-drop` attribute.  On a `Drop`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onDrop;

  NgDropAttrDirective(dom.Element element, Scope scope) {
    element.onDrop.listen((event) => scope.$apply(() {
      onDrop({r"$event": event});
    }));
  }
}


/**
 * The `ng-focus` directive allows you to specify custom behavior for the `Focus` event.
 *
 * Example:
 *
 *     <input ng-focus="lastEvent='Focus'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-focus]',
    map: const {'ng-focus': '&.onFocus'}
)
class NgFocusAttrDirective {
/**
   * Parsed expression from the `ng-focus` attribute.  On a `Focus`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onFocus;

  NgFocusAttrDirective(dom.Element element, Scope scope) {
    element.onFocus.listen((event) => scope.$apply(() {
      onFocus({r"$event": event});
    }));
  }
}


/**
 * The `ng-keydown` directive allows you to specify custom behavior for the `KeyDown` event.
 *
 * Example:
 *
 *     <input ng-keydown="lastEvent='KeyDown'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-keydown]',
    map: const {'ng-keydown': '&.onKeyDown'}
)
class NgKeyDownAttrDirective {
/**
   * Parsed expression from the `ng-keydown` attribute.  On a `KeyDown`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onKeyDown;

  NgKeyDownAttrDirective(dom.Element element, Scope scope) {
    element.onKeyDown.listen((event) => scope.$apply(() {
      onKeyDown({r"$event": event});
    }));
  }
}


/**
 * The `ng-keypress` directive allows you to specify custom behavior for the `KeyPress` event.
 *
 * Example:
 *
 *     <input ng-keypress="lastEvent='KeyPress'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-keypress]',
    map: const {'ng-keypress': '&.onKeyPress'}
)
class NgKeyPressAttrDirective {
/**
   * Parsed expression from the `ng-keypress` attribute.  On a `KeyPress`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onKeyPress;

  NgKeyPressAttrDirective(dom.Element element, Scope scope) {
    element.onKeyPress.listen((event) => scope.$apply(() {
      onKeyPress({r"$event": event});
    }));
  }
}


/**
 * The `ng-keyup` directive allows you to specify custom behavior for the `KeyUp` event.
 *
 * Example:
 *
 *     <input ng-keyup="lastEvent='KeyUp'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-keyup]',
    map: const {'ng-keyup': '&.onKeyUp'}
)
class NgKeyUpAttrDirective {
/**
   * Parsed expression from the `ng-keyup` attribute.  On a `KeyUp`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onKeyUp;

  NgKeyUpAttrDirective(dom.Element element, Scope scope) {
    element.onKeyUp.listen((event) => scope.$apply(() {
      onKeyUp({r"$event": event});
    }));
  }
}


/**
 * The `ng-mousedown` directive allows you to specify custom behavior for the `MouseDown` event.
 *
 * Example:
 *
 *     <input ng-mousedown="lastEvent='MouseDown'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-mousedown]',
    map: const {'ng-mousedown': '&.onMouseDown'}
)
class NgMouseDownAttrDirective {
/**
   * Parsed expression from the `ng-mousedown` attribute.  On a `MouseDown`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onMouseDown;

  NgMouseDownAttrDirective(dom.Element element, Scope scope) {
    element.onMouseDown.listen((event) => scope.$apply(() {
      onMouseDown({r"$event": event});
    }));
  }
}


/**
 * The `ng-mouseenter` directive allows you to specify custom behavior for the `MouseEnter` event.
 *
 * Example:
 *
 *     <input ng-mouseenter="lastEvent='MouseEnter'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-mouseenter]',
    map: const {'ng-mouseenter': '&.onMouseEnter'}
)
class NgMouseEnterAttrDirective {
/**
   * Parsed expression from the `ng-mouseenter` attribute.  On a `MouseEnter`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onMouseEnter;

  NgMouseEnterAttrDirective(dom.Element element, Scope scope) {
    element.onMouseEnter.listen((event) => scope.$apply(() {
      onMouseEnter({r"$event": event});
    }));
  }
}


/**
 * The `ng-mouseleave` directive allows you to specify custom behavior for the `MouseLeave` event.
 *
 * Example:
 *
 *     <input ng-mouseleave="lastEvent='MouseLeave'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-mouseleave]',
    map: const {'ng-mouseleave': '&.onMouseLeave'}
)
class NgMouseLeaveAttrDirective {
/**
   * Parsed expression from the `ng-mouseleave` attribute.  On a `MouseLeave`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onMouseLeave;

  NgMouseLeaveAttrDirective(dom.Element element, Scope scope) {
    element.onMouseLeave.listen((event) => scope.$apply(() {
      onMouseLeave({r"$event": event});
    }));
  }
}


/**
 * The `ng-mousemove` directive allows you to specify custom behavior for the `MouseMove` event.
 *
 * Example:
 *
 *     <input ng-mousemove="lastEvent='MouseMove'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-mousemove]',
    map: const {'ng-mousemove': '&.onMouseMove'}
)
class NgMouseMoveAttrDirective {
/**
   * Parsed expression from the `ng-mousemove` attribute.  On a `MouseMove`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onMouseMove;

  NgMouseMoveAttrDirective(dom.Element element, Scope scope) {
    element.onMouseMove.listen((event) => scope.$apply(() {
      onMouseMove({r"$event": event});
    }));
  }
}


/**
 * The `ng-mouseout` directive allows you to specify custom behavior for the `MouseOut` event.
 *
 * Example:
 *
 *     <input ng-mouseout="lastEvent='MouseOut'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-mouseout]',
    map: const {'ng-mouseout': '&.onMouseOut'}
)
class NgMouseOutAttrDirective {
/**
   * Parsed expression from the `ng-mouseout` attribute.  On a `MouseOut`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onMouseOut;

  NgMouseOutAttrDirective(dom.Element element, Scope scope) {
    element.onMouseOut.listen((event) => scope.$apply(() {
      onMouseOut({r"$event": event});
    }));
  }
}


/**
 * The `ng-mouseover` directive allows you to specify custom behavior for the `MouseOver` event.
 *
 * Example:
 *
 *     <input ng-mouseover="lastEvent='MouseOver'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-mouseover]',
    map: const {'ng-mouseover': '&.onMouseOver'}
)
class NgMouseOverAttrDirective {
/**
   * Parsed expression from the `ng-mouseover` attribute.  On a `MouseOver`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onMouseOver;

  NgMouseOverAttrDirective(dom.Element element, Scope scope) {
    element.onMouseOver.listen((event) => scope.$apply(() {
      onMouseOver({r"$event": event});
    }));
  }
}


/**
 * The `ng-mouseup` directive allows you to specify custom behavior for the `MouseUp` event.
 *
 * Example:
 *
 *     <input ng-mouseup="lastEvent='MouseUp'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-mouseup]',
    map: const {'ng-mouseup': '&.onMouseUp'}
)
class NgMouseUpAttrDirective {
/**
   * Parsed expression from the `ng-mouseup` attribute.  On a `MouseUp`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onMouseUp;

  NgMouseUpAttrDirective(dom.Element element, Scope scope) {
    element.onMouseUp.listen((event) => scope.$apply(() {
      onMouseUp({r"$event": event});
    }));
  }
}


/**
 * The `ng-mousewheel` directive allows you to specify custom behavior for the `MouseWheel` event.
 *
 * Example:
 *
 *     <input ng-mousewheel="lastEvent='MouseWheel'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-mousewheel]',
    map: const {'ng-mousewheel': '&.onMouseWheel'}
)
class NgMouseWheelAttrDirective {
/**
   * Parsed expression from the `ng-mousewheel` attribute.  On a `MouseWheel`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onMouseWheel;

  NgMouseWheelAttrDirective(dom.Element element, Scope scope) {
    element.onMouseWheel.listen((event) => scope.$apply(() {
      onMouseWheel({r"$event": event});
    }));
  }
}


/**
 * The `ng-scroll` directive allows you to specify custom behavior for the `Scroll` event.
 *
 * Example:
 *
 *     <input ng-scroll="lastEvent='Scroll'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-scroll]',
    map: const {'ng-scroll': '&.onScroll'}
)
class NgScrollAttrDirective {
/**
   * Parsed expression from the `ng-scroll` attribute.  On a `Scroll`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onScroll;

  NgScrollAttrDirective(dom.Element element, Scope scope) {
    element.onScroll.listen((event) => scope.$apply(() {
      onScroll({r"$event": event});
    }));
  }
}


/**
 * The `ng-touchcancel` directive allows you to specify custom behavior for the `TouchCancel` event.
 *
 * Example:
 *
 *     <input ng-touchcancel="lastEvent='TouchCancel'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-touchcancel]',
    map: const {'ng-touchcancel': '&.onTouchCancel'}
)
class NgTouchCancelAttrDirective {
/**
   * Parsed expression from the `ng-touchcancel` attribute.  On a `TouchCancel`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onTouchCancel;

  NgTouchCancelAttrDirective(dom.Element element, Scope scope) {
    element.onTouchCancel.listen((event) => scope.$apply(() {
      onTouchCancel({r"$event": event});
    }));
  }
}


/**
 * The `ng-touchend` directive allows you to specify custom behavior for the `TouchEnd` event.
 *
 * Example:
 *
 *     <input ng-touchend="lastEvent='TouchEnd'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-touchend]',
    map: const {'ng-touchend': '&.onTouchEnd'}
)
class NgTouchEndAttrDirective {
/**
   * Parsed expression from the `ng-touchend` attribute.  On a `TouchEnd`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onTouchEnd;

  NgTouchEndAttrDirective(dom.Element element, Scope scope) {
    element.onTouchEnd.listen((event) => scope.$apply(() {
      onTouchEnd({r"$event": event});
    }));
  }
}


/**
 * The `ng-touchmove` directive allows you to specify custom behavior for the `TouchMove` event.
 *
 * Example:
 *
 *     <input ng-touchmove="lastEvent='TouchMove'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-touchmove]',
    map: const {'ng-touchmove': '&.onTouchMove'}
)
class NgTouchMoveAttrDirective {
/**
   * Parsed expression from the `ng-touchmove` attribute.  On a `TouchMove`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onTouchMove;

  NgTouchMoveAttrDirective(dom.Element element, Scope scope) {
    element.onTouchMove.listen((event) => scope.$apply(() {
      onTouchMove({r"$event": event});
    }));
  }
}


/**
 * The `ng-touchstart` directive allows you to specify custom behavior for the `TouchStart` event.
 *
 * Example:
 *
 *     <input ng-touchstart="lastEvent='TouchStart'" type="text"></input>
 */
@NgDirective(
    selector: '[ng-touchstart]',
    map: const {'ng-touchstart': '&.onTouchStart'}
)
class NgTouchStartAttrDirective {
/**
   * Parsed expression from the `ng-touchstart` attribute.  On a `TouchStart`
   * event, this gets invoked with the event available as `$event` in it's
   * local scope.
   */
  Getter onTouchStart;

  NgTouchStartAttrDirective(dom.Element element, Scope scope) {
    element.onTouchStart.listen((event) => scope.$apply(() {
      onTouchStart({r"$event": event});
    }));
  }
}
