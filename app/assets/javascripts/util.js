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

jQuery(function($) {
  raty_ratings();
  $(".tooltipify").tooltip();
  $.removeCookie('auto_attend_event');
});
