// util.js
// common scripts

//datetime picker on events creation page
jQuery(function($){

  $('.date-select-component').datetimepicker({
    language: 'en',
    pickTime: false
  });

  $('.bootstrap-timepicker input').timepicker();

});
