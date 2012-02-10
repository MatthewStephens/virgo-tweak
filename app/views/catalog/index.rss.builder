xml.instruct! :xml, :version=>"1.0"
xml.rss(:version=>"2.0"){
	
	xml.channel{
		xml.title('VIRGO Search Results')
    params.delete :controller
		xml.link(catalog_index_url(:format => :rss, :params => params))
		xml.description('from the University of Virginia Library')
		xml.language('en-us')
		
		@document_list.each do |document| 
			xml.item do
			  document.doc_type == :article ? title = document.display.title : title = document.value_for(:title_display)
				xml.title(  title )
        document.doc_type == :article ? link = document.links.first.fulltext_url : link = catalog_url(document[:id])
				xml.link( link )
				unless document.doc_type == :article
          author = document.value_for(:author_display).match('n/a') ? "" : document.value_for(:author_display)+ "<br />" 
          summary = document.value_for(:description_note_display).match('n/a') ? "" : document.value_for(:description_note_display) + "<br />"
          call_number= document.value_for(:call_number_display)
          location=document.value_for(:library_facet)
          xml.description( author + summary + " Call number: " + call_number + "  Location: " +  location)
				end
			#  xml.author( document.value_for(:author_display) )
				
			#xml.description{
       #  document.value_for(:subtitle_display) + "\n" + document.value_for(:author_display) +
        #  xml.cdata!( image_tag(image_catalog_path(:format => :jpg, :id => document[:id] ), :alt => 'Cover for ' + document.value_for(:title_display) ) )
          
      #}
      
				
			end
		end
		
	}
}
