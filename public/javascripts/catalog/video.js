$(document).ready(function() {
  
  var info_hide = true;
  
  $('#results .title').hoverIntent({
    over: showVideoInfo,
    timeout: 800,
    out: hideVideoInfo,
    interval: 500,
    sensitivity: 6
  });
  
  function showVideoInfo(e) {
    var info_bubble = $(this).siblings('.more_info');
    
    // Calculating video info bubble position based on element position
    // and mouse position, plus a little offset.
    var pos = $(this).position();
    var mouse_pos_top = e.pageY - $(this).offset().top + pos.top - 30;
    var mouse_pos_left = e.pageX - $(this).offset().left + pos.left + 10;
    
    // Position bubble
    info_bubble.css('top', mouse_pos_top).css('left', mouse_pos_left);    
    // IE z-index bugfix: parent z-index must be higher than bubble and other divs
    info_bubble.parent().css('z-index', 9999);    
    // Reveal bubble
    info_bubble.show();
  }
  
  function hideVideoInfo(e) {
    if(info_hide) {
      var info_bubble = $(this).siblings('.more_info');
      // Return parent's z-index to default value
      info_bubble.parent().css('z-index', 10);
      info_bubble.hide();
    }
  }
  
  // Timer to keep info bubble open after mouseout  
  var info_timer;
  
  // keep bubble visible if hovering and hide after a short delay
  // after hover ends
  $('.more_info').hover(function() {
    //mouseenter
    info_hide = false;
    if(info_timer) {
      clearTimeout(info_timer);
      info_timer = null;
    }      
  }, function() {
    //mouseleave
    info_hide = true;
    var info_bubble = $(this);
    info_timer = setTimeout(function(){
      info_bubble.parent().css('z-index', 10);
      info_bubble.hide();
    }, 800);
  });
  
  
});
