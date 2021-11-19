(function ($) {
	"use strict";

    jQuery(document).ready(function($){
        
        
          //===== Prealoder
            $(window).on('load', function(event) {
            $('.proloader').delay(500).fadeOut(500);
            });  
        
        
        

        $(document).ready(function() {
            // $('select').niceSelect();
          });

          $(".add-scrween").click(function(){

          });


          

        
         
        
          
       
        
          // Hamburger-menu
            $('.hamburger-menu').on('click', function(){
                $('.hamburger-menu .line-top, .step-item-bar').toggleClass('current');
                $('.hamburger-menu .line-center').toggleClass('current');
                $('.hamburger-menu .line-bottom').toggleClass('current');
            });
    
      
    });


    jQuery(window).load(function(){


    });


}(jQuery));	