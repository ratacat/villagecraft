var form;
$(document).ready(function(){
    $('.open-reply-form').on('click', function(e){
        e.preventDefault();
        $(this).hide();
        form = $(this).parent().next('form');
        form.show();
        form.find("input:not([type=hidden]):first").focus();
    });
});
