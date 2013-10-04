(function( $ ){
 $.fn.vc_modal_register = function( options ) {
   return this.each(function() {
     var $this = $(this),
      options = $.extend({}, $.fn.vc_modal_register.defaults, $this.data(), typeof option == 'object' && option);

     $this.on('click', function() {
       if (typeof options['auto_attend_event'] != 'undefined') {
         $.cookie('auto_attend_event', options['auto_attend_event']);         
       };
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
})( jQuery );
