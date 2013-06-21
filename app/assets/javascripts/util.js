// util.js
// common scripts

//datetime picker on events creation page
jQuery(function($){

  $('.date-select-component').datetimepicker({
    language: 'en',
    pickTime: false,
    startDate: '0d'
  });

  $('.bootstrap-timepicker input').timepicker();
  
  /* FIXME: Incomplete B-list code to constrain a pair of timepickers
  $("input.constrain-other-datetime[data-constrain-start-datetime-id]").timepicker().on('changeTime.timepicker', function(e) {
    var start_id = $(this).data('constrain-start-datetime-id'),
        end_id = $(this).data('constrain-end-datetime-id'),
        t = e.time.value;
    if (start_id) {
      $('#' + start_id).timepicker('setTime', t);
    }
  });
  */
});
