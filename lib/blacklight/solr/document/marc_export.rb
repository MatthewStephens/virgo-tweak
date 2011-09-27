module Blacklight::Solr::Document::MarcExport

require_dependency 'vendor/plugins/blacklight/lib/blacklight/solr/document/marc_export.rb'

  def self.register_export_formats(document)
    document.will_export_as(:xml)
    document.will_export_as(:json)
    document.will_export_as(:marc, "application/marc")
    # marcxml content type: 
    # http://tools.ietf.org/html/draft-denenberg-mods-etc-media-types-00
    document.will_export_as(:marcxml, "application/marcxml+xml")
    document.will_export_as(:openurl_kev, "text/plain")
    document.will_export_as(:refworks_marc_txt, "text/plain")
    document.will_export_as(:endnote, "application/x-endnote-refer")
  end
  
  def export_as_json
    to_marc.to_json
  end
  

  # this is overridden from the plugin to add the rescue line to address items like u3869450/citation.  
  #this should probably be added to the plugin.
  def get_author_list(record)
    author_list = []
    authors_primary = record.find{|f| f.tag == '100'}
    author_primary = authors_primary.find{|s| s.code == 'a'}.value unless authors_primary.nil? rescue '' #changed
    author_list.push(clean_end_punctuation(author_primary)) unless author_primary.nil?
    authors_secondary = record.find_all{|f| ('700') === f.tag}
    if !authors_secondary.nil?
      authors_secondary.each do |l|
        author_list.push(clean_end_punctuation(l.find{|s| s.code == 'a'}.value)) unless l.find{|s| s.code == 'a'}.value.nil?
      end
    end

    author_list.uniq!
    author_list
  end
  
  # this is overridden from the plugin to test for blank instead of nil entries (to address items like u5074985)
  # this should probably be changed in the plugin
  def apa_citation(record)
     text = ''
     authors_list = []
     authors_list_final = []

     #setup formatted author list
     authors = get_author_list(record)
     authors.each do |l|
       authors_list.push(abbreviate_name(l)) unless l.blank? #changed
     end
     authors_list.each do |l|
       if l == authors_list.first #first
         authors_list_final.push(l.strip)
       elsif l == authors_list.last #last
         authors_list_final.push(", &amp; " + l.strip)
       else #all others
         authors_list_final.push(", " + l.strip)
       end
     end
     text += authors_list_final.join
     unless text.blank?
       if text[-1,1] != "."
         text += ". "
       else
         text += " "
       end
     end
     # Get Pub Date
     text += "(" + setup_pub_date(record) + "). " unless setup_pub_date(record).nil?

     # setup title info
     title = setup_title_info(record)
     text += "<i>" + title + "</i> " unless title.nil?

     # Edition
     edition_data = setup_edition(record)
     text += edition_data + " " unless edition_data.nil?

     # Publisher info
     text += setup_pub_info(record) unless setup_pub_info(record).nil?
     unless text.blank?
       if text[-1,1] != "."
         text += "."
       end
     end
     text
 end
 
 # this is overridden from the plugin
 def export_as_openurl_ctx_kev(format = nil)  
    title = to_marc.find{|field| field.tag == '245'}
    author = to_marc.find{|field| field.tag == '100'}
    publisher_info = to_marc.find{|field| field.tag == '260'}
    edition = to_marc.find{|field| field.tag == '250'}
    isbn = to_marc.find{|field| field.tag == '020'}
    issn = to_marc.find{|field| field.tag == '022'}
    id = to_marc.find{|field| field.tag == '001'}
    unless format.nil?
      format.is_a?(Array) ? format = format[0].downcase.strip : format = format.downcase.strip
    end
 
      if format == 'book'
       return "ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Abook&amp;rfr_id=info%3Asid%2Fblacklight.rubyforge.org%3Agenerator&amp;rft.genre=book&amp;rft.btitle=#{(title.nil? or title['a'].nil?) ? "" : CGI::escape(title['a'])}+#{(title.nil? or title['b'].nil?) ? "" : CGI::escape(title['b'])}&amp;rft.title=#{(title.nil? or title['a'].nil?) ? "" : CGI::escape(title['a'])}+#{(title.nil? or title['b'].nil?) ? "" : CGI::escape(title['b'])}&amp;rft.au=#{(author.nil? or author['a'].nil?) ? "" : CGI::escape(author['a'])}&amp;rft.place=#{(publisher_info.nil? or publisher_info['a'].nil?) ? "" : CGI::escape(publisher_info['a'])}&amp;rft.date=#{(publisher_info.nil? or publisher_info['c'].nil?) ? "" : CGI::escape(publisher_info['c'])}&amp;rft.pub=#{(publisher_info.nil? or publisher_info['b'].nil?) ? "" : CGI::escape(publisher_info['b'])}&amp;rft.edition=#{(edition.nil? or edition['a'].nil?) ? "" : CGI::escape(edition['a'])}&amp;rft_id=http%3A%2F%2Fsearch.lib.virginia.edu%2Fcatalog%2F#{id.value}&amp;rft.isbn=#{(isbn.nil? or isbn['a'].nil?) ? "" : isbn['a']}"
      elsif (format =~ /journal/i) # checking using include because institutions may use formats like Journal or Journal/Magazine
        return  "ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&amp;rfr_id=info%3Asid%2Fblacklight.rubyforge.org%3Agenerator&amp;rft.genre=article&amp;rft.title=#{(title.nil? or title['a'].nil?) ? "" : CGI::escape(title['a'])}+#{(title.nil? or title['b'].nil?) ? "" : CGI::escape(title['b'])}&amp;rft.atitle=#{(title.nil? or title['a'].nil?) ? "" : CGI::escape(title['a'])}+#{(title.nil? or title['b'].nil?) ? "" : CGI::escape(title['b'])}&amp;rft.date=#{(publisher_info.nil? or publisher_info['c'].nil?) ? "" : CGI::escape(publisher_info['c'])}&amp;rft_id=http%3A%2F%2Fsearch.lib.virginia.edu%2Fcatalog%2F#{id.value}&amp;rft.issn=#{(issn.nil? or issn['a'].nil?) ? "" : issn['a']}"
      else
         value = ""
         value += "ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Adc&amp;rfr_id=info%3Asid%2Fblacklight.rubyforge.org%3Agenerator&amp;"
         value += "rft.title=" + ((title.nil? or title['a'].nil?) ? "" : CGI::escape(title['a']))
         value +=  ((title.nil? or title['b'].nil?) ? "" : CGI.escape(" ") + CGI::escape(title['b']))
         value += "&amp;rft.creator=" + ((author.nil? or author['a'].nil?) ? "" : CGI::escape(author['a']))
         value += "&amp;rft.date=" + ((publisher_info.nil? or publisher_info['c'].nil?) ? "" : CGI::escape(publisher_info['c']))
         value +=  "&amp;rft.pub=" + ((publisher_info.nil? or publisher_info['b'].nil?) ? "" : CGI::escape(publisher_info['b']))
         value +=  "&amp;rft.place=" + ((publisher_info.nil? or publisher_info['a'].nil?) ? "" : CGI::escape(publisher_info['a']))
         value += "&amp;rft_id=http%3A%2F%2Fsearch.lib.virginia.edu%2Fcatalog%2F#{id.value}&amp;"
         value += "&amp;rft.format=" + (format.nil? ? "" : CGI::escape(format))
        return value
     end
  end

end