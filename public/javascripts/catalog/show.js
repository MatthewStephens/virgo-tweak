jQuery(function(){
	
	var $=jQuery;
	
	/* Initialize popups for image content */	
  $(".imageCollection a").each(function(index) {
    $(this).colorbox({rel:$(this).attr('data-group'), maxHeight: "100%", photo:true,maxWidth:"95%",scalePhotos:true,opacity:0.7,current:"{current} of {total}"});
  });
	
	/* Fetch item availability */
	(function(){
		var libItemAvail=$('#physicalAvailability');
		if(libItemAvail.length > 0){
			var id = libItemAvail.attr('title');
			$.get('/catalog/' + id + '/status', function(data){
				libItemAvail.hide();
				libItemAvail.html(data);
				if($('#__GBS_Button0 > a').length > 0 && $("#physicalAvailability:contains('only available to Semester At Sea')").length > 0) {
					//Set statusvar in case avail info loads after google, this way we can tell it to change the information.
					$("#physicalAvailability").html("This item is also available in print to Semester at Sea participants");
				}
				if ($('tr.holding').is(':gt(4)')) {
					$('table.holdings').dataTable({
						"bAutoWidth": false,
						"bInfo": false,
						"bLengthChange": false,
						"bPaginate": false,
						"bSort": false,
						"oLanguage": {"sSearch": "<label for='filter_input_field'>Filter Availability</label>"}
					});
					
					var filterInput = $('.dataTables_filter input[type="text"]');	
					var defaultText = "Filter availability by dates, keywords, etc.";
					
					filterInput.attr('id', 'filter_input_field');
					
					filterInput.val(defaultText).addClass('default_filter');
					
					filterInput.focus(function(srcc)
				    {
				        if ( $(this).val() == defaultText )
				        {
				            $(this).removeClass("default_filter");
				            $(this).val("");
				        }
				    });

				    filterInput.blur(function()
				    {
				        if ($(this).val() == "")
				        {
				            $(this).addClass("default_filter");
				            $(this).val(defaultText);
				        }
				    });

				    filterInput.blur();
				
				}
				libItemAvail.show();
				$('.recallAndLeo').css('position', 'absolute');
			});
		}
	})();
	
});
