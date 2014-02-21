library ng_if_spec;

import '../_specs.dart';

@NgDirective(
    selector: '[child-controller]',
    children: NgAnnotation.TRANSCLUDE_CHILDREN)
class ChildController {
  ChildController(BoundBlockFactory boundBlockFactory,
                  BlockHole blockHole,
                  Scope scope) {
    scope.context['setBy'] = 'childController';
    boundBlockFactory(scope).insertAfter(blockHole);
  }
}

main() {
  var compile, html, element, rootScope, logger, directives;

  void configInjector() {
    module((Module module) {
        module
          ..type(ChildController)
          ..type(LogAttrDirective);
      });
  }

  void configState() {
    inject((Scope scope, Compiler compiler, Injector injector, Logger _logger, DirectiveMap _directives) {
      rootScope = scope;
      logger = _logger;
      compile = (html, [applyFn]) {
        element = $(html);
        compiler(element, _directives)(injector, element);
        scope.apply(applyFn);
      };
      directives = _directives;
    });
  }

  they(should, htmlForElements, callback, [exclusive=false]) {
    htmlForElements.forEach((html) {
      var directiveName = html.contains('ng-if') ? 'ng-if' : 'ng-unless';
      describe(directiveName, () {
        beforeEach(configInjector);
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
      expect(element.contents().length).toEqual(1);
      expect(element.find('span').html()).toEqual('');

      rootScope.apply(() {
        rootScope.context['isVisible'] = true;
      });

      // The span node SHOULD exist in the DOM.
      expect(element.contents().length).toEqual(2);
      expect(element.find('span').html()).toEqual('content');

      rootScope.apply(() {
        rootScope.context['isVisible'] = false;
      });

      expect(element.find('span').html()).toEqual('');
    }
  );

  they('should create a child scope',
    [
      // ng-if
      '<div>' +
      '  <div ng-if="isVisible">'.trim() +
      '    <span child-controller id="inside">{{setBy}}</span>'.trim() +
      '  </div>'.trim() +
      '  <span id="outside">{{setBy}}</span>'.trim() +
      '</div>',
      // ng-unless
      '<div>' +
      '  <div ng-unless="!isVisible">'.trim() +
      '    <span child-controller id="inside">{{setBy}}</span>'.trim() +
      '  </div>'.trim() +
      '  <span id="outside">{{setBy}}</span>'.trim() +
      '</div>'],
    (html) {
      rootScope.context['setBy'] = 'topLevel';
      compile(html);
      expect(element.contents().length).toEqual(2);

      rootScope.apply(() {
        rootScope.context['isVisible'] = true;
      });
      expect(element.contents().length).toEqual(3);
      // The value on the parent scope.context['should'] be unchanged.
      expect(rootScope.context['setBy']).toEqual('topLevel');
      expect(element.find('#outside').html()).toEqual('topLevel');
      // A child scope.context['must'] have been created and hold a different value.
      expect(element.find('#inside').html()).toEqual('childController');
    }
  );

  they('should play nice with other elements beside it',
    [
      // ng-if
      '<div>' +
      '  <div ng-repeat="i in values"></div>'.trim() +
      '  <div ng-if="values.length==4"></div>'.trim() +
      '  <div ng-repeat="i in values"></div>'.trim() +
      '</div>',
      // ng-unless
      '<div>' +
      '  <div ng-repeat="i in values"></div>'.trim() +
      '  <div ng-unless="values.length!=4"></div>'.trim() +
      '  <div ng-repeat="i in values"></div>'.trim() +
      '</div>'],
    (html) {
      var values = rootScope.context['values'] = [1, 2, 3, 4];
      compile(html);
      expect(element.contents().length).toBe(12);
      rootScope.apply(() {
        values.removeRange(0, 1);
      });
      expect(element.contents().length).toBe(9);
      rootScope.apply(() {
        values.insert(0, 1);
      });
      expect(element.contents().length).toBe(12);
    }
  );

  they('should restore the element to its compiled state',
    [
      '<div><span class="my-class" ng-if="isVisible">content</span></div>',
      '<div><span class="my-class" ng-unless="!isVisible">content</span></div>'],
    (html) {
      rootScope.context['isVisible'] = true;
      compile(html);
      expect(element.contents().length).toEqual(2);
      element.find('span').removeClass('my-class');
      expect(element.find('span').hasClass('my-class')).not.toBe(true);
      rootScope.apply(() {
        rootScope.context['isVisible'] = false;
      });
      expect(element.contents().length).toEqual(1);
      rootScope.apply(() {
        rootScope.context['isVisible'] = true;
      });
      // The newly inserted node should be a copy of the compiled state.
      expect(element.find('span').hasClass('my-class')).toBe(true);
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
      expect(element.find('span').html()).toEqual('');
    }
  );

  they('should prevent other directives from running when disabled',
    [
      '<div><li log="ALWAYS"></li><span log="JAMES" ng-if="isVisible">content</span></div>',
      '<div><li log="ALWAYS"></li><span log="JAMES" ng-unless="!isVisible">content</span></div>'],
    (html) {
      compile(html);
      expect(element.find('span').html()).toEqual('');

      rootScope.apply(() {
        rootScope.context['isVisible'] = false;
      });
      expect(element.find('span').html()).toEqual('');
      expect(logger.result()).toEqual('ALWAYS');


      rootScope.apply(() {
        rootScope.context['isVisible'] = true;
      });
      expect(element.find('span').html()).toEqual('content');
      expect(logger.result()).toEqual('ALWAYS; JAMES');
    }
  );

  they('should prevent other directives from running when disabled',
  [
    '<div><div ng-if="a"><div ng-if="b">content</div></div></div>',
    '<div><div ng-unless="!a"><div ng-unless="!b">content</div></div></div>'],
    (html) {
      compile(html);
      expect(element.find('span').html()).toEqual('');

      expect(() {
        rootScope.apply(() {
          rootScope.context['a'] = true;
          rootScope.context['b'] = false;
        });
      }).not.toThrow();
      expect(element.find('span').html()).toEqual('');


      expect(() {
        rootScope.apply(() {
          rootScope.context['a'] = false;
          rootScope.context['b'] = true;
        });
      }).not.toThrow();
      expect(element.find('span').html()).toEqual('');
    }
  );
}
