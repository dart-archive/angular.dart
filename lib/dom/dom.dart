library dom;

import 'dart:html';
import 'dart:async';
import 'package:angular/tracing.dart';

export 'dart:html';


final _Dom = traceCreateScope('Dom(ascii operation)');

Future<num> animationFrame(Window w) {
  final s = traceEnter1(_Dom, "animationFrame");
  final r = w.animationFrame;
  traceLeave(s);
  return r;
}

Node parentNode(Node n) {
  final s = traceEnter1(_Dom, "parentNode");
  final r = n.parentNode;
  traceLeave(s);
  return r;
}



CssStyleDeclaration getComputedStyle(Element e) {
  final s = traceEnter1(_Dom, "getComputedStyle");
  final r = e.getComputedStyle();
  traceLeave(s);
  return r;
}

CssStyleDeclaration style(Element e) {
  final s = traceEnter1(_Dom, "style");
  final r = e.style;
  traceLeave(s);
  return r;
}

void setCssProperty(CssStyleDeclaration e, String key, String value) {
  final s = traceEnter1(_Dom, "setCssProperty");
  e.setProperty(key, value);
  traceLeave(s);
}



void addClass(Element e, String className) {
  final s = traceEnter1(_Dom, "addClass");
  e.classes.add(className);
  traceLeave(s);
}

void removeClass(Element e, String className) {
  final s = traceEnter1(_Dom, "removeClass");
  e.classes.remove(className);
  traceLeave(s);
}

CssClassSet classes(Element e) {
  final s = traceEnter1(_Dom, "classes");
  final r = e.classes;
  traceLeave(s);
  return r;
}



void removeNode(Node n) {
  final s = traceEnter1(_Dom, "removeNode");
  n.remove();
  traceLeave(s);
}

void append(Node n, Node nodeToAppend) {
  final s = traceEnter1(_Dom, "append");
  n.append(nodeToAppend);
  traceLeave(s);
}

void appendText(Element e, String text) {
  final s = traceEnter1(_Dom, "appendText");
  e.appendText(text);
  traceLeave(s);
}



String text(Node n) {
  final s = traceEnter1(_Dom, "text");
  final r = n.text;
  traceLeave(s);
  return r;
}

void setText(Node n, String text) {
  final s = traceEnter1(_Dom, "setText");
  n.text = text;
  traceLeave(s);
}

String innerHtml(elementOrShadowRoot) {
  assert(elementOrShadowRoot is Element || elementOrShadowRoot is DocumentFragment);
  final s = traceEnter1(_Dom, "innerHtml");
  final r = elementOrShadowRoot.innerHtml;
  traceLeave(s);
  return r;
}

void setInnerHtml(Element e, String html, {NodeValidator validator}) {
  final s = traceEnter1(_Dom, "setInnerHtml");
  e.setInnerHtml(html, validator: validator);
  traceLeave(s);
}

void insertBefore(Node n, Node nodeToInsert, Node insertBefore) {
  final s = traceEnter1(_Dom, "insertBefore");
  n.insertBefore(nodeToInsert, insertBefore);
  traceLeave(s);
}

void insertAllBefore(Node n, List<Node> nodesToInsert, Node insertBefore){
  final s = traceEnter1(_Dom, "insertAllBefore");
  n.insertAllBefore(nodesToInsert, insertBefore);
  traceLeave(s);
}

List<Node> nodes(Element e) {
  final s = traceEnter1(_Dom, "nodes");
  final r = e.nodes;
  traceLeave(s);
  return r;
}

void setNodes(Element e, List<Node> nodes) {
  final s = traceEnter1(_Dom, "setNodes");
  e.nodes = nodes;
  traceLeave(s);
}




Map attributes(Element e) {
  final s = traceEnter1(_Dom, "attributes");
  final r = e.attributes;
  traceLeave(s);
  return r;
}

String getAttribute(Element e, String name) {
  final s = traceEnter1(_Dom, "getAttribute");
  final r = e.getAttribute(name);
  traceLeave(s);
  return r;
}

void removeAttribute(Element e, String name) {
  final s = traceEnter1(_Dom, "removeAttribute");
  e.attributes.remove(name);
  traceLeave(s);
}

void setAttribute(Element e, String name, value) {
  final s = traceEnter1(_Dom, "setAttribute");
  e.setAttribute(name, value);
  traceLeave(s);
}


bool isChecked(input) {
  assert(input is CheckboxInputElement || input is OptionElement);
  final s = traceEnter1(_Dom, "isChecked");
  final r = input.checked;
  traceLeave(s);
  return r;
}

void setChecked(input, bool value) {
  assert(input is CheckboxInputElement || input is OptionElement);
  final s = traceEnter1(_Dom, "setChecked");
  input.checked = value;
  traceLeave(s);
}

String value(input) {
  assert(input is InputElement || input is OptionElement);
  final s = traceEnter1(_Dom, "value");
  final r = input.value;
  traceLeave(s);
  return r;
}

void setValue(input, String value) {
  assert(input is InputElement || input is OptionElement);
  final s = traceEnter1(_Dom, "setValue");
  input.value = value;
  traceLeave(s);
}

num valueAsNumber(InputElement e) {
  final s = traceEnter1(_Dom, "valueAsNumber");
  final r = e.valueAsNumber;
  traceLeave(s);
  return r;
}

void setValueAsNumber(InputElement e, num value) {
  final s = traceEnter1(_Dom, "setValueAsNumber");
  e.valueAsNumber = value;
  traceLeave(s);
}

DateTime valueAsDate(InputElement e) {
  final s = traceEnter1(_Dom, "valueAsDate");
  final r = e.valueAsDate;
  traceLeave(s);
  return r;
}

void setValueAsDate(InputElement e, DateTime value) {
  final s = traceEnter1(_Dom, "setValueAsDate");
  e.valueAsDate = value;
  traceLeave(s);
}

void setSelected(OptionElement e, obj) {
  final s = traceEnter1(_Dom, "setSelected");
  e.selected = obj;
  traceLeave(s);
}



Node firstChild(Node n) {
  final s = traceEnter1(_Dom, "firstChild");
  final r = n.firstChild;
  traceLeave(s);
  return r;
}

DocumentFragment content(TemplateElement e) {
  final s = traceEnter1(_Dom, "content");
  final r = e.content;
  traceLeave(s);
  return r;
}

String outerHtml(Element e) {
  final s = traceEnter1(_Dom, "outerHtml");
  final r = e.outerHtml;
  traceLeave(s);
  return r;
}

Node nextNode(Node n) {
  final s = traceEnter1(_Dom, "nextNode");
  final r = n.nextNode;
  traceLeave(s);
  return r;
}

List querySelectorAll(Element e, String selectors) {
  final s = traceEnter1(_Dom, "querySelectorAll");
  final r = e.querySelectorAll(selectors);
  traceLeave(s);
  return r;
}

Node querySelector(Element e, String selectors) {
  final s = traceEnter1(_Dom, "querySelector");
  final r = e.querySelector(selectors);
  traceLeave(s);
  return r;
}


ShadowRoot createShadowRoot(Element e) {
  final s = traceEnter1(_Dom, "createShadowRoot");
  final r = e.createShadowRoot();
  traceLeave(s);
  return r;
}

Node clone(Node n, [bool deep = true]) {
  final s = traceEnter1(_Dom, "clone");
  final r = n.clone(deep);
  traceLeave(s);
  return r;
}
