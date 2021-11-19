// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require rails_sortable
//= require popper
//= require bootstrap
//= require multi-select/jquery.sumoselect
//= require nested_hidden_input_sorting
//= require input_number_validations
//= require cocoon
//= require moment
//= require daterangepicker
//= require active-accordian
//= require active-question
//= require data-confirm-modal
//= require autosize
//= require toster/utoast
//= require jquery.validate
//= require wickedpicker
//= require bootstrap-timepicker.min

// save and exit for wizard
function submitForm() {
	var c_e = ($('#survey_welcome_page').val() == '') || ($('#survey_thank_you_page').val() == '')
	if (c_e == false){
    	$('.save-and-exit').val('save-and-exit');
    	$('.deliver_save_and_exit_button').val('save-and-exit');
	}
	else{
		$('.save-and-exit').val('');
	}
    $('.save-and-exit').click();
    $('.deliver_save_and_exit_button').click();
}


// data-confirm-modal defaults
dataConfirmModal.setDefaults({
    title: '',
    commit: 'Yes',
    cancel: 'No'
});


$(function() {
    autosize($('textarea'));
});

