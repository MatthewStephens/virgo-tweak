jQuery(document).ready(function() {
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
});
