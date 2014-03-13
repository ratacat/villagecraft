$(function () {
    $(document).on({
        click: function (event) {
            var url;
            event.preventDefault();
            url = $('#add_review').attr('href');
            $.ajax({
                type: 'POST',
                dataType: 'json',
                data: $("#review-form").serialize(),
                url: url,
                success: function (responseJson) {
                    window.location.href = window.location.pathname;
                },
                error: function (response) {
                    response.responseJSON

                  $('.error .help-inline').each(function(){
                    if($(this).is(":visible")){
                      $(this).text('');
                      $(this).slideUp();
                    }
                  })
                  $('.error').removeClass('error');
                  $.each(response.responseJSON, function(key, val){

                    $("[id$='_"+key+"']").parents(".control-group").addClass("error")
                    $(".help-inline", $("[id$='_"+key+"']").parents(".control-group")).text(val[0]).slideDown()
                  })
                }
            });
        }
    }, ".create_review");

  $(document).on({
    click: function(event){
      event.preventDefault();
      var url = $(this).attr('href');
      var that = $(this);
      $.ajax({
        type: 'POST',
        dataType: 'json',
        url: url,
        success: function (responseJson){
          $('.review-rating-value',that.parents('.review-rating')).html(responseJson.rating)
        },
        error: function (response){
          console.log(response)
          alert(response.responseText)
        }
      })
    }
  }, ".plus-rating, .minus-rating");

  $(document).on({
    click: function(event){
      event.preventDefault();
      $('h4#modalMoreReviewAuthor').text($('.review-author', $(this).parents('.review-box')).text());
      $('#more-review-body').text($('.review-body', $(this).parents('.review-box')).data('body'));
      $('span#modalMoreReviewTime').text('wrote ' + $('.review-time', $(this).parents('.review-box')).text());
      $('#modal-more-review').modal().show();
      $(".modal").css("position", "fixed");
      if( $(".modal").height()+100 > $(window).innerHeight()){
        $(".modal").css("position", "absolute");
      }

    }
  }, '.review-more')
  $(document).on({
    click: function(event){
        event.preventDefault();
        $('#add-review-user').slideDown();
    }
  }, '#add-review-user-button')
  $(document).on({
    click: function(event){
        event.preventDefault();
        $('#add-review-user').slideUp();
    }
  }, '#close-add-review-user-button');

  $('.review-list').hover(
      function() {
        $('.review-element-close',$(this)).show();
      }, function() {
        $('.review-element-close',$(this)).hide();
      });

    $(document).on({
        click: function (event) {
            var url;
            event.preventDefault();
            id =
            url = $('#delete_review').attr('href');

            $.ajax({
                type: 'DELETE',
                dataType: 'json',
                url: url,
                success: function (responseJson) {
                    window.location.href = window.location.pathname;
                },
                error: function (response) {
                    response.responseJSON

                    $('.error .help-inline').each(function(){
                        if($(this).is(":visible")){
                            $(this).text('');
                            $(this).slideUp();
                        }
                    })
                    $('.error').removeClass('error');
                    $.each(response.responseJSON, function(key, val){

                        $("[id$='_"+key+"']").parents(".control-group").addClass("error")
                        $(".help-inline", $("[id$='_"+key+"']").parents(".control-group")).text(val[0]).slideDown()
                    })
                }
            });
        }
    }, ".review-element-close");
});
