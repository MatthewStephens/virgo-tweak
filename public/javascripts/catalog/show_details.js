// Show and hide extra metadata fields to shorten very long records.
jQuery(document).ready(function() {
	
	if ($('#details dt').is(':gt(3)')) {
		// Hiding any more than five details (0-3 are visible)
		$('#details dt:gt(3):not(.show_detail), #details dt:gt(3) ~ dd:not(.show_detail)').hide();
		// Create the see more / see less text
		$('#details').append('<span class="show_details">See more</span>');
		// Respond to clicks on see more / see less
		$('.show_details').click(function() {
			// Toggle the visibility of extra fields (slide up or down)
			$('#details dt:gt(3):not(.show_detail), #details dt:gt(3) ~ dd:not(.show_detail)').slideToggle();
			$(this).toggleClass('.open');
			// If the text is currently "See more" change it to "See less" and vice versa
			var text = $(this).html();
			$(this).html(text == "See more" ? "See less<span class='always_show'><a href='?full_view=true'>Always show full record</a></span>" : "See more");
		});
	}
});