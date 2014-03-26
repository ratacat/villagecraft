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

                    $("[id$='_"+key+"']").parents(".form-group").addClass("has-error")
                    $(".help-inline", $("[id$='_"+key+"']").parents(".form-group")).text(val[0]).slideDown()
                    $(".help-inline", $("[id$='_"+key+"']").parents(".form-group")).removeClass("hide")
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
      console.log ($('.review-body-full', $(this).parents('.review-box')).html())
      $('h4#modalMoreReviewAuthor').text($('.review-author', $(this).parents('.review-box')).text());
      $('#more-review-body').html($('.review-body-full', $(this).parents('.review-box')).html());
      $('span#modalMoreReviewTime').text('wrote ' + $('.review-time', $(this).parents('.review-box')).text());
      if($('.review-destroy-link', $(this).parents('.review-box')).length > 0){
        $('.review-destroy').attr('href', $('.review-destroy-link', $(this).parents('.review-box')).attr('href'));
        $('.review-destroy').show();
      }else{
        $('.review-destroy').attr('href','');
        $('.review-destroy').hide();
      }

      $('#modal-more-review').modal('show');

//     probably not needed. remove it later
//      $(".modal").css("position", "fixed");
//      if( $(".modal").height()+100 > $(window).innerHeight()){
//        $(".modal").css("position", "absolute");
//      }

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
      var result = confirm("Are you sure you want to delete the review?");
      if (result==true) {
          var url = $(this).attr("href");
          $.ajax({
            method: "DELETE",
            url: url,
            success: function(){
              $('#modal-more-review').modal('hide');
              window.location = window.location
            },
            error: function(){
              alert('error');
            }
          })
      }
    }
  }, '.review-destroy')


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

                        $("[id$='_"+key+"']").parents(".form-group").addClass("has-error")
                        $(".help-inline", $("[id$='_"+key+"']").parents(".form-group")).text(val[0]).slideDown()
                    })
                }
            });
        }
    }, ".review-element-close");
});
