$(document).ready(function() {
  $('#barred_notice').hide();
  $('.whats-this').show();
  $('.whats-this').colorbox({
    maxHeight: "100%", 
    inline:true,
    maxWidth:"40%",
    opacity:0.7,
    href:"#barred_notice",
    onOpen: function(){$('#barred_notice').show();},
    onCleanup: function(){$('#barred_notice').hide();} });
});
