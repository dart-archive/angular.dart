part of angular.directive;

/**
 * Sets boolean HTML attributes as true or false. `Selector:
 * [ng-checked]` or `[ng-disabled]` or `[ng-multiple]` or `[ng-open]` or `[ng-readonly]` or
 * `[ng-required]` or `[ng-selected]`
 *
 * Since the presence of a boolean attribute on an element represents the true value,
 * and the absence of the attribute represents the false value, `<button disabled="{{false}}">`
 * would produce `<button disabled="false">` (which disables the button) rather than the desired
 * result: `<button>`.
 *
 * Angular provides alternate `ng-`attribute directives that set elements to true or false
 * by adding or removing boolean attributes as needed.
 *
 * #Example
 *
 *     <button ng-disabled="isDisabled">Button</button>
 */
@Decorator(selector: '[ng-checked]',  map: const {'ng-checked':  '=>checked'})
@Decorator(selector: '[ng-disabled]', map: const {'ng-disabled': '=>disabled'})
@Decorator(selector: '[ng-multiple]', map: const {'ng-multiple': '=>multiple'})
@Decorator(selector: '[ng-open]',     map: const {'ng-open':     '=>open'})
@Decorator(selector: '[ng-readonly]', map: const {'ng-readonly': '=>readonly'})
@Decorator(selector: '[ng-required]', map: const {'ng-required': '=>required'})
@Decorator(selector: '[ng-selected]', map: const {'ng-selected': '=>selected'})
class NgBooleanAttribute {
  final NgElement _ngElement;

  NgBooleanAttribute(this._ngElement);

  void set checked(on)  => _toggleAttribute('checked',  on);
  void set disabled(on) => _toggleAttribute('disabled', on);
  void set multiple(on) => _toggleAttribute('multiple', on);
  void set open(on)     => _toggleAttribute('open', on);
  void set readonly(on) => _toggleAttribute('readonly', on);
  void set required(on) => _toggleAttribute('required', on);
  void set selected(on) => _toggleAttribute('selected', on);

  void _toggleAttribute(attrName, on) {
    if (toBool(on)) {
      _ngElement.setAttribute(attrName);
    } else {
      _ngElement.removeAttribute(attrName);
    }
  }
}

/**
 * Provides `ng-`prefixed attributes to avoid a network side-effect on the `href`, `src`,
 * and `srcset` attributes that can cause the browser to fetch bogus URLs when one of these
 * attributes uses `{{interpolation}}`. `Selector: [ng-href]` or `[ng-src]` or `[ng-srcset]`
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
@Decorator(selector: '[ng-href]',   map: const {'ng-href':   '@href'})
@Decorator(selector: '[ng-src]',    map: const {'ng-src':    '@src'})
@Decorator(selector: '[ng-srcset]', map: const {'ng-srcset': '@srcset'})
class NgSource {
  final NgElement _ngElement;
  NgSource(this._ngElement);

  void set href(value)   => _ngElement.setAttribute('href', value);
  void set src(value)    => _ngElement.setAttribute('src', value);
  void set srcset(value) => _ngElement.setAttribute('srcset', value);

}

/**
 * Provides a generic way to use `{{ }}` interpolation for attributes within validated SVG
 * elements. `Selector: [ng-attr-*]`
 *
 * Because the browser validates SVG syntax, using `{{interpolation}}` inside some validated
 * `<svg>` elements causes the browser to ignore the interpolated value. The `ng-attr-*` selector
 * inserts `{{ }}` into the element without breaking validation. (The `ng-attr-` part is stripped
 * out during rendering.)
 *
 * #Example
 *     <svg>
 *       <circle ng-attr-cx="{{cx}}"></circle>
 *     </svg>
 */
@Decorator(selector: '[ng-attr-*]')
class NgAttribute implements AttachAware {
  final NodeAttrs _attrs;

  NgAttribute(this._attrs);

  void attach() {
    String ngAttrPrefix = 'ng-attr-';
    _attrs.forEach((key, value) {
      if (key.startsWith(ngAttrPrefix)) {
        var newKey = key.substring(ngAttrPrefix.length);
        _attrs[newKey] = value;
        _attrs.observe(key, (newValue) => _attrs[newKey] = newValue );
      }
    });
  }
}
