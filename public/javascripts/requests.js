$(document).ready(function() {
  // Intercept request link click for popup display.
  // Uses 'live' since link is added via Ajax
  $('#availability').ajaxComplete(function(){
    $('a.initiate-request').each(function() {
      $(this).colorbox({iframe: true, rel:'nofollow', innerHeight: "460px",innerWidth:"606px",opacity:0.7});
    });
  });
});
