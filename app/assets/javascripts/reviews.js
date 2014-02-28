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
                    return window.location.href = window.location.pathname;
                },
                error: function (response) {
                    return console.log(response);
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
        }
      })
    }
  }, ".plus-rating, .minus-rating")
});
