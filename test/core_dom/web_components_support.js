/**
 * Registers Javascript Web Components from Dart tests.
 *
 * Per HTML5 spec, the prototype object should inherit from `HTMLELement`.
 * see http://w3c.github.io/webcomponents/spec/custom/#extensions-to-document-interface-to-register
 *
 * Note: __proto__ can not be used as it is not supported in IE10.
 */
function angularTestsRegisterElement(name, prototype) {
  var proto = Object.create(HTMLElement.prototype);
  for (var p in prototype) {
    if (prototype.hasOwnProperty(p)) {
      proto[p] = prototype[p];
    }
  }
  proto.createdCallback = function() {};
  document.registerElement(name, {prototype: proto});
}
