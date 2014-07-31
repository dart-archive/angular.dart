/**
 * Used to create Javascript Web Components from Dart tests
 */
function angularTestsRegisterElement(name, prototype) {
  // Polymer requires that all prototypes are chained to HTMLElement
  // https://github.com/Polymer/CustomElements/issues/121
  prototype.__proto__ = HTMLElement.prototype;
  prototype.createdCallback = function() {};
  document.registerElement(name, {prototype: prototype});
}
