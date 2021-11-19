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
//= require account_settings
//= require cocoon
//= require moment
//= require daterangepicker
//= require data-confirm-modal
//= require toster/utoast
//= require autosize
//= require bootstrap-switch

// data-confirm-modal defaults
dataConfirmModal.setDefaults({
    title: '',
    commit: 'Yes',
    cancel: 'No'
});


$(function() {
    autosize($('textarea'));
});

