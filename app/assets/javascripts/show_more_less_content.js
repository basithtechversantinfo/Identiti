$(function() {
    if ($('.show-more-less').length > 6) {
        $('.show-more-less:gt(5)').hide();
        $('.show-more').show();
    }
    else {
        $('.show-more').hide();
    }

    $('.show-more').on('click', function() {
        $('.show-more-less:gt(5)').toggle();
        //change text of show more element just for demonstration purposes to this demo
        $(this).text() === 'Show more' ? $(this).text('Show less') : $(this).text('Show more');
    });
});