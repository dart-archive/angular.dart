part of angular;

cloneElements(elements) {
  var clones = [];
  for(var i = 0, ii = elements.length; i < ii; i++) {
    clones.add(elements[i].clone(true));
  }
  return clones;
}
