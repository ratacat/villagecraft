/*
 * jquery.transition.highlight. jQuery highlight effect using only CSS transitions
 *
 * Copyright (c) 2013 Ben Teitelbaum
 * http://ben.teitelbaum.us/
 *
 * Licensed under MIT
 * http://www.opensource.org/licenses/mit-license.php
 *
 * Usage:
 * 
 * Flash a yellow highlight on a SPAN.
 * $('#booyah').highlight();
 *
 * Flash a red highlight on all DIVs with a certain class.
 * $("div.stopsign").highlight({'color' : 'red'})
 *
*/
(function ($) {
  $.fn.highlight = function (options) {
    var settings = $.extend({
      'color'                  : '#FFFF80',
      'clear-transition-delay' : 1700
      }, options);

    function set_transition(options) {
      var settings = $.extend({
        'property' : 'background-color',
        'duration' : '1400ms',
        'timing'   : 'ease-out',
        'delay'    : '0s',
        'clear'    : false
        }, options);
      if (settings['clear']) {
        var style_s = '';
      } else {
        var style = [settings['property'], settings['duration'], settings['timing'], settings['delay']], 
            style_s = style.join(' ');                
      };
      return {
        '-webkit-transition' : style_s,
        '-moz-transition' : style_s,
        '-o-transition' : style_s,
        '-ms-transition' : style_s,
        'transition' : style_s
      };
    }

    return this.each(function () {
      var e = $(this),
      old_bg = e.css('background-color');

      e.css('background-color', settings['color']);

      setTimeout(function () {
        if (old_bg === 'transparent') {
          old_bg = '';
        }
        e.css(set_transition());
        e.css('background-color', old_bg);
        setTimeout(function () {
          e.css(set_transition({'clear' : true}));
        }, settings['clear-transition-delay']);
      }, 10);
    });
  };
})(jQuery);
