library ng_style_spec;

import '../_specs.dart';
import 'dart:html' as dom;

void main() {
  describe('NgStyle', () {
    TestBed _;

    beforeEach((TestBed tb) => _ = tb);

    it('should set', () {
      dom.Element element = _.compile('<div ng-style="{height: \'40px\'}"></div>');
      _.rootScope.apply();
      expect(element.style.height).toEqual('40px');
    });


    it('should silently ignore undefined style', () {
      dom.Element element = _.compile('<div ng-style="myStyle"></div>');
      _.rootScope.apply();
      expect(element).not.toHaveClass('ng-exception');
    });


    describe('preserving styles set before and after compilation', () {
      var scope, preCompStyle, widthVal, postCompStyle, heightVal;
      Element element;

      beforeEach(() {
        preCompStyle = 'width';
        widthVal = '300px';
        postCompStyle = 'height';
        heightVal = '100px';
        element = e('<div ng-style="styleObj"></div>');
        element.style.width = widthVal;
        document.body.append(element);
        _.compile(element);
        scope = _.rootScope;
        scope.context['styleObj'] = {'margin-top': '44px'};
        scope.apply();
        element.style.height = heightVal;
      });

      it('should not mess up stuff after compilation', () {
        element.style.margin = '44px';
        expect(element.style.width).toEqual(widthVal);
        expect(element.style.marginTop).toEqual('44px');
        expect(element.style.height).toEqual(heightVal);
      });

      it(r'should not mess up stuff after $apply with no model changes', () {
        element.style.paddingTop = '33px';
        scope.apply();
        expect(element.style.width).toEqual(widthVal);
        expect(element.style.marginTop).toEqual('44px');
        expect(element.style.height).toEqual(heightVal);
        expect(element.style.paddingTop).toEqual('33px');
      });


      it(r'should not mess up stuff after $apply with non-colliding model changes', () {
        scope.context['styleObj'] = {'padding-top': '99px'};
        scope.apply();
        expect(element.style.width).toEqual(widthVal);
        expect(element.style.marginTop).not.toEqual('44px');
        expect(element.style.paddingTop).toEqual('99px');
        expect(element.style.height).toEqual(heightVal);
      });


      it(r'should overwrite original styles after a colliding model change', () {
        scope.context['styleObj'] = {'height': '99px', 'width': '88px'};
        scope.apply();
        expect(element.style.width).toEqual('88px');
        expect(element.style.height).toEqual('99px');
        scope.context['styleObj'] = {};
        scope.apply();
        expect(element.style.width).not.toEqual('88px');
        expect(element.style.height).not.toEqual('99px');
      });
    });
  });
}
