$(document).ready(function() {
  
  /* =loadViewer
   *
   * Given a pid (string) as an argument, loadViewer removes the 
   * image layer if it exists, retrieves metadata for a given 
   * image, sets appropriate OpenLayers options, adds a new image
   * layer to the 'map,' and centers and zooms the image.
  -------------------------------------------------------------- */  
  function loadViewer(pid){
    
    // remove the image layer if it's on the map
    if(map.getLayersByName('JP2k').length) {
      map.removeLayer(OUlayer);
    }
    
  	// Set metadata and image URLs
    var metadataUrl = "/fedora_metadata/" + PageTurner.id + "/" + pid + ".json";
    // Don't actually need this info, but Layer.OpenURL wants it for now
    var imageUrl = PageTurner.repo + "/get/" + pid + "/content";
    var djatokaUrl = PageTurner.repo + "/objects/" + pid + "/methods/djatoka:jp2SDef/getRegion?";
    var tileSize = new OpenLayers.Size(512,512);
  	// Create OpenLayers layer
    OUlayer = new OpenLayers.Layer.OpenURL( "JP2k",
      djatokaUrl, {layername: 'basic', format:'image/jpeg', rft_id: imageUrl, metadataUrl: metadataUrl, tileSize: tileSize, buffer: 0} );

  	// Retrieve options from metadata and set
    var metadata = OUlayer.getImageMetadata();
    var resolutions = OUlayer.getResolutions();
    var maxExtent = new OpenLayers.Bounds(0, 0, metadata.width, metadata.height);
    
    var options = {
      resolutions: resolutions, 
      maxExtent: maxExtent};

  	// Create map, add layer, and center on image    
    map.setOptions(options);
    map.addLayer(OUlayer);
    centerZoom(map, metadata); 
    
  }
  
  /* =centerZoom
   *
   * Center and zoom the image, using permalink values if provided
  -------------------------------------------------------------- */
  
  function centerZoom(map, meta) {
    // Use permalink values if present.  Otherwise use center.
    var max = map.getMaxExtent();
    var lon = PageTurner.x ? PageTurner.x : (max.getWidth() / 2);
    var lat = PageTurner.y ? PageTurner.y : (max.getHeight() / 2);
    
    // Only use the permalink x/y values once (not on every page turn)
    PageTurner.x = null;
    PageTurner.y = null;
    
    map.setCenter(new OpenLayers.LonLat(lon, lat));
    
    if(PageTurner.z) {
      // Zoom to set extent if included in permalink, 
      // then forget zoom value unless Zoom Lock is on.
      map.zoomTo(PageTurner.z);
      if(PageTurner.lock != "true") {
        PageTurner.z = null;
      }
    } else {
      map.zoomToMaxExtent();
    }
  }
  
  /* =Thumbnail clicking
   *
   * Handles clicks on thumbnail images.  Adds a class to
   * indicate the selected page, and loads the selected new image. 
  -------------------------------------------------------------- */
  
  $('.page_thumb').click(function() {
    
    $('.page_thumb').removeClass('thumb_select');
    $(this).addClass('thumb_select');
    
    var pid = $(this).attr('id');  
    loadViewer(pid);
  });
  
  /* =Dropdown selection
   *
   * Handles selection of page from dropdown menu (<select>).
  -------------------------------------------------------------- */
  
  $('.page_turner_select select').change(function() {
    
    var pid = $(this).val();
    
    // escape the colon in our selector
    var selected = $('#' + pid.replace(/\:/ig, "\\:"));
        
    // page_thumb class only on selected page thumbnail
    $('.page_thumb').removeClass('thumb_select');
    $(selected).addClass('thumb_select');
      
    loadViewer(pid);
    
    $('.page_thumbs').scrollTop( $('.page_thumbs').scrollTop() + $('.thumb_select').position().top - 200 );
        
  });
  
  /* =Previous and Next links
  -------------------------------------------------------------- */
  // NEXT
  $('.page_turner_next').click(function() {
    
    // retrieve next page's pid
    var pid = $('.thumb_select').next().attr('id');
    
    // escape the colon in our selector
    var selected = $('#' + pid.replace(/\:/ig, "\\:"));
        
    // page_thumb class only on selected page thumbnail
    $('.page_thumb').removeClass('thumb_select');
    $(selected).addClass('thumb_select');
      
    loadViewer(pid);
    
    $('.page_thumbs').scrollTop( $('.page_thumbs').scrollTop() + $('.thumb_select').position().top - 200 );
  });
  
  // PREVIOUS
  $('.page_turner_prev').click(function() {
    
    // retrieve next page's pid
    var pid = $('.thumb_select').prev().attr('id');
    
    // escape the colon in our selector
    var selected = $('#' + pid.replace(/\:/ig, "\\:"));
        
    // page_thumb class only on selected page thumbnail
    $('.page_thumb').removeClass('thumb_select');
    $(selected).addClass('thumb_select');
      
    loadViewer(pid);
    
    $('.page_thumbs').scrollTop( $('.page_thumbs').scrollTop() + $('.thumb_select').position().top - 200 );
  });
  
  /* =Show/Hide Panels
  -------------------------------------------------------------- */
  
  $('#hide_header').click(function() {
    var button = $(this);
    $('.page_turner_title').toggle('slide', function(){
      $('#container').toggleClass('title-closed');
      if( $('#container.title-closed').length ) {
        button.html("Show");
      } else {
        button.html("Hide");
      }
      $(window).resize();
    });
    return false;
  });
  $('#hide_thumbs').click(function() {
    var button = $(this);
    $('.page_thumbs').toggle('slide', function(){
      $('#container').toggleClass('thumbs-closed');
      if( $('#container.thumbs-closed').length ) {
        button.html("Show");
      } else {
        button.html("Hide");
      }
      $(window).resize();
    });
    return false;
  });
  
  /* =Zoom Lock
  -------------------------------------------------------------- */

  $('#lock_zoom.lock-inactive').live('click', function() {
    var lock_button = $(this);
    lock_button.toggleClass('lock-active').toggleClass('lock-inactive');
    lock_button.html("Unset Default Zoom");
    PageTurner.lock = 'true';
    PageTurner.z = map.getZoom() ? map.getZoom() : 0;
  });
  
  $('#lock_zoom.lock-active').live('click', function() {
    var lock_button = $(this);
    lock_button.toggleClass('lock-active').toggleClass('lock-inactive');
    lock_button.html("Set Default Zoom");
    PageTurner.lock = 'false';
    PageTurner.z = null;
  });
  
  
  /* =Window resize
   *
   * Changes height of thumbnail list and viewer to match viewport
   * minus the header.
  -------------------------------------------------------------- */
  $(window).resize(function() {
    $('.page_container').css('height', $(window).height() - ( $('.page_turner_head').outerHeight(true) + 1 ) );
    $('.page_container').css('min-height', '600 !important' );
	}); 
	
	// Timing issues were causing off-center images, so we now trigger
	// a resize "reset" after Ajax requests complete.
	$(document).ajaxComplete(function(){
	  $(window).trigger('resize');
	});
	
	/* =loadThumb
	 *
	 * Loads the 125x125 thumbnail for a given page image container
	-------------------------------------------------------------- */
	function loadThumb(el) {
	  var elPid = el.attr("id");
	  var imgUrl = PageTurner.repo + "/get/" + elPid + "/djatoka:jp2SDef/getRegion?scale=125,125";
	  var caption = el.children('.page_title').text();
	  var elImg = el.children('.jp2kPreview').html('<img src="' + imgUrl + '" alt="' + caption + '" />');
	}
	
	/* =Load additional thumbnails on scroll
	-------------------------------------------------------------- */
	
	var scrollTimer;
	
  $('.page_thumbs').scroll(function() {
    if(scrollTimer) {
      clearTimeout(scrollTimer);
      scrollTimer = null;
    }
    scrollTimer = setTimeout(function(){
      var thumbs = $('.page_thumbs');
      var listHeight = thumbs.height();
      $('li.page_thumb').each(function(index) {
        var el = $(this);
        if(el.find('.jp2kPreview .page_default').length > 0) {
          var pos = el.position();
          if(pos.top > 0 && pos.top <  listHeight) {
            loadThumb(el);
          } 
        }
      });
    }, 500);
  });
  
  /* =updateLink
   *
   * Constructs a permalink to the current x, y, and zoom based
   * on current map info.  Responds to map-changing events.
  -------------------------------------------------------------- */
  function updateLink(event){    
    var base = window.location.href.split('?')[0];    
    var zoom = map.getZoom() ? map.getZoom() : 0;
    var lock = PageTurner.lock == 'true' ? 'true' : 'false';
    
    var mapCenter = map.getCenter();
    var lon = mapCenter ? mapCenter.lon : 0;
    var lat = mapCenter ? mapCenter.lat : 0;
    
    var page = $('.thumb_select').attr('id');
    
    pageLink =  base + "?x=" + lon + "&y=" + lat + "&z=" + zoom + "&lock=" + lock + "&page=" + page;  
    
    $('#page_permalink').attr('href', pageLink);
  }
  
  
	
  
  // =INIT
  
  // MapBox control icons
  OpenLayers.ImgPath = "http://js.mapbox.com/theme/dark/";
  
  // Create map in #page_viewer and initialize layer variable
  var map = new OpenLayers.Map('page_viewer', {
    eventListeners: {
      "moveend": updateLink,
      "zoomend": updateLink,
      "changelayer": updateLink,
      "changebaselayer": updateLink
    }
  });
  
	var OUlayer;
	
	// Force thumbnail list and viewer to take up available height.
	$(window).trigger('resize');
	
	// Load initial page in viewer
  loadViewer(PageTurner.pid);
  
  $('li.page_thumb:lt(8)').each(function(index) {
    loadThumb($(this));
  });
  
  // Scroll to first page in thumbnail list
  $('.page_thumbs').scrollTop( $('.thumb_select').position().top - 200 );
  
  // Add map touch and div scrolling behavior for iOS devices
  if(navigator.userAgent.match(/iP(ad|od|hone)/i)) {
    var scroller = new iScroll('page_viewer');
  }

});