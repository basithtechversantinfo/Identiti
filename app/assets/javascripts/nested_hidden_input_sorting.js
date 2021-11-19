$(function() {
    $( '.nested-hidden-sorting' ).sortable({
        stop: function () {
        	$(".hidden-sorting-position").each(function (){ $(this).val(0)})
            var nbElems = 0
            $('.hidden-sorting').each(function(idx) {
                $(this).val(nbElems + idx);
            });
        }
    });
});