var gmap_options = {};

function initializeGMap() {
  var myLatlng = new google.maps.LatLng(gmap_options.lat, gmap_options.lon);
  var mapOptions = {
    zoom: gmap_options.zoom,
    center: myLatlng,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  }
  
  var map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);

  if (gmap_options.show_address) {
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
  };

  // NB: only works whem kml_layer_url is PUBLIC
  if (typeof gmap_options.kml_layer_url != 'undefined') {
    var kml_layer = new google.maps.KmlLayer(gmap_options.kml_layer_url);
    kml_layer.setMap(map);
  }
  
  if (typeof gmap_options.geo_json != 'undefined') {
    var llbounds = new google.maps.LatLngBounds();
    var googleVector = new GeoJSON(gmap_options.geo_json, gmap_options.geo_json_options, llbounds);

    if (googleVector.type === 'Error') {
      alert("Error in GeoJSON: " + myGoogleVector.error.message)
    } else {
      if (!googleVector.length) {
        googleVector.setMap(map);
      } else {
        for(var idx in googleVector) {
          googleVector[idx].setMap(map);
        }
      }
      map.fitBounds(llbounds);
    }
  }  
}

function loadGMap(options) {
  var default_options = {
    title: '',
    zoom: 16,
    show_address: false,
    geo_json_options: {
        "strokeColor": "#1450B4",
        "strokeOpacity": 1,
        "strokeWeight": 4,
        "fillColor": "#1450B4",
        "fillOpacity": 0.40
    }
  };
  gmap_options = $.extend(default_options, options);

  var script = document.createElement("script");
  script.type = "text/javascript";
  script.src = "http://maps.googleapis.com/maps/api/js?key=" + ENV.GOOGLE_MAPS_API_KEY + "&sensor=false&callback=initializeGMap";
  document.body.appendChild(script);
}
