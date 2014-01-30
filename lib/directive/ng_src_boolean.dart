part of angular.directive;

/**
 * Allows adding and removing the boolean attributes from the element.
 *
 * Using `<button disabled="{{false}}">` does not work since it would result
 * in `<button disabled="false">` rather than `<button>`.
 * Browsers change behavior based on presence/absence of attribute rather the
 * its value.
 *
 * For this reason we provide alternate `ng-`attribute directives to
 * add/remove boolean attributes such as `<button ng-disabled="{{false}}">`
 * which will result in proper removal of the attribute.
 *
 * The full list of supported attributes are:
 *
 *  - [ng-checked]
 *  - [ng-disabled]
 *  - [ng-multiple]
 *  - [ng-open]
 *  - [ng-readonly]
 *  - [ng-required]
 *  - [ng-selected]
 */
@NgDirective(selector: '[ng-checked]',  map: const {'ng-checked':  '=>checked'})
@NgDirective(selector: '[ng-disabled]', map: const {'ng-disabled': '=>disabled'})
@NgDirective(selector: '[ng-multiple]', map: const {'ng-multiple': '=>multiple'})
@NgDirective(selector: '[ng-open]',     map: const {'ng-open':     '=>open'})
@NgDirective(selector: '[ng-readonly]', map: const {'ng-readonly': '=>readonly'})
@NgDirective(selector: '[ng-required]', map: const {'ng-required': '=>required'})
@NgDirective(selector: '[ng-selected]', map: const {'ng-selected': '=>selected'})
class NgBooleanAttributeDirective {
  final NodeAttrs attrs;
  NgBooleanAttributeDirective(this.attrs);

  _setBooleanAttribute(name, value) => attrs[name] = (toBool(value) ? '' : null);

  set checked(value)   => _setBooleanAttribute('checked',  value);
  set disabled(value)  => _setBooleanAttribute('disabled', value);
  set multiple(value)  => _setBooleanAttribute('multiple', value);
  set open(value)      => _setBooleanAttribute('open',     value);
  set readonly(value)  => _setBooleanAttribute('readonly', value);
  set required(value)  => _setBooleanAttribute('required', value);
  set selected(value)  => _setBooleanAttribute('selected', value);
}

/**
 * In browser some attributes have network side-effect. If the attribute
 * has `{{interpolation}}` in it it may cause browser to fetch bogus URLs.
 *
 * Example: In `<img src="{{username}}.png">` the browser will fetch the image
 * `http://server/{{username}}.png` before Angular has a chance to replace the
 * attribute with data-bound url.
 *
 * For this reason we provide `ng-`prefixed attributes which avoid the issues
 * mentioned above as in this example: `<img ng-src="{{username}}.png">`.
 *
 * The full list of supported attributes are:
 *
 * - [ng-href]
 * - [ng-src]
 * - [ng-srcset]
 */
@NgDirective(selector: '[ng-href]',   map: const {'ng-href':   '@href'})
@NgDirective(selector: '[ng-src]',    map: const {'ng-src':    '@src'})
@NgDirective(selector: '[ng-srcset]', map: const {'ng-srcset': '@srcset'})
class NgSourceDirective {
  final NodeAttrs attrs;
  NgSourceDirective(this.attrs);

  set href(value)   => attrs['href']   = value;
  set src(value)    => attrs['src']    = value;
  set srcset(value) => attrs['srcset'] = value;

}

/**
 * In SVG some attributes have a specific syntax. Placing `{{interpolation}}` in
 * those attributes will break the attribute syntax, and browser will clear the
 * attribute.
 *
 * The `ng-attr-*` is a generic way to use interpolation without breaking the
 * attribute syntax validator. The `ng-attr-` part get stripped.
 *
 * @example
 *     <svg>
 *       <circle ng-attr-cx="{{cx}}"></circle>
 *     </svg>
 */
@NgDirective(selector: '[ng-attr-*]')
class NgAttributeDirective implements NgAttachAware {
  final NodeAttrs _attrs;

  NgAttributeDirective(this._attrs);

  void attach() {
    _attrs.forEach((key, value) {
      if (key.startsWith('ngAttr')) {
        var newKey = key.substring(6);
        _attrs[newKey] = value;
        _attrs.observe(snakecase(key), (newValue) => _attrs[newKey] = newValue );
      }
    });
  }
}
