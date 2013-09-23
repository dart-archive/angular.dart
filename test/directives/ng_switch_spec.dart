library ng_switch_spec;

import '../_specs.dart';
import '../_test_bed.dart';

main() => describe('ngSwitch', () {
  TestBed _;

  beforeEach(beforeEachTestBed((tb) => _ = tb));

  it('should switch on value change', inject(() {
    var element = _.compile(
        '<div ng-switch="select">' +
        '<div ng-switch-when="1">first:{{name}}</div>' +
        '<div ng-switch-when="2">second:{{name}}</div>' +
        '<div ng-switch-when="true">true:{{name}}</div>' +
        '</div>');
    expect(element.html()).toEqual(
        '<!--ANCHOR: [ng-switch-when]=1--><!--ANCHOR: [ng-switch-when]=2--><!--ANCHOR: [ng-switch-when]=true-->');
    _.rootScope.select = 1;
    _.rootScope.$apply();
    expect(element.text()).toEqual('first:');
    _.rootScope.name="shyam";
    _.rootScope.$apply();
    expect(element.text()).toEqual('first:shyam');
    _.rootScope.select = 2;
    _.rootScope.$apply();
    expect(element.text()).toEqual('second:shyam');
    _.rootScope.name = 'misko';
    _.rootScope.$apply();
    expect(element.text()).toEqual('second:misko');
    _.rootScope.select = true;
    _.rootScope.$apply();
    expect(element.text()).toEqual('true:misko');
  }));


  it('should show all switch-whens that match the current value', inject(() {
    var element = _.compile(
      '<ul ng-switch="select">' +
        '<li ng-switch-when="1">first:{{name}}</li>' +
        '<li ng-switch-when="1">, first too:{{name}}</li>' +
        '<li ng-switch-when="2">second:{{name}}</li>' +
        '<li ng-switch-when="true">true:{{name}}</li>' +
      '</ul>');
    expect(element.html()).toEqual('<!--ANCHOR: [ng-switch-when]=1-->'
                                   '<!--ANCHOR: [ng-switch-when]=1-->'
                                   '<!--ANCHOR: [ng-switch-when]=2-->'
                                   '<!--ANCHOR: [ng-switch-when]=true-->');
    _.rootScope.select = 1;
    _.rootScope.$apply();
    expect(element.text()).toEqual('first:, first too:');
    _.rootScope.name="shyam";
    _.rootScope.$apply();
    expect(element.text()).toEqual('first:shyam, first too:shyam');
    _.rootScope.select = 2;
    _.rootScope.$apply();
    expect(element.text()).toEqual('second:shyam');
    _.rootScope.name = 'misko';
    _.rootScope.$apply();
    expect(element.text()).toEqual('second:misko');
    _.rootScope.select = true;
    _.rootScope.$apply();
    expect(element.text()).toEqual('true:misko');
  }));


  it('should switch on switch-when-default', inject(() {
    var element = _.compile(
      '<div ng-switch="select">' +
        '<div ng-switch-when="1">one</div>' +
        '<div ng-switch-default>other</div>' +
      '</div ng-switch>');
    _.rootScope.$apply();
    expect(element.text()).toEqual('other');
    _.rootScope.select = 1;
    _.rootScope.$apply();
    expect(element.text()).toEqual('one');
  }));


  it('should show all switch-when-default', inject(() {
    var element = _.compile(
      '<ul ng-switch="select">' +
        '<li ng-switch-when="1">one</li>' +
        '<li ng-switch-default>other</li>' +
        '<li ng-switch-default>, other too</li>' +
      '</ul>');
    _.rootScope.$apply();
    expect(element.text()).toEqual('other, other too');
    _.rootScope.select = 1;
    _.rootScope.$apply();
    expect(element.text()).toEqual('one');
  }));


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
    _.rootScope.$apply();
    expect(element.text()).toEqual('always other, other too ');
    _.rootScope.select = 1;
    _.rootScope.$apply();
    expect(element.text()).toEqual('always one ');
  }));


  it('should display the elements that do not have ngSwitchWhen nor ' +
     'ngSwitchDefault at the position specified in the template, when the ' +
     'first and last elements in the ngSwitch body do not have a ngSwitch* ' +
     'directive', inject(() {
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
    _.rootScope.$apply();
    expect(element.text()).toEqual('135678');
    _.rootScope.select = 1;
    _.rootScope.$apply();
    expect(element.text()).toEqual('12368');
  }));


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
    _.rootScope.$apply();
    expect(element.text()).toEqual('3567');
    _.rootScope.select = 1;
    _.rootScope.$apply();
    expect(element.text()).toEqual('236');
  }));


  it('should call change on switch', inject(() {
    var element = _.compile(
      '<div ng-switch="url" change="name=\'works\'">' +
        '<div ng-switch-when="a">{{name}}</div>' +
      '</div ng-switch>');
    _.rootScope.url = 'a';
    _.rootScope.$apply();
    expect(_.rootScope.name).toEqual('works');
    expect(element.text()).toEqual('works');
  }));


  it('should properly create and destroy child scopes', inject(() {
    var element = _.compile(
      '<div ng-switch="url">' +
        '<div ng-switch-when="a" probe="probe">{{name}}</div>' +
      '</div ng-switch>');
    _.rootScope.$apply();

    var getChildScope = () => _.rootScope.probe == null ?
        null : _.rootScope.probe.scope;

    expect(getChildScope()).toBeNull();

    _.rootScope.url = 'a';
    _.rootScope.name = 'works';
    _.rootScope.$apply();
    var child1 = getChildScope();
    expect(child1).toBeNotNull();
    expect(element.text()).toEqual('works');
    var destroyListener = jasmine.createSpy('watch listener');
    var listenerRemove = child1.$on('\$destroy', destroyListener);

    _.rootScope.url = 'x';
    _.rootScope.$apply();
    print(element);
    print(getChildScope());
    expect(getChildScope()).toBeNull();
    expect(destroyListener).toHaveBeenCalledOnce();
    listenerRemove();

    _.rootScope.url = 'a';
    _.rootScope.$apply();
    var child2 = getChildScope();
    expect(child2).toBeDefined();
    expect(child2).not.toBe(child1);
  }));
});
