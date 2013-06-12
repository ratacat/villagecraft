// util.js
// common scripts

//datetime picker on events creation page
jQuery(function($){

  $('.date-select-component').datetimepicker({
    language: 'en',
    pickTime: false
  });

  $('.time-select-component').datetimepicker({
    pickDate: false,
    pick12HourFormat: true,
    pickSeconds: false
  });

});
