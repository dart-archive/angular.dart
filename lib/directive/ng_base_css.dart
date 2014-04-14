part of angular.directive;

@Decorator(
    selector: '[ng-base-css]',
    visibility: Directive.CHILDREN_VISIBILITY
)
class NgBaseCss {
  List<String> _urls = const [];

  @NgAttr('ng-base-css')
  set urls(v) => _urls = v is List ? v : [v];

  List<String> get urls => _urls;
}
