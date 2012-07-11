require 'lib/uva/solr_helper_override'
require 'lib/firehose/patron'


class ReservesController < ApplicationController
  include Blacklight::SolrHelper
  include Blacklight::Configurable
  include UVA::SolrHelperOverride
  include Firehose::Patron
  
  def email
    @response, @documents = get_solr_response_for_field_values("id",session_folder_document_ids || []) 
    @user_patron = get_patron(current_user.login) unless current_user.blank?
  end
  
end