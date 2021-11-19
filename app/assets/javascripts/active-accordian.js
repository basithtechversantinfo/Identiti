$(function() {

    $('.collapse').on('hidden.bs.collapse', function () {
        $(this).parent().removeClass('active-border');
    });
    $('.collapse').on('shown.bs.collapse', function () {
        $(this).parent().addClass('active-border');
    });

});
