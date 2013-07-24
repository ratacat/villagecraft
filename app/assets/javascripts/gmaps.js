var gmap_options = {};

function initializeGMap() {
  var myLatlng = new google.maps.LatLng(gmap_options.lat, gmap_options.lon);
  var mapOptions = {
    zoom: gmap_options.zoom,
    center: myLatlng,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  }
  
  var map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);

  var marker = new google.maps.Marker({
    position: myLatlng,
    map: map,
    animation: google.maps.Animation.DROP,
    title: gmap_options.title
  });

  if (typeof gmap_options.info != 'undefined') {
    var contentString = '<div id="gmap_info_content">'+
        '<h4>' + gmap_options.title + '</h4>'+
        '<div id="gmap_info_body_content">'+
        '<p>' +
        gmap_options.info +
        '</p>' +
        '</div>';

    var infowindow = new google.maps.InfoWindow({
        content: contentString
    });
    
    google.maps.event.addListener(marker, 'click', function() {
      infowindow.open(map,marker);
    });
  };
  
}

function loadGMap(options) {
  var default_options = {
    title: '',
    zoom: 16
  };
  gmap_options = $.extend(default_options, options);
  var script = document.createElement("script");
  var api_key = "AIzaSyCl3ttkTdZRcseyq4_Jyx0msz4ae7e0n9c";
  script.type = "text/javascript";
  script.src = "http://maps.googleapis.com/maps/api/js?key=" + api_key + "&sensor=false&callback=initializeGMap";
  document.body.appendChild(script);
}
