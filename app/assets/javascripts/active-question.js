$(function() {

    // hide = true;
    // $('.content').on("click", function () {
    //     if (hide) $('.question-border').removeClass('active-border');
    //     hide = true;
    // });

// add and remove .active-border
    $('.content').on('click', '.question-border', function () {

        var self = $(this);

        if (self.hasClass('active')) {
            $('.question-border').removeClass('active-border');
            return false;
        }

        $('.question-border').removeClass('active-border');

        self.toggleClass('active-border');
        hide = false;
    });

});
