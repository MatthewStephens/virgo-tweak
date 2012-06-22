require 'lib/uva/articles_helper'
require 'lib/uva/solr_helper_override'

class ReservesController < ApplicationController
  include UVA::ArticlesHelper
  include Blacklight::SolrHelper
  include Blacklight::Configurable
  include UVA::SolrHelperOverride
  
  
  before_filter :max_per_page_params, :only=>[:index, :refworks_texts, :csv]
  before_filter :resolve_sort, :only=>:index
  before_filter :articles, :only=>[:index, :csv]
  
 def cres_email
     @response, @documents = get_solr_response_for_field_values("id",session_folder_document_ids || []) 
 end
end