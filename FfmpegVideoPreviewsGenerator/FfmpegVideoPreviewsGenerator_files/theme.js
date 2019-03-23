// fitvids to make all videos full width http://fitvidsjs.com/  
(function(e){"use strict";e(function(){e(".the-content").fitVids()})})(jQuery);

jQuery(document).ready(function($){
								
/*  Dropdown menu animation
/* ------------------------------------ */
	$('#menu-main-menu ul.sub-menu').hide();
	$('#menu-main-menu li').hover( 
		function() {
			$(this).children('ul.sub-menu').slideDown('fast');
		}, 
		function() {
			$(this).children('ul.sub-menu').hide();
		}
	);	
	
		
	// Table even row class
	$('table tr:even').addClass('even');
	
/*  Sticky Sidebar
/* ------------------------------------
function sticky_relocate() {
    var window_top = $(window).scrollTop();
    var div_top = $('#anchor').offset().top;
    if (window_top > div_top) {
        $('#sidebar').addClass('stick');
    } else {
        $('#sidebar').removeClass('stick');
    }
}

$(function () {
    $(window).scroll(sticky_relocate);
    sticky_relocate();
});
 */

});