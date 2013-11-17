// util.js
// common scripts

if(!String.prototype.trim) {
  String.prototype.trim = function () {
    return this.replace(/^\s+|\s+$/g,'');
  };
}

function raty_ratings() {
  $('div.star_rating').raty({
    path: '/assets', 
    readOnly: true,
    score: function() {
      return $(this).attr('data-score');
    },
    hints: ['bad', 'poor', 'meh', 'good', 'excellent'],
    noRatedMsg: ''
  });
}

function popover_maps() {
  $('.popover_map').popover({
    html: true,
    placement: 'left',
    template: '<div class="popover" style="width: 480px"><div class="arrow"></div><div class="popover-inner"><h3 class="popover-title"></h3><div class="popover-content"><p></p></div></div></div>',
    trigger: 'hover'
  });

}

function show_bootstrap_alert(opts) {
  var options = $.extend( {
    'type': 'warning',
    'text': '',
    'selector': "#alerts",
    'clear': true
  }, opts);
  if (options.clear) {
    $(options.selector).empty();
  };
  $(options.selector).prepend(HandlebarsTemplates['alerts/show'](options));
}

function auth_token() {
  return $("meta[name='csrf-token']").attr('content');
}

jQuery(function($) {
  raty_ratings();
  popover_maps();
  $(".tooltipify").tooltip();
  $.removeCookie('auto_attend_event');
  $('.click_to_show').click(function(e) {
    window.document.location = $(this).attr("href");
  });
});
