$(document).ready(function() {

  // Respond to click event on facet category title
  $('.facet-category-label').click(function(){
    var facet_list = $(this).next('ul');
    if(facet_list.hasClass('facet-open')) {
      facet_list.removeClass('facet-open').slideUp();
    } else {
      $('.facet-category ul').removeClass('facet-open');
      facet_list.addClass('facet-open');
      $('.facet-category ul').not('.facet-open').slideUp();
      facet_list.slideDown();
    }    
  });

});
