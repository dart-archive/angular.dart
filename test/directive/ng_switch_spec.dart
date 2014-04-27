library ng_switch_spec;

import '../_specs.dart';

void main() {
  describe('ngSwitch', () {
    TestBed _;

    beforeEach((TestBed tb) => _ = tb);

    it('should switch on value change', () {
      var element = _.compile(
          '<div ng-switch="select">' +
          '<div ng-switch-when="1">first:{{name}}</div>' +
          '<div ng-switch-when="2">second:{{name}}</div>' +
          '<div ng-switch-when="true">true:{{name}}</div>' +
          '</div>');
      expect(element.innerHtml).toEqual(
          '<!--ANCHOR: [ng-switch-when]=1--><!--ANCHOR: [ng-switch-when]=2--><!--ANCHOR: [ng-switch-when]=true-->');
      _.rootScope.context['select'] = 1;
      _.rootScope.apply();
      expect(element.text).toEqual('first:');
      _.rootScope.context['name'] = "shyam";
      _.rootScope.apply();
      expect(element.text).toEqual('first:shyam');
      _.rootScope.context['select'] = 2;
      _.rootScope.apply();
      expect(element.text).toEqual('second:shyam');
      _.rootScope.context['name'] = 'misko';
      _.rootScope.apply();
      expect(element.text).toEqual('second:misko');
      _.rootScope.context['select'] = true;
      _.rootScope.apply();
      expect(element.text).toEqual('true:misko');
    });


    it('should show all switch-whens that match the current value', () {
      var element = _.compile(
          '<ul ng-switch="select">' +
          '<li ng-switch-when="1">first:{{name}}</li>' +
          '<li ng-switch-when="1">, first too:{{name}}</li>' +
          '<li ng-switch-when="2">second:{{name}}</li>' +
          '<li ng-switch-when="true">true:{{name}}</li>' +
          '</ul>');
      expect(element.innerHtml).toEqual('<!--ANCHOR: [ng-switch-when]=1-->'
      '<!--ANCHOR: [ng-switch-when]=1-->'
      '<!--ANCHOR: [ng-switch-when]=2-->'
      '<!--ANCHOR: [ng-switch-when]=true-->');
      _.rootScope.context['select'] = 1;
      _.rootScope.apply();
      expect(element.text).toEqual('first:, first too:');
      _.rootScope.context['name'] = "shyam";
      _.rootScope.apply();
      expect(element.text).toEqual('first:shyam, first too:shyam');
      _.rootScope.context['select'] = 2;
      _.rootScope.apply();
      expect(element.text).toEqual('second:shyam');
      _.rootScope.context['name'] = 'misko';
      _.rootScope.apply();
      expect(element.text).toEqual('second:misko');
      _.rootScope.context['select'] = true;
      _.rootScope.apply();
      expect(element.text).toEqual('true:misko');
    });


    it('should switch on switch-when-default', () {
      var element = _.compile(
          '<div ng-switch="select">' +
          '<div ng-switch-when="1">one</div>' +
          '<div ng-switch-default>other</div>' +
          '</div ng-switch>');
      _.rootScope.apply();
      expect(element.text).toEqual('other');
      _.rootScope.context['select'] = 1;
      _.rootScope.apply();
      expect(element.text).toEqual('one');
    });


    it('should show all switch-when-default', () {
      var element = _.compile(
          '<ul ng-switch="select">' +
          '<li ng-switch-when="1">one</li>' +
          '<li ng-switch-default>other</li>' +
          '<li ng-switch-default>, other too</li>' +
          '</ul>');
      _.rootScope.apply();
      expect(element.text).toEqual('other, other too');
      _.rootScope.context['select'] = 1;
      _.rootScope.apply();
      expect(element.text).toEqual('one');
    });


    it('should always display the elements that do not match a switch',
    inject(() {
      var element = _.compile(
          '<ul ng-switch="select">' +
          '<li>always </li>' +
          '<li ng-switch-when="1">one </li>' +
          '<li ng-switch-when="2">two </li>' +
          '<li ng-switch-default>other, </li>' +
          '<li ng-switch-default>other too </li>' +
          '</ul>');
      _.rootScope.apply();
      expect(element.text).toEqual('always other, other too ');
      _.rootScope.context['select'] = 1;
      _.rootScope.apply();
      expect(element.text).toEqual('always one ');
    }));


    it('should display the elements that do not have ngSwitchWhen nor ' +
    'ngSwitchDefault at the position specified in the template, when the ' +
    'first and last elements in the ngSwitch body do not have a ngSwitch* ' +
    'directive', () {
      var element = _.compile(
          '<ul ng-switch="select">' +
          '<li>1</li>' +
          '<li ng-switch-when="1">2</li>' +
          '<li>3</li>' +
          '<li ng-switch-when="2">4</li>' +
          '<li ng-switch-default>5</li>' +
          '<li>6</li>' +
          '<li ng-switch-default>7</li>' +
          '<li>8</li>' +
          '</ul>');
      _.rootScope.apply();
      expect(element.text).toEqual('135678');
      _.rootScope.context['select'] = 1;
      _.rootScope.apply();
      expect(element.text).toEqual('12368');
    });


    it('should display the elements that do not have ngSwitchWhen nor ' +
    'ngSwitchDefault at the position specified in the template when the ' +
    'first and last elements in the ngSwitch have a ngSwitch* directive',
    inject(() {
      var element = _.compile(
          '<ul ng-switch="select">' +
          '<li ng-switch-when="1">2</li>' +
          '<li>3</li>' +
          '<li ng-switch-when="2">4</li>' +
          '<li ng-switch-default>5</li>' +
          '<li>6</li>' +
          '<li ng-switch-default>7</li>' +
          '</ul>');
      _.rootScope.apply();
      expect(element.text).toEqual('3567');
      _.rootScope.context['select'] = 1;
      _.rootScope.apply();
      expect(element.text).toEqual('236');
    }));


    it('should call change on switch', () {
      var element = _.compile(
          '<div ng-switch="url" change="name=\'works\'">' +
          '<div ng-switch-when="a">{{name}}</div>' +
          '</div ng-switch>');
      _.rootScope.context['url'] = 'a';
      _.rootScope.apply();
      expect(_.rootScope.context['name']).toEqual('works');
      expect(element.text).toEqual('works');
    });


    it('should properly create and destroy child scopes', () {
      var element = _.compile(
          '<div ng-switch="url">' +
          '<div ng-switch-when="a" probe="probe">{{name}}</div>' +
          '</div ng-switch>');
      _.rootScope.apply();

      var getChildScope = () => _.rootScope.context['probe'] == null ?
      null : _.rootScope.context['probe'].scope;

      expect(getChildScope()).toBeNull();

      _.rootScope.context['url'] = 'a';
      _.rootScope.context['name'] = 'works';
      _.rootScope.apply();
      var child1 = getChildScope();
      expect(child1).toBeNotNull();
      expect(element.text).toEqual('works');
      var destroyListener = guinness.createSpy('watch listener');
      var watcher = child1.on(ScopeEvent.DESTROY).listen(destroyListener);

      _.rootScope.context['url'] = 'x';
      _.rootScope.apply();
      expect(getChildScope()).toBeNull();
      expect(destroyListener).toHaveBeenCalledOnce();
      watcher.cancel();

      _.rootScope.context['url'] = 'a';
      _.rootScope.apply();
      var child2 = getChildScope();
      expect(child2).toBeDefined();
      expect(child2).not.toBe(child1);
    });
  });
}
