$(document).ready(function() {
  $('.toggle-library-maps').click(function() {
    var toggle = $(this);
    var container = toggle.parent().parent();
    if( container.hasClass('open') ) {
      toggle.html('Show');
    } else {
      toggle.html('Hide');
    }
    container.toggleClass('open');
  });
  $('.expand-contract .btn').click(function() {
    var toggle = $(this);
    if( toggle.hasClass('open') ) {
      toggle.html('Show All');
      $('.toggle-library-maps').html('Show');
      $('.library-map-container').removeClass('open');
    } else {
      toggle.html('Hide All');
      $('.toggle-library-maps').html('Hide');
      $('.library-map-container').addClass('open');
    }
    toggle.toggleClass('open');
  });
});
