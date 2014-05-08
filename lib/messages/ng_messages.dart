part of angular.messages;

/**
 * The NgMessages directive is designed to show and hide form messages and allow previously
 * defined message template code to be reused and overridden.
 * 
 * Please note that the ngMessages and ngMessage directives exist within the [MessagesModule]
 * module. Therefore the MessagesModule must be included into the application for the directives
 * to become available for use.
 * 
 * Upon compile, NgMessages renders inner [NgMessage] messages based on the state of the
 * given key/value map. If the value property within the provided map is a truthy value
 * then the first inner element containing a [NgMessage] directive that matches the key
 * of that truthy value will be inserted into the DOM. By default, only one NgMessages
 * element (the first detected instance) will be displayed at a time, however, this behavior
 * can be overridden by providing the ng-messages-multiple attribute on the element
 * (with a truthy value).
 * 
 * Messages that have a [NgMessage] directive are to be defined as children within
 * the element containing the NgMessages directive. In order to reuse inner messages, an
 * external template can be assigned by via the ng-messages-template attribute. When
 * an external template is used, then any child NgMessage elements will override
 * any existing NgMessage directives that are defined in the external template.
 * This mechanism is useful for creating data-specific messages and/or for reusing
 * a general collection of messages for multiple pieces of instances of NgMessages.
 * (A common usecase is for displaying form error messages.)
 *
 * For each of the inner [NgMessage] instances, a new child [Scope] is created.
 *
 * If the provided map is empty, or there are no inner messages that match any of the key
 * values in the map, then the `.ng-inactive` CSS class will be placed on the element containing
 * the NgMessages directive. Otherwise the `.ng-active` CSS class will be placed on the element.
 *
 * Note: both the `.ng-active` and `.ng-active` CSS classes are valid hooks for animations.
 *
 * Note: If a remote template on [NgMessages] is used (via ng-messages-template),
 * then the browser's Same Origin Policy (<http://v.gd/5LE5CA>) and
 * Cross-Origin Resource Sharing (CORS) policy (<http://v.gd/nXoY8y>) restrict
 * whether the template is successfully loaded.  For example,
 * [NgMessages] (when used with a template) won't work for cross-domain requests
 * on all browsers and * for `file://` access on some browsers.
 */
@Decorator(
    selector:'[ng-messages]',
    map: const {
      'ng-messages': '=>value',
      'ng-messages-include': '@template',
      'ng-messages-multiple': '=>multiple'},
    exportExpressions: const ['self'])
class NgMessages {
  static const NG_ACTIVE    = 'ng-active';
  static const NG_INACTIVE  = 'ng-inactive';

  final _messages = <NgMessage>[];
  final _loadingQueue = <NgMessage>[];

  final Scope _scope;
  final NgElement _element;
  final ViewCache _viewCache;
  final Injector _injector;
  final DirectiveMap _directives;

  bool _multiple = false;
  bool _loading = false;

  Map _lastChanges = new Map();
  Watch _watch;

  NgMessages(this._scope, this._element, this._viewCache, this._injector, this._directives);

  void set value(map) {
    if (_watch != null) {
      _watch.remove();
      _watch = null;
    }
    if (map != null) {
      _watch = _scope.watch(
          'self',
          (changes, _) => _update(_lastChanges = changes.map),
          context: {'self': map},
          collection: true);
    } else {
      _update(_lastChanges = {});
    }
  }

  bool get multiple => _multiple;
  void set multiple(value) {
    _multiple = (value is num)
      ? value != 0
      : value == true;
  }

  void set template(url) {
    if (url == null) return;

    _loading = true;
    _viewCache.fromUrl(url, _directives).then((viewFn) {
      _loading = false;

      View view = viewFn(_injector.createChild([
        new Module()..value(Scope, _scope)
      ]));
      view.nodes.forEach((node) => _element.node.append(node));

      _loadingQueue..forEach(register)..clear();

      _update(_lastChanges);
    });
  }

  void _update(Map values) {
    // TODO(matsko): refactor to use something Dart-native?
    truthy(value) => value != null && value != false;

    bool found = false;
    _messages.forEach((message) {
      String type = message.type;
      if ((!found || _multiple) && truthy(values[type])) {
        message.attach(_scope, values[type]);
        found = true;
      } else {
        message.detach();
      }
    });

    if (found) {
      _element..addClass(NG_ACTIVE)..removeClass(NG_INACTIVE);
    } else {
      _element..addClass(NG_INACTIVE)..removeClass(NG_ACTIVE);
    }
  }

  /**
    * Registers the provided instance of [NgMessage] with the internal list of messages.
    */
  void register(NgMessage message) {
    if (_loading) {
      _loadingQueue.add(message);
    } else {
      String type = message.type;
      for(int i = 0; i < _messages.length; i++) {
        if (_messages[i].type == type) {
          _messages[i].detach();
          _messages[i] = message;
          return;
        }
      }
      _messages.add(message);
    }
  }
}


/**
 * [NgMessage] is managed by [NgMessages]. The element attached to the directive
 * is designed to be placed inside of the element containing the NgMessages directive.
 * NgMessages will automatically determine which instances of NgMessage will be displayed
 * depending on the order they appear within the HTML code. If a NgMessage element with
 * a type value (the value acquired from the ng-message attribute) which is already
 * present among other NgMessage directives defined in the same container then the latter
 * directive will override the former one. This is useful for defining a more specific message
 * to override a general one depending on what data is being tracked for the messaging.
 *
 * See [NgMessages] to learn how the directive interacts with NgMessages.
 */
@Decorator(
    children: Directive.TRANSCLUDE_CHILDREN,
    selector: '[ng-message]',
    map: const {'.': '@type'})
class NgMessage {
  final Scope _scope;
  final NgMessages _messages;
  final BoundViewFactory _boundViewFactory;
  final ViewPort _viewPort;
   
  Scope _childScope;
  String _type;
  View _view;

  NgMessage(this._scope, this._boundViewFactory, this._viewPort, this._messages);

  String get type => _type;
  void set type(value) {
    _type = value;
    _messages.register(this);
  }

  /**
    * Inserts the element attached to the directive into the DOM and creates a new scope.
    * Depending on the key value for NgMessage, (whatever value was set for the
    * ng-message attribute) that value will be represented as `$control` within the newly
    * created scope.
    */
  void attach(Scope parentScope, dynamic value) {
    if (_view == null) {
      _childScope = _scope.createChild(new PrototypeMap(parentScope.context));

      //The control/model is aliased as $control for convenience. Since FormControl collects
      //child controls as a set then the value will be referenced as the first control in the set.
      _childScope.context[r'$control'] = value is Set ? value.elementAt(0) : value;

      var view = _view = _boundViewFactory(_childScope);
      _scope.rootScope.domWrite(() {
        _viewPort.insert(view);
     });
    }
  }

  /**
    * Removes the element, which is attached to the directive, away from the DOM. It
    * also destroys the scope which is bound to the element.
    */
  void detach() {
    if (_view != null) {
      var view = _view;
      _scope.rootScope.domWrite(() {
        _viewPort.remove(view);
      });
      _childScope.destroy();
      _view = null;
      _childScope = null;
    }
  }
}
