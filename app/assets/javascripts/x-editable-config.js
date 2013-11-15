$.fn.editable.defaults.ajaxOptions = {type: 'PUT'};

var editable_currency_display = 
  function(value, response) { 
    var html = value > 0 ? '$' + Number(value).toFixed(2) : 'Free'; 
    $(this).html(html);
  };
  