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

// compute the great circle distance ignoring ellipsoidal effects, which is fine over short distances; 
// to get high-accuracy over large distances, use Vincenty’s formula (http://www.movable-type.co.uk/scripts/latlong-vincenty.html), 
function getDistanceFromLatLonInKm(lat1,lon1,lat2,lon2) {
  var R = 6371; // Radius of the earth in km
  var dLat = deg2rad(lat2-lat1);  // deg2rad below
  var dLon = deg2rad(lon2-lon1); 
  var a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) * 
    Math.sin(dLon/2) * Math.sin(dLon/2)
    ; 
  var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
  var d = R * c; // Distance in km
  return d;
}

function deg2rad(deg) {
  return deg * (Math.PI/180)
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

  $('form.auto_submit :input').change(function(){
    $(this).closest('form').submit();
  });

  $(document).delegate('*[data-toggle="lightbox"]', 'click', function(event) {
      event.preventDefault();
      $(this).ekkoLightbox({always_show_close: false});
  });

  // Default AJAX error handler
  $(document).on("ajax:error", function(evt, xhr, status, error) {
    var errors = $.parseJSON(xhr.responseText).errors.join("; ");
    var message = $.parseJSON(xhr.responseText).message;
    if (errors != '' && message) {
      show_bootstrap_alert({type: 'warning', text: message + ': ' + errors});
    } else {
      show_bootstrap_alert({type: 'warning', text: message + errors});
    };
  });
});
