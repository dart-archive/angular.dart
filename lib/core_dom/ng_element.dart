part of angular.core.dom_internal;

/**
 * An [NgElement] wraps a DOM element. It can be used by a component to
 * modify the element's classes and attributes.
 *
 * Example:
 *
 *    class ElementAwareComponent {
 *      NgElement ngElement;
 *      ElementAwareComponent(this.ngElement);
 *
 *      void onClick() {
 *        ngElement.addClass("clicked");
 *      }
 *    }
 *
 * These modifications are asynchronous and will update the DOM only
 * during the next flush phase.
 */
@Injectable()
class NgElement {
  static const _TO_BE_REMOVED = const Object();

  final dom.Element node;
  final RootScope _rootScope;
  final Animate _animate;
  final DestinationLightDom _lightDom;

  final _classesToUpdate = new HashMap<String, bool>();
  final _attributesToUpdate = new HashMap<String, dynamic>();

  bool _writeScheduled = false;

  NgElement(this.node, this._rootScope, this._animate, [this._lightDom]);

  /// Schedules a DOM write adding [className] to the element.
  void addClass(String className) {
    _scheduleDomWrite();
    _classesToUpdate[className] = true;
  }

  /// Schedules a DOM write removing [className] from the element.
  void removeClass(String className) {
    _scheduleDomWrite();
    _classesToUpdate[className] = false;
  }

  /// Schedules a DOM write updating [attrName] to [value].
  void setAttribute(String attrName, [value = '']) {
    _scheduleDomWrite();
    _attributesToUpdate[attrName] = value == null ? '' : value;
  }

  /// Schedules a DOM write removing [attrName] from the element.
  void removeAttribute(String attrName) {
    _scheduleDomWrite();
    _attributesToUpdate[attrName] = _TO_BE_REMOVED;
  }

  /// Schedules a DOM write for the next flush phase
  _scheduleDomWrite() {
    if (!_writeScheduled) {
      _writeScheduled = true;
      _rootScope.domWrite(() {
        _writeToDom();
        _notifyLightDom();
        _writeScheduled = false;
      });
    }
  }

  /// Executes scheduled DOM update - this should be called from the flush phase
  _writeToDom() {
    _classesToUpdate.forEach((String className, bool toBeAdded) {
      toBeAdded
        ? _animate.addClass(node, className)
        : _animate.removeClass(node, className);
    });
    _classesToUpdate.clear();

    _attributesToUpdate.forEach((String attrName, value) {
      if (value == _TO_BE_REMOVED) {
        node.attributes.remove(attrName);
      } else {
        node.attributes[attrName] = value;
      }
    });
    _attributesToUpdate.clear();
  }

  void _notifyLightDom() {
    if (_lightDom != null) _lightDom.redistribute();
  }
}
