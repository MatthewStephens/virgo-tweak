module CoverImage
  class Loader
    include Blacklight::SolrHelper
    include UVA::SolrHelper

    def initialize(do_solr_updates, date_string)
      do_solr_updates ? docs = solr_add_docs(date_string) : docs = hourly_updates
      puts("about to look for covers for docs #{docs.collect{|doc| doc[:id]}.inspect}")
      prepare_harvest(docs)
    end
  
    def params
      {}
    end
    
    # gets requested added to the index on the given date_string (YYYYmmdd)
    def solr_add_docs(date_string)
      local_params = {}
      local_params[:f] = {}
      local_params[:f][:date_first_indexed_facet] = [date_string]
      local_params[:sort] = 'date_received_facet desc'
      local_params[:per_page] = 100
      response, documents = get_search_results(local_params)
      documents
    end
    
    # gets requests for the last hour
    def hourly_updates
      start_time = DateTime.civil(Time.now.year, Time.now.month, Time.now.day, Time.now.hour - 1)
      end_time = DateTime.civil(Time.now.year, Time.now.month, Time.now.day, Time.now.hour)
      # get the requests for the last hour
      image_requests = DocumentImageRequestRecord.find(:all, :conditions => {:requested_at => start_time..end_time}) || []
      # take those document ids and turn them into solr docs
      doc_ids = image_requests.collect {|request| request.document_id}
      response, documents = get_solr_response_for_field_values("id", doc_ids)
      documents
    end
    
    # turn the solr docs into doc images and harvest away
    def prepare_harvest(docs)
      docs.each do |doc|
        doc_image = CoverImage::Image.new(doc)
        harvest!(doc_image)
        end
    end
    
    # harvest an image for this doc
    def harvest!(doc_image)
      if images = find(doc_image.doc)
        puts("found image for #{doc_image.doc[:id]}")
        FileUtils.mkdir_p File.dirname(doc_image.file_path)
        File.open(doc_image.file_path, File::CREAT|File::WRONLY) {|f| f.puts images.first[:source_data] }
      end
    end

    # dispatch to the appropriate finder
    def find(doc)
      return find_bookcovers(doc) if doc.doc_type==:lib_catalog
      mbids = music_brainz_ids(doc)
      return find_albumcovers(mbids) if doc.doc_type==:lib_album && !mbids.nil?
      # find a way to do digital library images too?
    end
    
    #
    # load up the finders and go find!
    #
    def find_bookcovers(doc)
      puts "LOOKING FOR A BOOKCOVER for #{doc[:id]}:: #{doc.isbns.inspect}"
      ri = CoverImage::Finder.new(:use_cache=>false)
      ri.add_finder :syndetics, CoverImage::Sources::Syndetics.new
      ri.add_finder :google, CoverImage::Sources::Google.new
      ri.add_finder :library_thing, CoverImage::Sources::LibraryThing.new
      ri.find(:isbn=>doc.isbns)
    end
    
    #
    # load up the finders and go find!
    #
    def find_albumcovers(ids)
      puts "LOOKING FOR AN ALBUM COVER"
      ri = CoverImage::Finder.new(:use_cache=>false)
      ri.add_finder :last_fm, CoverImage::Sources::LastFM.new
      ri.find(:mbid=>ids)
    end
    
    def music_brainz_ids(doc)
      author = doc.values_for(:author_display).first unless doc.values_for(:author_display).nil?
      title = doc.values_for(:title_display).first unless doc.values_for(:title_display).nil?
      return if author.nil? || title.nil?
      author = author.sub(/ \(Musical group\)/, '') # remove that last little annoying bit
      mb = CoverImage::Sources::MusicBrainz.new
      mb.find_album_ids_by_artist_and_album(author, title)
    end

  end
end    
      