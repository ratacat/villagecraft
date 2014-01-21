// util.js
// common scripts

if(!String.prototype.trim) {
  String.prototype.trim = function () {
    return this.replace(/^\s+|\s+$/g,'');
  };
}

if(!String.prototype.trunc) {
  String.prototype.trunc = String.prototype.trunc ||
      function(n){
          return this.length>n ? this.substr(0,n-1)+'&hellip;' : this;
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
  $('.popover_map').each(function() {
    var _this = $(this);
    _this.popover({
      html: true,
      placement: _this.data('placement') || 'left',
      template: '<div class="popover" style="width: 480px"><div class="arrow"></div><div class="popover-inner"><h3 class="popover-title"></h3><div class="popover-content"><p></p></div></div></div>',
      trigger: 'hover'
    });
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
  
  $(document).on('click', 'form input.submit_on_click', function(e) {
    $(this).closest('form').submit();
  });
  
  var zclip = new ZeroClipboard($('button.zero_clip_button'));
  $(zclip.htmlBridge).tooltip({title: "copy to clipboard", placement: 'bottom', delay: { show: 10, hide: 400 }});
  
  zclip.on( "load", function(client) {
    client.on( "complete", function(client, args) {
      show_bootstrap_alert({type: 'success', text: "Workshop link copied to clipboard.  Paste it to email, Facebook, or Twitter to share."});
    });
  });

  // Default AJAX error handler
  $(document).on("ajax:error", function(evt, xhr, status, error) {
    var errors = $.parseJSON(xhr.responseText).errors.join("; ");
    var message = $.parseJSON(xhr.responseText).message;
    if (errors != '' && message) {
      show_bootstrap_alert({type: 'error', text: message + ': ' + errors});
    } else {
      show_bootstrap_alert({type: 'error', text: message + errors});
    };
  });
});
