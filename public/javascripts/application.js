var debugging = false; // or true
if (typeof console == "undefined" || typeof console.log == "undefined") { 
	var console = { log: function() {} };
} else {
	if (!debugging && typeof console != "undefined") {
		console.log = function() {};
	}
}

jQuery(document).ready(function($) {
	
	$.ajaxSetup({'timeout':20000});
	
	/* private methods */
	
	/*
		Load cover images
		Sample HTML:
		<span class="coverImage">ANYTHING HERE GETS REPLACED BY img TAG</span>
	*/
	
	function loadCoverImages(){
		var isbn = null;
		$('span.coverImage').not('.combined-results span.coverImage').each(function(i,span){
			var el = $(span);
			var doc_id = el.attr('title'); // comma separated list of bib keys
			$.get('/catalog/' + doc_id + '/image_load', function(data){
				var i = $(data);
				el.html(i);
			});
		});
	}
	
	function loadArticles(){
	  if($('#article_results_container').length > 0) {
	    var q = $.getUrlVar('q');
	    var load_url = "";
	    if(q) {
	      load_url = "/articles?q=" + q + "&catalog_select=all";
	    } else {
	      var author = $.getUrlVar('author') || "";
	      var journal = $.getUrlVar('journal') || "";
	      var title = $.getUrlVar('title') || "";
	      var keyword = $.getUrlVar('keyword') || "";
	      load_url = "/articles?search_field=advanced&author=" + author + "&journal=" + journal + "&title=" + title + "&keyword=" + keyword + "&catalog_select=all";
	    }
		  $('#article_results_container').load(load_url, 
		  function() {
		    $('#article_results_container').css('background', '#FFF');
		  });
	  }
	}
	
	function loadFolderArticles(){
	  if($('#folder_article_container').length > 0) {
	      load_url = "/folder/articles";
		  $('#folder_article_container').load(load_url, 
		  function() {
		    $('#folder_article_container').css('background', '#FFF');
		  });
	  }
	}
	
	/*
		Bind the availability links to a handler
		
		SAMPLE CSS:
		.hide{display:none;}
		
		SAMPLE HTML:
		<div class="document" id="DocXXX">
			<div>
				<img src="loader.gif" class="ajaxLoader hide"/>
				<a href="#" class="availability">Check Availability...</a>
			</div>
		</div>
	*/
	
	function makeBookmarkLinks(){
		$('.addUserBookmarkForm .submitForm').click(function(e){
			e.preventDefault();
			var el=$(this);
			el.parent().html('This item is in <a href="/bookmarks">My Favorites</a>');
			el.parent().ajaxSubmit();
		});
	}
	
	function makeFolderLinks(){
	  // Submit form to add new marked item on link click
		$('.addFolderForm .submitForm').live('click', function(){	
		  
			var options = { 
			  dataType: 'json',
        beforeSubmit:  changeStar,  // pre-submit callback 
        success:       checkStarResponse  // post-submit callback 
      };
			
      var target = $(this).parent();
			target.ajaxSubmit(options);
						
      // Pre-submit callback function
      function changeStar(formData, jqForm, options) { 
        target.children('.submitForm').addClass('saving-star');
        return true; 
      } 

      // Post-submit callback function
      function checkStarResponse(responseText, statusText, xhr, $form)  { 
        // Retrieve the item id (like u5333028) from a hidden field 
        // (id for catalog, article_id for articles)
        if ( target.children("input[name='id']").length ) {
          var elId = target.children("input[name='id']").val();
        } else {
          var elId = target.children("input[name='article_id']").val();
        }       
        
        // Since the ajax submit call has succeeded, 
        // replace the star form with a delete link.
        target.closest('.folder_container').html('<a href="/folder/' + elId + '" class="deleteFolder_link">Remove Star</a>');

        // check to see if star count has reached max
        checkStarCount(responseText.length);
      }

      return false;

		});
		
		$('.deleteFolder_link, .deleteFolderArticle_link').live('click', function(){
      var el = $(this);
      // Retrieve the item ID (after "folder/" in the link URL)
      var elId = $(this).attr('href').substring(8);
      
      el.closest('.folder_container').html('<form action="/folder" class="addFolderForm" method="post" name="folder' + elId +'"><input id="id" name="id" type="hidden" value="' + elId + '"><a href="/folder" class="submitForm">Add Star</a><input class="hide" id="submitFolderForm_' + elId + '" name="commit" type="submit" value="Add Star"></form>');
            
      // POST using Rails' faux DELETE method, then create a new
      // "add to marked list" form in place of the old delete link
		  $.post(el.attr('href'), {_method: 'delete'});
        
      return false;
		});
	}

  function checkStarCount(star_count){
    // Show a notice if the starred item list is over 100 items
    if(star_count >= 100) {
      $(document).colorbox({html: '<div id="folder_full_notice">You may only save up to 100 items in your starred item list.  Please <a href="/folder">view and export</a> any items you wish to preserve then <a class="clear_all close-notice" href="/folder/clear">clear the list</a> to add more items.</div>', open: true, title: 'Starred Item List Full', height: '40%', width: '40%'});
    }
  }

  // Close colorbox when the user clicks certain links
  $('.close-notice').live('click', function(){
    $(document).colorbox.close();  
  });
	
	function makeActionList(){	  
	  $('.action_list').hover(function() {
      $('.list_body').show();
	  }, function() {
      $('.list_body').hide();
	  });
	}
	
	function getMarkedIds(){
	  var markedIds = new Array();
	  var markedEls = $('.deleteFolder_link');
	  markedEls.each(function(index) {
      markedIds[index] = $(this).attr('href').substring(8);
	  });
	  return markedIds;
	}
	
	function getUnmarkedIds() {
	  var unmarkedIds = new Array();
	  var unmarkedEls = $('.addFolderForm .submitForm');
	  unmarkedEls.each(function(index) {
      if ( $(this).siblings("input[name='id']").length ) {
        unmarkedIds[index] = $(this).siblings("input[name='id']").val();
      } else {
        unmarkedIds[index] = $(this).siblings("input[name='article_id']").val();
      }
      
	  });
	  return unmarkedIds;
	}
	
	
	// Responds by adding all items on the page to the marked list (if they're
	// not already there).
	function allowSelectAll(){
	  $('a.select_all').click(function() {	    
      var selectIds = getUnmarkedIds();
      if($(selectIds).length > 0) {

        var select_link = $(this);
        var selectData = $('body.articles-page').length ? { 'article_id[]' : selectIds } : { 'id[]': selectIds };
                
        $.ajax({
          url: "/folder",
          type: "POST",
          dataType: "json",
          data: selectData,
          beforeSend: function(jqXHR, settings){
            $('.addFolderForm .submitForm').addClass('saving-star');
            select_link.addClass('link_disabled');
          },
          success: function(data, textStatus, jqXHR) {
            $('.addFolderForm .submitForm').each(function(index) {
              var elId = $(this).siblings("input[name='id']").val();
              $(this).closest('.folder_container').html('<a href="/folder/' + elId + '" class="deleteFolder_link">Remove Star</a>');
            });
            checkStarCount(data.length);
            select_link.removeClass('link_disabled');
          }
        });        
      }
      
      return false;
	  });
	}
	
	// Responds by emptying the Marked List
	function allowClearAll(){
	  $('a.clear_all').live('click', function(e) {

      var clearIds = getMarkedIds();
      
      if($(clearIds).length > 0) {

        $(this).addClass('link_disabled');
        
        $('.deleteFolder_link, .deleteFolderArticle_link').each(function(index) {
          var el=$(this);
    			var elId = $(this).attr('href').substring(8);      			
  		    el.closest('.folder_container').html('<form action="/folder" class="addFolderForm" method="post" name="folder' + elId +'"><input id="id" name="id" type="hidden" value="' + elId + '"><a href="/folder" class="submitForm">Add Star</a><input class="hide" id="submitFolderForm_' + elId + '" name="commit" type="submit" value="Add Star"></form>');  		    
        });
        
        $('a.clear_all').removeClass('link_disabled');
        
        // POST using Rails' faux DELETE method, then create a new
        // "add to marked list" form in place of the old delete link      
        $.post('/folder/clear', {_method: 'delete'});
                
      }
          
      return false;
	  });
	}
	
	//Make sure more facet lists loaded in this dialog have
    //ajaxy behavior added to next/prev/sort     
	
    function addBehaviorToMoreFacetDialog(dialog) {
      var dialog = $(dialog);    
      
      // Make next/prev/sort links load ajaxy
      dialog.find("a.next_page, a.prev_page, a.sort_change").click( function() {     
          $("body").css("cursor", "progress");
          dialog.find("ul.facet_extended_list").animate({opacity: 0});
          dialog.load( this.href, 
              function() {
                addBehaviorToMoreFacetDialog(dialog);
                $("body").css("cursor", "auto");
                // Remove first header from loaded content, and make it a dialog
                // title instead
                var heading = dialog.find("h1, h2, h3, h4, h5, h6").eq(0).remove();
                if (heading.size() > 0 ) {
                  dialog.dialog("option", "title", heading.text());
                }
              }
          );
          //don't follow original href
          return false;
      });
    }

    function positionDialog(dialog) {
      dialog = $(dialog);
      
      dialog.dialog("option", "height", 641);
      dialog.dialog("option", "width", 804);
      dialog.dialog("option", "position", ['center', 75]);
      
      dialog.dialog("open").dialog("moveToTop");

			// scroll to the dialog (for IE) sans some 50px padding
			window.scrollTo(0, dialog.offset().top - 70);
			
    }
	
	// Submit per page form when the user selects a value
	function changePerPage(){
	 	$('#PerPageSelector').change(function(){
      $('#PerPageContainer form').submit();
    });
    $('#SortSelector').change(function(){
      $('#SortFormContainer form').submit();
    }); 
	}
	
	function addChatLink(){
	  $('.catalog-page .no-items-ask').click(function() {
      $('.libraryh3lp-container').show();
      return false;
	  });
	}
  
  function addSearchContext() {
    $('a[data-counter]').click(function(event) {
      var f = document.createElement('form'); f.style.display = 'none'; 
      this.parentNode.appendChild(f); 
      f.method = 'POST'; 
      f.action = $(this).attr('href');
      if(event.metaKey || event.ctrlKey){f.target = '_blank';};
      var d = document.createElement('input'); d.setAttribute('type', 'hidden'); 
      d.setAttribute('name', 'counter'); d.setAttribute('value', $(this).attr('data-counter')); f.appendChild(d);
      var m = document.createElement('input'); m.setAttribute('type', 'hidden'); 
      m.setAttribute('name', '_method'); m.setAttribute('value', 'put'); f.appendChild(m);
      var m = document.createElement('input'); m.setAttribute('type', 'hidden'); 
      m.setAttribute('name', $('meta[name="csrf-param"]').attr('content')); m.setAttribute('value', $('meta[name="csrf-token"]').attr('content')); f.appendChild(m);

      f.submit();
        
      return false;
    });

  };
		
	function init(){
		loadCoverImages();		
		makeBookmarkLinks();
		makeFolderLinks();
		makeActionList();
		allowSelectAll();
		allowClearAll();
		loadArticles();
		loadFolderArticles();
		changePerPage();
		addChatLink();
    addSearchContext();
	}
	
	$.extend({
	  getUrlVars: function(){
	    var vars = [], hash;
	    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
	    for(var i = 0; i < hashes.length; i++)
	    {
	      hash = hashes[i].split('=');
	      vars.push(hash[0]);
	      vars[hash[0]] = hash[1];
	    }
	    return vars;
	  },
	  getUrlVar: function(name){
	    return $.getUrlVars()[name];
	  }
	});
	
	init();
	
	// send along tokens so that session doesn't go poof
	$(document).ajaxSend(function(e, xhr, options) {
	  var token = $("meta[name='csrf-token']").attr("content");
	  xhr.setRequestHeader("X-CSRF-Token", token);
	});

});
