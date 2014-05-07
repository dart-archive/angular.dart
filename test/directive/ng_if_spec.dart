library ng_if_spec;

import '../_specs.dart';

@Decorator(
    selector: '[child-controller]',
    children: Directive.TRANSCLUDE_CHILDREN)
class ChildController {
  ChildController(BoundViewFactory boundViewFactory,
                  ViewPort viewPort,
                  Scope scope) {
    scope.context['setBy'] = 'childController';
    viewPort.insert(boundViewFactory(scope));
  }
}

main() {
  var compile, html, element, rootScope, logger, directives;

  void configInjector(Module module) {
    module..bind(ChildController)
          ..bind(LogAttrDirective);
  }

  void configState(Scope scope, Compiler compiler, Injector injector,
                   Logger _logger, DirectiveMap _directives) {
    rootScope = scope;
    logger = _logger;
    compile = (html, [applyFn]) {
      element = e(html);
      compiler([element], _directives)(injector, [element]);
      scope.apply(applyFn);
    };
    directives = _directives;
  }

  they(should, htmlForElements, callback, [exclusive=false]) {
    htmlForElements.forEach((html) {
      var directiveName = html.contains('ng-if') ? 'ng-if' : 'ng-unless';
      describe(directiveName, () {
        beforeEachModule(configInjector);
        beforeEach(configState);
        (exclusive ? iit : it)(should, () {
          callback(html);
        });
      });
    });
  }

  they('should add/remove the element',
    [ '<div><span ng-if="isVisible">content</span></div>',
      '<div><span ng-unless="!isVisible">content</span></div>'],
    (html) {
      compile(html);
      // The span node should NOT exist in the DOM.
      expect(element.querySelectorAll('span').length).toEqual(0);

      rootScope.apply(() {
        rootScope.context['isVisible'] = true;
      });

      // The span node SHOULD exist in the DOM.
      expect(element.querySelector('span')).toHaveHtml('content');

      rootScope.apply(() {
        rootScope.context['isVisible'] = false;
      });

      expect(element.querySelectorAll('span').length).toEqual(0);
    }
  );

  they('should create a child scope',
    [
      // ng-if
      '<div>' +
      '  <div ng-if="isVisible">'.trim() +
      '    <span child-controller id="inside">inside {{setBy}};</span>'.trim() +
      '  </div>'.trim() +
      '  <span id="outside">outside {{setBy}}</span>'.trim() +
      '</div>',
      // ng-unless
      '<div>' +
      '  <div ng-unless="!isVisible">'.trim() +
      '    <span child-controller id="inside">inside {{setBy}};</span>'.trim() +
      '  </div>'.trim() +
      '  <span id="outside">outside {{setBy}}</span>'.trim() +
      '</div>'],
    (html) {
      rootScope.context['setBy'] = 'topLevel';
      compile(html);
      expect(element).toHaveText('outside topLevel');

      rootScope.apply(() {
        rootScope.context['isVisible'] = true;
      });
      expect(element).toHaveText('inside childController;outside topLevel');
      // The value on the parent scope.context['should'] be unchanged.
      expect(rootScope.context['setBy']).toEqual('topLevel');
      expect(element.querySelector('#outside')).toHaveHtml('outside topLevel');
      // A child scope.context['must'] have been created and hold a different value.
      expect(element.querySelector('#inside')).toHaveHtml('inside childController;');
    }
  );

  they('should play nice with other elements beside it',
    [
      // ng-if
      '<div>' +
      '  <div ng-repeat="i in values">repeat;</div>'.trim() +
      '  <div ng-if="values.length==4">if;</div>'.trim() +
      '  <div ng-repeat="i in values">repeat2;</div>'.trim() +
      '</div>',
      // ng-unless
      '<div>' +
      '  <div ng-repeat="i in values">repeat;</div>'.trim() +
      '  <div ng-unless="values.length!=4">if;</div>'.trim() +
      '  <div ng-repeat="i in values">repeat2;</div>'.trim() +
      '</div>'],
    (html) {
      var values = rootScope.context['values'] = [1, 2, 3, 4];
      compile(html);
      expect(element).toHaveText('repeat;repeat;repeat;repeat;if;repeat2;repeat2;repeat2;repeat2;');
      rootScope.apply(() {
        values.removeRange(0, 1);
      });
      expect(element).toHaveText('repeat;repeat;repeat;repeat2;repeat2;repeat2;');
      rootScope.apply(() {
        values.insert(0, 1);
      });
      expect(element).toHaveText('repeat;repeat;repeat;repeat;if;repeat2;repeat2;repeat2;repeat2;');
    }
  );

  they('should restore the element to its compiled state',
    [
      '<div><span class="my-class" ng-if="isVisible">content</span></div>',
      '<div><span class="my-class" ng-unless="!isVisible">content</span></div>'],
    (html) {
      rootScope.context['isVisible'] = true;
      compile(html);
      expect(element).toHaveText('content');
      element.querySelector('span').classes.remove('my-class');
      expect(element.querySelector('span')).not.toHaveClass('my-class');
      rootScope.apply(() {
        rootScope.context['isVisible'] = false;
      });
      expect(element).toHaveText('');
      rootScope.apply(() {
        rootScope.context['isVisible'] = true;
      });
      // The newly inserted node should be a copy of the compiled state.
      expect(element.querySelector('span')).toHaveClass('my-class');
    }
  );

  they('should not cause ng-click to throw an exception',
    [
      '<div><span ng-click="click" ng-if="isVisible">content</span></div>',
      '<div><span ng-click="click" ng-unless="!isVisible">content</span></div>'],
    (html) {
      compile(html);
      rootScope.apply(() {
        rootScope.context['isVisible'] = false;
      });
      expect(element.querySelectorAll('span').length).toEqual(0);
    }
  );

  they('should prevent other directives from running when disabled',
    [
      '<div><li log="ALWAYS"></li><span log="JAMES" ng-if="isVisible">content</span></div>',
      '<div><li log="ALWAYS"></li><span log="JAMES" ng-unless="!isVisible">content</span></div>'],
    (html) {
      compile(html);
      expect(element.querySelectorAll('span').length).toEqual(0);

      rootScope.apply(() {
        rootScope.context['isVisible'] = false;
      });
      expect(element.querySelectorAll('span').length).toEqual(0);
      expect(logger.result()).toEqual('ALWAYS');


      rootScope.apply(() {
        rootScope.context['isVisible'] = true;
      });
      expect(element.querySelector('span')).toHaveHtml('content');
      expect(logger.result()).toEqual('ALWAYS; JAMES');
    }
  );

  they('should prevent other directives from running when disabled',
  [
    '<div><div ng-if="a"><div ng-if="b">content</div></div></div>',
    '<div><div ng-unless="!a"><div ng-unless="!b">content</div></div></div>'],
    (html) {
      compile(html);
      expect(element.querySelectorAll('span').length).toEqual(0);

      expect(() {
        rootScope.apply(() {
          rootScope.context['a'] = true;
          rootScope.context['b'] = false;
        });
      }).not.toThrow();
      expect(element.querySelectorAll('span').length).toEqual(0);


      expect(() {
        rootScope.apply(() {
          rootScope.context['a'] = false;
          rootScope.context['b'] = true;
        });
      }).not.toThrow();
      expect(element.querySelectorAll('span').length).toEqual(0);
    }
  );
}
