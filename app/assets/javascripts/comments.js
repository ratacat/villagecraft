// var Comment = {
//   init: function() {
//     $(".comment").bind('click', $.proxy(this.handleClick, this));
//   },
//   handleClick: function(evt) {
//     var form = $('#new_comment').clone();
//     var target = $(evt.target);
//     var isFormAvailable = $("#new_comment", target).length > 0;
//     if(!isFormAvailable) {
//         $(evt.target).append(form);
//     }
//   }   
// };

// $(function() {
//     Comment.init();
// });

$(document).ready(function(){
    $('.reply-comment').on('click', function(e){
        e.preventDefault();
        $(this).next('.form').show();
    });
});