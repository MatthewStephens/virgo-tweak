jQuery(function(){
	
	var $=jQuery;
	
	$('.tabNavigation li a').click(function(){
		var tab=$(this).attr('href');
		// use the entire href as the selector (the href already has the # symbol)
		$(tab).find('input[@type=text]').focus();
	});
	
	// focus the first .searchIn text input field
	$('.searchInHome:first').focus();
	
	// after selecting a field, put focus on the related text input
	$('#FilterQueryFields').change(function(){$('.searchIn', $(this).parent().parent()).focus();});
	
	var submitSearch = function(e){
		// find the search form (parent of the element submitting the form)
		var sf = $('#MainSearch form', $(e.target).parents());
		var el = $('select option:selected', sf);
		var field = el.val();
		if(field!=''){
			// Change the text input from a query field, 
			// to a query filter field using the selected field as a filter field - *&$@*&^%!@$ what?
			$('.searchIn', sf).attr('name', 'fq[' + field + '][]');
		}
		sf.submit();// submit the form!
	}
	
	// When the button is clicked, execute submitSearch
	$('#MainSearch button').click(submitSearch);
	
	// When the enter key is pressed, while the .searchIn element has focus
	$('.searchIn').keypress(function(e){
		if (e.which == 13){submitSearch(e);}
	});
});