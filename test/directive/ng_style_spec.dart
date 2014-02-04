library ng_style_spec;

import '../_specs.dart';
import 'dart:html' as dom;

main() => describe('NgStyle', () {
  TestBed _;

  beforeEach(inject((TestBed tb) => _ = tb));

  it('should set', () {
    dom.Element element = _.compile('<div ng-style="{height: \'40px\'}"></div>');
    _.rootScope.apply();
    expect(element.style.height).toEqual('40px');
  });


  it('should silently ignore undefined style', () {
    dom.Element element = _.compile('<div ng-style="myStyle"></div>');
    _.rootScope.apply();
    expect(element.classes.contains('ng-exception')).toBeFalsy();
  });


  describe('preserving styles set before and after compilation', () {
    var scope, preCompStyle, preCompVal, postCompStyle, postCompVal, element;

    beforeEach(inject(() {
      preCompStyle = 'width';
      preCompVal = '300px';
      postCompStyle = 'height';
      postCompVal = '100px';
      element = $('<div ng-style="styleObj"></div>');
      element.css(preCompStyle, preCompVal);
      document.body.append(element[0]);
      _.compile(element);
      scope = _.rootScope;
      scope.context['styleObj'] = {'margin-top': '44px'};
      scope.apply();
      element.css(postCompStyle, postCompVal);
    }));

    afterEach(() {
      element.remove(null);
    });


    it('should not mess up stuff after compilation', () {
      element.css('margin', '44px');
      expect(element.css(preCompStyle)).toEqual(preCompVal);
      expect(element.css('margin-top')).toEqual('44px');
      expect(element.css(postCompStyle)).toEqual(postCompVal);
    });

    it(r'should not mess up stuff after $apply with no model changes', () {
      element.css('padding-top', '33px');
      scope.apply();
      expect(element.css(preCompStyle)).toEqual(preCompVal);
      expect(element.css('margin-top')).toEqual('44px');
      expect(element.css(postCompStyle)).toEqual(postCompVal);
      expect(element.css('padding-top')).toEqual('33px');
    });


    it(r'should not mess up stuff after $apply with non-colliding model changes', () {
      scope.context['styleObj'] = {'padding-top': '99px'};
      scope.apply();
      expect(element.css(preCompStyle)).toEqual(preCompVal);
      expect(element.css('margin-top')).not.toEqual('44px');
      expect(element.css('padding-top')).toEqual('99px');
      expect(element.css(postCompStyle)).toEqual(postCompVal);
    });


    it(r'should overwrite original styles after a colliding model change', () {
      scope.context['styleObj'] = {'height': '99px', 'width': '88px'};
      scope.apply();
      expect(element.css(preCompStyle)).toEqual('88px');
      expect(element.css(postCompStyle)).toEqual('99px');
      scope.context['styleObj'] = {};
      scope.apply();
      expect(element.css(preCompStyle)).not.toEqual('88px');
      expect(element.css(postCompStyle)).not.toEqual('99px');
    });
  });
});
