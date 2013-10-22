(function( $ ){
 $.fn.vc_modal_register = function( options ) {
   return this.each(function() {
     var $this = $(this),
      options = $.extend({}, $.fn.vc_modal_register.defaults, $this.data(), typeof option == 'object' && option);

     $this.on('click', function() {
       if (typeof options['auto_attend_event'] != 'undefined') {
         $.cookie('auto_attend_event', options['auto_attend_event']);
       };
       $('#' + options['modal_id'] + ' span.event_title').html(options['auto_attend_event_title']);
       $('#' + options['modal_id']).modal('show');
     });
   });
 };
 
 $.fn.vc_modal_register.defaults = {
   modal_id: "register_modal"
 };   
 
 $("[data-toggle_modal_registration]").vc_modal_register();
 
 $("#register_modal").on('show', function() {
   if ($.cookie('auto_attend_event')) {
     $(this).find("p.event_signup_notification").show();
   } else {
     $(this).find("p.event_signup_notification").hide();
   }
 });
 
 $("#register_modal").on('hide', function() {
   $.removeCookie('auto_attend_event');
 });
 
 $('#attend_by_email_form').submit(function(event) {
   event.preventDefault();
   var event_uuid = $.cookie('auto_attend_event'), 
       email = $(this).find('input[name="user[email]"]').val();
   $.ajax({
     type: "POST",
     url: '/attend_by_email/' + event_uuid,
     data: { email: email },
     dataType: 'json'
   }).done( function(msg) {
     $("#register_modal").modal("hide");
     show_bootstrap_alert({text: "Check your email and click through to complete your sign up."});
   }).fail( function(msg) {
     $('#register_new_user input[name="user[email]"]').val(email);
     $('#collect_email_address').hide();
     $('#register_new_user').show();
   });
 });
 
})( jQuery );
