(function (define) {
    define(['jquery'], function ($) {
        var utoast_id = 0;
        return (function () {


            var utoast = {
                error: error,
                success: success,
                error_medium: error_medium,
                error_large: error_large,
                warning: warning,
                learning:learning,
                summary:summary
            };


            return utoast;



            function success(message, action = "#", action_title = "Action", duration = 5000) {
                var html = '<div id="utoast-' + utoast_id + '" class="utoast utoast-success utoast-wide">';
                html = html + '<div class="utoast-icon">';
                html = html + '<i class="fas fa-check"></i>';
                html = html + '</div>'
                html = html + '<div class="utoast-content">';
                html = html + '<div class="utoast-message">' + message + '</div>';
                // html = html + '<div class="utoast-action"><a href="' + action + '">' + action_title + '</a></div></div></div>';

                notify(html,duration);


            }

            function warning(message, action = "#", action_title = "Action", duration = 5000) {
                var html = '<div id="utoast-' + utoast_id + '" class="utoast utoast-warning utoast-wide">';
                html = html + '<div class="utoast-icon">';
                html = html + '<i class="fas fa-exclamation-circle"></i>';
                html = html + '</div>'
                html = html + '<div class="utoast-content">';
                html = html + '<div class="utoast-message">' + message + '</div>';
                // html = html + '<div class="utoast-action"><a href="' + action + '">' + action_title + '</a></div></div></div>';

                notify(html,duration);


            }

            function error(message, action = "#", action_title = "Action", duration = 5000) {
                var html = '<div id="utoast-' + utoast_id + '" class="utoast utoast-error utoast-wide">';
                html = html + '<div class="utoast-icon">';
                html = html + '<i class="fas fa-exclamation-circle"></i>';
                html = html + '</div>'
                html = html + '<div class="utoast-content">';
                html = html + '<div class="utoast-message">' + message + '</div>';
                // html = html + '<div class="utoast-action"><a href="' + action + '">' + action_title + '</a></div></div></div>';

                notify(html,duration);


            }

            function error_medium(message, duration = 5000) {
                var html = '<div id="utoast-' + utoast_id + '" class="utoast utoast-error utoast-medium">';
                html = html + '<div class="utoast-icon">';
                html = html + '<i class="fas fa-exclamation-circle"></i>';
                html = html + '</div>'
                html = html + '<div class="utoast-content">';
                html = html + '<div class="utoast-message">' + message + '</div>';
                html = html + '</div></div>';

                notify(html, duration);

            }
            function error_large(title,message, duration = 5000) {
                var html = '<div id="utoast-' + utoast_id + '" class="utoast utoast-error utoast-large">';
                html = html + '<div class="utoast-icon">';
                html = html + '<i class="fas fa-exclamation-circle"></i>';
                html = html + '</div>'
                html = html + '<div class="utoast-content">';
                
                html = html + '<span class="utoast-close">&times;</span>'
                html = html + '<div class="utoast-message"><div class="utoast-title">'+title+'</div>';
                
                html = html + message + '</div>';
                html = html + '<div class="utoast-connection"><i class="fa fa-globe"></i></div>';
                html = html + '</div></div>';

                notify(html, duration);

            }

            function learning(title,message, action="#", action_title="Ok", duration = 5000) {
                var html ='<div id="utoast-' + utoast_id + '" class="utoast utoast-learning">';

                html = html + '<div class="utoast-icon">';
                html = html + '<img src="Attitude.png" alt="">';
                html = html + '</div>';
                html = html + '<div class="utoast-content">';
                html = html + '<div class="utoast-message">';
                html = html + '<div class="utoast-title">'+title+'</div>';
                html = html + message;
                html = html + '</div>';
                html = html + '<div class="utoast-action"><a href="'+action+'">'+action_title+'</a></div>';
                html = html + '</div>';
                html = html + '</div>';

                notify(html, duration);
            }
            function summary(title,message, duration = 5000) {
                var html ='<div id="utoast-' + utoast_id + '" class="utoast utoast-summary">';
                html = html + '<div class="utoast-content">';
                html = html + '<div class="utoast-title">'+title+'</div>';
                html = html + '<div class="utoast-detail">'+message+'</div>';
                html = html + '</div>';
                html = html + '</div>';

                notify(html, duration);
            }



            function notify(html, duration, toasted){
                
                var clear = true;
                var utoasted = '#utoast-' + utoast_id;
                timeOut();
                jQuery('.utoast-container').append(html);
                jQuery(utoasted).hide().fadeIn('slow');
                function timeOut() {
                    utoast_id++;
                    
                    var Int = setTimeout(function () {
                        // jQuery(utoasted).removeClass('show');

                        if (clear) {
                            jQuery(utoasted).fadeOut('slow', function () {
                                jQuery(this).remove();
                            });
                        } else {
                            console.log(clear);
                            clearTimeout(Int);
                        }
                    }, duration);
                }


                jQuery(utoasted).mouseover(function () {


                    clear = false;

                });

                jQuery(utoasted).mouseout(function () {
                    clear = true;
                    timeOut()
                });
            }


        })();
    });
}(typeof define === 'function' && define.amd ? define : function (deps, factory) {
    if (typeof module !== 'undefined' && module.exports) { //Node
        module.exports = factory(require('jquery'));
    } else {
        window.utoast = factory(window.jQuery);
    }
}));