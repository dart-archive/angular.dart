part of angular;

@NgDirective(
  selector: '[ng-bind]',
  map: const {'.': '=.value'})
class NgBindAttrDirective {
  dom.Element element;

  NgBindAttrDirective(dom.Element this.element);

  set value(value) => element.text = value == null ? '' : value.toString();
}
