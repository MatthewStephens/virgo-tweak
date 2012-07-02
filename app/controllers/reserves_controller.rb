require 'lib/uva/solr_helper_override'
require 'lib/firehose/patron'


class ReservesController < ApplicationController
  include Blacklight::SolrHelper
  include Blacklight::Configurable
  include UVA::SolrHelperOverride
  include Firehose::Patron

  before_filter :max_per_page_params, :only=>[:index, :refworks_texts, :csv]
  before_filter :resolve_sort, :only=>:index
  
 def cres_email
     @response, @documents = get_solr_response_for_field_values("id",session_folder_document_ids || []) 
     @user_patron = get_patron(current_user.login) unless current_user.blank?
 end
end