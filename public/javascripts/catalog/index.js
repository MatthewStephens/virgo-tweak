$(document).ready(function() {
  
  // Create facet popups
  $("a.more_facets_link, a.lightboxLink").each(function() {
    // Load facet list in iframe for the ability to follow links in the popup
    $(this).colorbox({iframe: true, rel:'nofollow', innerHeight: "460px",innerWidth:"606px",opacity:0.7});
    $(this).attr("href", $(this).attr("href") + "&complete=true");                   
  });	
	    
  // Create availability popups
  $(".availability a").each(function() {  
    var id = $(this).parents('.document').attr('id').replace(/^Doc/, '');
  	var url = '/catalog/' + id + '/status';
  
    $(this).colorbox({href: url, rel:'nofollow', opacity:0.7});                     
  });
	      
  // Show and hide search help on user click
  $('.which-search').click(function() {
    $('.which-search-help').slideToggle();
    return false;
  });
  
  // Change search box placeholder text based on user radio input selection
  $('input[name=catalog_select]').change(function() {
    var label = $(this).val();
    var search_box = $('#SI');
    switch(label) {
      case 'catalog':
        search_box.attr('placeholder', 'Search for books, maps, DVDs, and other catalog materials.');
        break;
      case 'articles':
        search_box.attr('placeholder', 'Search for articles from subscription journal databases.');
        break;
      default:
        search_box.attr('placeholder', 'Search for books, articles, digital materials, and more.');
    }
  });
  
  // Add lightbox to digital images
  // Uses data-group for HTML5 validity
  $(".imageCollection a").each(function(index) {
    $(this).colorbox({rel:$(this).attr('data-group'), maxHeight: "100%", photo:true,maxWidth:"95%",scalePhotos:true,opacity:0.7,current:"{current} of {total}"});
  });

	$('.single-copy').each(function(index) {
		var item_availability = $(this);
		var item_id = item_availability.parent().attr('id').split('availability_')[1];
		item_availability.load('/catalog/' + item_id + '/brief_availability');		
	});

	

});
