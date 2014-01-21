$.fn.editable.defaults.ajaxOptions = {type: 'PUT'};
$.fn.editable.defaults.error = 
  function(response, newValue) { 
    var field_name = $(this).data('name'),
        error_msgs = response.responseJSON[field_name];
    return error_msgs.join("; ");
  };

var editable_currency_display = 
  function(value, response) { 
    var html = value > 0 ? '$' + Number(value).toFixed(0) : 'Free'; 
    $(this).html(html);
  };

var click_to_edit_url_display = 
  function(value, response) { 
    $(this).html(value.trunc(25));
  };

var yes_or_no_display = 
  function(value, response) { 
    $(this).html(value ? 'yes' : 'no');
  };
