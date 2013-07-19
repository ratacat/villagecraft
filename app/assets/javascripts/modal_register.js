(function( $ ){
 $.fn.vc_modal_register = function( options ) {
   return this.each(function() {
     var $this = $(this),
      options = $.extend({}, $.fn.vc_modal_register.defaults, $this.data(), typeof option == 'object' && option);

     $this.on('click', function() {
       $('#' + options['modal_id']).modal('show');
     });
   });
 };
 
 $.fn.vc_modal_register.defaults = {
   modal_id: "register_modal"
 };   
 
 $("#modal_register").vc_modal_register();
})( jQuery );
