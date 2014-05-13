part of angular.directive;

@Decorator(
    selector: '[ng-base-css]',
    bind: const {'ngBaseCss': 'urls'}
)
class NgBaseCss {
  List<String> _urls = const [];

  set urls(v) => _urls = v is List ? v : [v];

  List<String> get urls => _urls;
}
