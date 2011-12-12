module UVA
  
  module Fedora
    # a mixin module, giving additional methods
    # thus far only used in catalog controller

    def get_exemplar(repo_url, pid)
      require 'rest_client'
      require 'uri'
      @pid = pid

      # runs a SPARQL query on fedora object to get pid for a title page or other image that exemplifies this item
      # The id passed is the pid of the Fedora aggregation object (the book,
      # manuscript, etc. for which we want to display page images)
   
      response=sparql_query_self(repo_url, @pid, "hasExemplar", "djatoka:jp2CModel")

      if response.to_s !~ /info:fedora/
        response=sparql_query_self(repo_url, @pid, "hasCatalogRecordIn", "djatoka:jp2CModel")
      end

      # Because we've used format=CSV above, the response is in plain text
      # format with a header line and then one pid per line, like so:
      #   "object"
      #   info:fedora/uva-lib:1234
      #   info:fedora/uva-lib:1235
      #   info:fedora/uva-lib:1236
      # Convert to an array of pid values, as in ["uva-lib:1234", "uva-lib:1235", "uva-lib:1236"]
      #
      # The Fedora response doesn't seem to return the pids in any particular
      # order, but order shouldn't matter as there should only be one entry per item.  Fedora doesn't
      # seem to offer anything akin to a METS <structMap>, but we will split the pid
      # grabbing the integer localname and using it to build an ordered list
      #
      # N.B. The SPARQL query returns the word "object" with each query, and this method looks for that
     
      exemplar_pids = Array.new
      if response.to_s =~ /info:fedora/
        exemplar_pid=get_pids_from_csv(response)

        # If, for some reason, this SPARQL query returned more than one pid in the array, we will code
        # that the only one returned to the view will be element 0.
        return exemplar_pid[0] 
      else
        # if no RDF info was found, return own pid
        logger.debug("GET_EXEMPLAR FAIL: returning #{@pid}")
        return @pid
      end
    end

    def get_pids_from_sparql(response)
      require 'nokogiri'
      optional="supp"
      desc="desc"
   
      doc=Nokogiri::XML(response)
      errs=doc.errors
      if errs.length != 0 
       warn "ERROR: Sparql query response has XML parse errors." 
      end
      
      nodeset=doc.xpath("//*[local-name()='result']")

      sorted_pid_list=Array.new
      nodeset.each do |n| 
        set=Hash.new
        obj=n.xpath("./*[local-name()='object']/@uri").to_s.gsub(/info:fedora\//, '') 
        title=n.xpath("./*[local-name()='#{optional}']/text()[1]").to_s
        description=n.xpath("./*[local-name()='#{desc}']/text()[1]").to_s
        set[:pid]= obj
        set[:title]= title
        set[:description]= description
        sorted_pid_list << set
      end

      return sorted_pid_list
    end

    def get_pids_from_csv(response)
      # parse response object, grabbing pid(s) for matching objects
      # N.B. returns sorted list of pids, sorting on integer after pid delimiter
      # TODO: handle exceptions for e.g., uva-lib:test1, which to_i takes as 0 

      pids = response.to_s.sub(/"object"\s*/,'').split().collect {|s| s.sub(/info:fedora\//,'')}.sort

      sorted_pid_list=Array.new
      pids.each { |t| x=t.split(":"); sorted_pid_list[x[1].to_i]=t }
      sorted_pid_list.compact!

      return sorted_pid_list # explicit return for clarity
    end

    def sparql_query_others(repo_url, pid, relationship, options={})
      options[:type] ||= false
      options[:limit] ||= "10000"
      options[:supp] ||= false
      options[:desc] ||= false

      # runs a SPARQL query on fedora objects to get pid(s) for objects mentioning pid
      # type passes a content model to Resource Index, limit sets number of results

      # this fedora urn will restrict queries to data objects (excludes cModels, sDefs, etc.)
      type="fedora-system:FedoraObject-3.0" if options[:type]==nil || type==''

      require 'rest_client'
      require 'uri'
  
      # Set up REST client
      resource = RestClient::Resource.new repo_url, :user => Fedora_username, :password => Fedora_password
    
      # Search the Fedora repository's Resource Index (using a SPARQL query)
      # to query an items own RDF triples and select any values for hasExemplar 
      # (triple should contain pid of another item which has a JP2K stream)

      terms="$object" 
      terms << " $supp" if options[:supp]
      terms << " $desc" if options[:desc]

      query = "SELECT #{terms} FROM <#ri> WHERE  {
        $object <fedora-model:state> <fedora-model:Active> . "

      query << "$object <fedora-model:hasModel> <info:fedora/#{options[:type]}> . " if options[:type]
      query << "$object <#{options[:supp]}> $supp . " if options[:supp]
      query << "$object <http://fedora.lib.virginia.edu/relationships##{relationship}> <info:fedora/#{pid}> . "
      query << "OPTIONAL { $object <#{options[:desc]}> $desc . } " if options[:desc] 
      query << "} ORDER BY $object limit #{options[:limit]}"

      url = "/risearch?type=tuples&lang=sparql&format=Sparql&query=#{URI.escape(query)}"

      response = resource[url].get
      # if this query comes back empty, try a query for the first child object
      return response
    end

    def sparql_query_self(repo_url, pid, relationship, type=false, limit=1000)
      # runs a SPARQL query on fedora object 'pid' to fetch references to objects based on relationship specified
      # type passes a content model to Resource Index, limit sets number of results

      type="fedora-system:FedoraObject-3.0" if type==nil || type==''
      require 'rest_client'
      require 'uri'
  
      # Set up REST client
      resource = RestClient::Resource.new repo_url, :user => Fedora_username, :password => Fedora_password
    
      # Search the Fedora repository's Resource Index (using a SPARQL query)
      # to query an items own RDF triples and select any values for hasExemplar 
      # (triple should contain pid of another item which has a JP2K stream)

      query="select $object from <#ri> where  {$object <fedora-model:state> <fedora-model:Active> . "
      unless type==false then query << "$object <fedora-model:hasModel> <info:fedora/#{type}> . " end
      query << "<info:fedora/#{pid}> <http://fedora.lib.virginia.edu/relationships##{relationship}> $object } limit #{limit}"
      url = "/risearch?type=tuples&lang=sparql&format=CSV&query=#{URI.escape(query)}"

      response = resource[url].get

      # if this query comes back empty, try a query for the first child object
      return response
    end

    def get_other_record(some_id)
      q="id:" + some_id.to_s.gsub(/:/, "?")
      response, document = self.public_methods.to_yaml, self.class
      #response, document = get_solr_response_for_doc_id("uva-lib:729422") 
      response = Blacklight.solr.select(:q => q )
      [response, document]
    end
  end
end
