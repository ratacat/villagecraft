$.fn.editable.defaults.ajaxOptions = {type: 'PUT'};

var editable_currency_display = 
  function(value, response) { 
    var html = value > 0 ? '$' + Number(value).toFixed(0) : 'Free'; 
    $(this).html(html);
  };
  