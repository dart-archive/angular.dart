part of angular.core.dom;

@NgInjectableService()
class NgElement {

  final dom.Element node;
  final Scope _scope;
  final NgAnimate _animate;
  final _classes = new Map<String, bool>();

  NgElement(this.node, this._scope, NgAnimate this._animate);

  addClass(String className) {
    if(_classes.isEmpty) {
      _listenOnWrite();
    }
    _classes[className] = true;
  }

  removeClass(String className) {
    if(_classes.isEmpty) {
      _listenOnWrite();
    }
    _classes[className] = false;
  }

  _listenOnWrite() {
    _scope.rootScope.domWrite(() => flush());
  }

  flush() {
    _classes.forEach((className, status) {
      status == true
        ? _animate.addClass(node, className)
        : _animate.removeClass(node, className);
    });
    _classes.clear();
  }
}
