$.fn.format_phone_number = function() {
  var country = 'us';
  return this.each(function() {
    var cur_val = $(this).val();
    cur_val = cur_val.replace(/^\+1/,'');
    $(this).val(formatLocal(country, cur_val));
  });
};

$.fn.format_phone_number_html = function() {
  var country = 'us';
  return this.each(function() {
    var cur_val = $(this).text();
    cur_val = cur_val.replace(/^\+1/,'');
    $(this).text(formatLocal(country, cur_val));
  });
};

$('#user_phone').format_phone_number();

$('#user_phone').keypress(function(e) {
  $(this).format_phone_number();
});

$('#user_phone').blur(function(e) {
  $(this).format_phone_number();
});
