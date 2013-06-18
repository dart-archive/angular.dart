import "_specs.dart";
import "_log.dart";

class LogAttrDirective {
  static var $priority = 0;
  Log log;
  LogAttrDirective(Log this.log, NodeAttrs attrs) {
    log(attrs[this] == "" ? "LOG" : attrs[this]);
  }
}

class ReplaceComponent {
  static String $template = '<div log="REPLACE" style="width: 10px" high-log>Replace!</div>';
  static var $replace = true;
  ReplaceComponent(Node node) {
    node.attributes['compiled'] = 'COMPILED';
  }
}

class ReplacetwoComponent {
  static String $template = '<div log="REPLACE" style="width: 10px" high-log>Re<div>place!</div></div>';
  static var $replace = true;
  ReplaceComponent(Node node) {
    node.attributes['compiled'] = 'COMPILED';
  }
}

class ShadowtranscludeComponent {
  static String $template = '<div log="REPLACE" style="width: 10px" high-log>Replace!<content>SHADOW-CONTENT</content></div>';
  static var $replace = true;
  ShadowtranscludeDirective(Node node) {
    node.attributes['compiled'] = 'COMPILED';
  }
}

class AppendAttrDirective {
  static String $template = '<div log style="width: 10px" high-log>Append!</div>';
  AppendAttrDirective(Node node) {
    node.attributes['compiled'] = 'COMPILED';
  }
}

main() {
  describe('template', () {
    var element, directive, $compile, $rootScope;

    beforeEach(inject((Injector injector) {
      element = null;
      injector.get(DirectiveRegistry)
      ..register(LogAttrDirective)
      ..register(ReplaceComponent)
      ..register(ReplacetwoComponent)
      ..register(ShadowtranscludeComponent);
    }));


    xit('should replace element with template', inject((Compiler $compile, Scope $rootScope, Log log, Injector injector) {
      var element = $('<div><replace log>ignore</replace><div>');
      $compile(element)(injector, element);
      expect(renderedText(element)).toEqual('Replace!');
      expect(log.result()).toEqual('REPLACE; LOG');
    }));

    xit('should replacetwo element with template', inject((Compiler $compile, Scope $rootScope, Log log, Injector injector) {
      var element = $('<div><replacetwo log>ignore</replacetwo><div>');
      $compile(element)(injector, element);
      expect(renderedText(element)).toEqual('Replace!');
      expect(log.result()).toEqual('REPLACE; LOG');
    }));

    xit('should support transclusion within the template', inject((Compiler $compile, Scope $rootScope, Log log, Injector injector) {
      var element = $('<div><shadowtransclude log>transcluded</shadowtransclude><div>');
      $compile(element)(injector, element);
      expect(renderedText(element)).toEqual('Replace!transcluded');
      expect(log.result()).toEqual('REPLACE; LOG');
    }));

/*
    it('should append element with template', inject(function($compile, $rootScope) {
      element = $compile('<div><div append>ignore</div><div>')($rootScope);
      expect(element.text()).toEqual('Append!');
      expect(element.find('div').attr('compiled')).toEqual('COMPILED');
    }));



    it('should compile template when replacing', inject(($compile, $rootScope, log) {
      element = $compile('<div><div replace medium-log>ignore</div><div>')
        ($rootScope);
      $rootScope.$digest();
      expect(element.text()).toEqual('Replace!');
      // HIGH goes after MEDIUM since it executes as part of replaced template
      expect(log).toEqual('MEDIUM; HIGH; LOG');
    }));


    it('should compile template when appending', inject(function($compile, $rootScope, log) {
      element = $compile('<div><div append medium-log>ignore</div><div>')
        ($rootScope);
      $rootScope.$digest();
      expect(element.text()).toEqual('Append!');
      expect(log).toEqual('HIGH; LOG; MEDIUM');
    }));


    it('should merge attributes including style attr', inject(function($compile, $rootScope) {
      element = $compile(
        '<div><div replace class="medium-log" style="height: 20px" ></div><div>')
        ($rootScope);
      var div = element.find('div');
      expect(div.hasClass('medium-log')).toBe(true);
      expect(div.hasClass('log')).toBe(true);
      expect(div.css('width')).toBe('10px');
      expect(div.css('height')).toBe('20px');
      expect(div.attr('replace')).toEqual('');
      expect(div.attr('high-log')).toEqual('');
    }));

    it('should prevent multiple templates per element', inject(function($compile) {
      try {
        $compile('<div><span replace class="replace"></span></div>')
        fail();
      } catch(e) {
        expect(e.message).toMatch(/Multiple directives .* asking for template/);
      }
    }));

    it('should play nice with repeater when replacing', inject(function($compile, $rootScope) {
      element = $compile(
        '<div>' +
          '<div ng-repeat="i in [1,2]" replace></div>' +
        '</div>')($rootScope);
      $rootScope.$digest();
      expect(element.text()).toEqual('Replace!Replace!');
    }));


    it('should play nice with repeater when appending', inject(function($compile, $rootScope) {
      element = $compile(
        '<div>' +
          '<div ng-repeat="i in [1,2]" append></div>' +
        '</div>')($rootScope);
      $rootScope.$digest();
      expect(element.text()).toEqual('Append!Append!');
    }));


    it('should handle interpolated css from replacing directive', inject(
        function($compile, $rootScope) {
      element = $compile('<div replace-with-interpolated-class></div>')($rootScope);
      $rootScope.$digest();
      expect(element).toHaveClass('class_2');
    }));


    it('should merge interpolated css class', inject(function($compile, $rootScope) {
      element = $compile('<div class="one {{cls}} three" replace></div>')($rootScope);

      $rootScope.$apply(function() {
        $rootScope.cls = 'two';
      });

      expect(element).toHaveClass('one');
      expect(element).toHaveClass('two'); // interpolated
      expect(element).toHaveClass('three');
      expect(element).toHaveClass('log'); // merged from replace directive template
    }));


    it('should merge interpolated css class with ngRepeat',
        inject(function($compile, $rootScope) {
      element = $compile(
          '<div>' +
            '<div ng-repeat="i in [1]" class="one {{cls}} three" replace></div>' +
          '</div>')($rootScope);

      $rootScope.$apply(function() {
        $rootScope.cls = 'two';
      });

      var child = element.find('div').eq(0);
      expect(child).toHaveClass('one');
      expect(child).toHaveClass('two'); // interpolated
      expect(child).toHaveClass('three');
      expect(child).toHaveClass('log'); // merged from replace directive template
    }));

    it("should fail if replacing and template doesn't have a single root element", function() {
      module(function() {
        directive('noRootElem', function() {
          return {
            replace: true,
            template: 'dada'
          }
        });
        directive('multiRootElem', function() {
          return {
            replace: true,
            template: '<div></div><div></div>'
          }
        });
        directive('singleRootWithWhiteSpace', function() {
          return {
            replace: true,
            template: '  <div></div> \n'
          }
        });
      });

      inject(function($compile) {
        expect(function() {
          $compile('<p no-root-elem></p>');
        }).toThrow('Template must have exactly one root element. was: dada');

        expect(function() {
          $compile('<p multi-root-elem></p>');
        }).toThrow('Template must have exactly one root element. was: <div></div><div></div>');

        // ws is ok
        expect(function() {
          $compile('<p single-root-with-white-space></p>');
        }).not.toThrow();
      });
      */
    });
//    });

}
