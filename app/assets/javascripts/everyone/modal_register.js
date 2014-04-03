(function( $ ){
 $.fn.vc_modal_register = function( options ) {
   return this.each(function() {
     var $this = $(this),
      options = $.extend({}, $.fn.vc_modal_register.defaults, $this.data(), typeof option == 'object' && option);
     $this.on('click', function(event) {
       console.log(options);
       event.preventDefault();
       if (typeof options['autoAttendEvent'] != 'undefined') {
         $.cookie('auto_attend_event', options['autoAttendEvent'], {path: '/' });
       };
       $('#' + options['modalId'] + ' span.event_title').html(options['autoAttendEventTitle']);
       $('#' + options['modalId']).modal('show');
     });
   });
 };
 
 $.fn.vc_modal_register.defaults = {
   modalId: "register_modal"
 };   
 
 $("[data-toggle-modal-registration]").vc_modal_register();
 
 $("#register_modal").on('shown', function() {
   $('#attend_by_email_form input[name="user[email]"]:first').focus();
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
     $('#register_new_user input[name="user[name]"]:first').focus();
   });
 });
 
})( jQuery );
