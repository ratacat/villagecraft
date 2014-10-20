$(document).ready(function(){
    $('.open-reply-form').on('click', function(e){
        e.preventDefault();
        $(this).hide();
        var form = $(this).parent().next('form');
        form.show();
        form.find("input:not([type=hidden]):first").focus();
    });
    
    $(document).on('ajax:success', 'form.comment', function(event, data, status, xhr) {
      var comments_div= $(this).next();
      comments_div.append(data);
      $(this)[0].reset();
    });

    $(document).on('ajax:success', 'form.reply', function(event, data, status, xhr) {
      var replies = $(this).parent().find("ul.replies");
      var reply_link = $(this).parent().find("a.open-reply-form");
      replies.append(data);
      $(this)[0].reset();
      $(this).hide();
      reply_link.show();
    });
    
});
