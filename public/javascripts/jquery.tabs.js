/* TAB SOURCE: http://jqueryfordesigners.com/demo/tabs.html */
jQuery(function () {
	var tabContainers = jQuery('div.tabs > div');
	tabContainers.hide().filter(':first').show();
	jQuery('div.tabs ul.tabNavigation a').click(function () {
		tabContainers.hide();
		tabContainers.filter(this.hash).show();
		jQuery('div.tabs ul.tabNavigation a').removeClass('selected');
		jQuery(this).addClass('selected');
		return false;
	}).filter(':first').click();
});