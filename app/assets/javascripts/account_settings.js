function showDetails(user_id){
    $.ajax({
        url: 'account_settings/users/'+ user_id+ '/edit',
        type: 'GET',
        dataType: 'json',
        data: {id: user_id},
        success: function(data) {
            $(".user-details-inner").html(data.data);
            $(".user-details-inner").addClass("user-show");
            $(".overlay-u").show();
            $(".usr-name-field").hide();
            $(".usr-email-field").hide();
        },
        error: function(e) {
            //called when there is an error
            //console.log(e.message);
        }
    });
}

function hideUserDetails(){
    $(".user-details-inner").removeClass("user-show");
    $(".overlay-u").hide();
}
function showBilling(){
    $('[href="#menu2"]').tab('show');
}
$(document).ready(function() {
    $(".add-user").on('click', function(e){
        e.preventDefault();
        $.ajax({
            url: 'account_settings/users/new',
            type: 'GET',
            data: {},
            success: function(data) {
                //called when successful
                $('.add-user-wrapper').html(data.data);
                $('#new-user-modal').modal('show')
            },
            error: function(e) {
                //called when there is an error
                //console.log(e.message);
            }
        });
    });

    $('.delete-user').on('click', function(e){
        var id = $(this).data('id');
        var name = $(this).data('name');
        $("#delete_user").attr("href", "/users/"+id)
        $("#delete_user_name").text('"'+name+'"'+"?");
    })

    $('.add-more').on('click', function(e){
        $('#account_setting_billing_emails').val("");
    })
});

// $(function() {
//     // for bootstrap 3 use 'shown.bs.tab', for bootstrap 2 use 'shown' in the next line
//     $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
//         // save the latest tab; use cookies if you like 'em better:
//         localStorage.setItem('lastTab', $(this).attr('href'));
//     });
//
//     // go to the latest tab, if it exists:
//     var lastTab = localStorage.getItem('lastTab');
//     if (lastTab) {
//         $('[href="' + lastTab + '"]').tab('show');
//     }
// });
function showUserNameField(){
    $(".usr-name-field").show();
    $(".user-name-only").hide();
}
function showUserEmailField(){
    $(".usr-email-field").show();
    $(".user-email-only").hide();
}
