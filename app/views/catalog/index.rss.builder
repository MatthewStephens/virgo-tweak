xml.instruct! :xml, :version=>"1.0"
xml.rss(:version=>"2.0"){
	
	xml.channel{
		
		xml.title('VIRGO Catalog Search Results')
		xml.link(catalog_index_url(:format => :rss, :params => params))
		xml.description('from the University of Virginia Library')
		xml.language('en-us')
		
		@document_list.each do |document| 
			xml.item do
			  
				xml.title( document.value_for(:title_display)  )
          
				xml.link(catalog_url(document[:id]) )
        xml.cdata!( 
          summary = document.value_for(:description_note_display).match('n/a') ? "" : document.value_for(:description_note_display) + "<br />")
           
          
        xml.description( summary + "Call number: " + document.value_for(:call_number_display) + "  Location: " + document.value_for(:library_facet) )
				
			#  xml.author( document.value_for(:author_display) )
				
			#xml.description{
       #  document.value_for(:subtitle_display) + "\n" + document.value_for(:author_display) +
        #  xml.cdata!( image_tag(image_catalog_path(:format => :jpg, :id => document[:id] ), :alt => 'Cover for ' + document.value_for(:title_display) ) )
          
      #}
      
				
			end
		end
		
	}
}
