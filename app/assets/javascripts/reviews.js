$(function () {
    return $(document).on({
        submit: function (event) {
            var url;
            event.preventDefault();
            url = $('#add_review').attr('href');
            console.log('click');
            console.log($('#add_review'));
            return $.ajax({
                type: 'POST',
                dataType: 'json',
                data: $(this).serialize(),
                url: url,
                success: function (responseJson) {
                    console.log('success');
                    return window.location.href = window.location.pathname;
                },
                error: function () {
                    console.log('errors');
                    return console.log(responseJson);
                }
            });
        }
    }, "#review-form");
});
