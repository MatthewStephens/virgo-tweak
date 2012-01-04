# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'firehose/patron'
require 'lib/uva/search_fields_helper'
require 'lib/uva/solr_helper_override'
require 'lib/uva/virgo_marc_record'

class ApplicationController < ActionController::Base
  include Blacklight::Controller
  include Firehose::Patron
  include UVA::SearchFieldsHelper
  include UVA::SolrHelperOverride
  helper :all # include all helpers, all the time
  helper_method :user_session, :current_user, :new_user_session_path, :destroy_user_session_path
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  before_filter :notices_update

  include ExceptionNotification::Notifiable
  include UVA::ScopeHelper

  # ensures that the current user is allowed to administer maps
  def verify_map_user
    if current_user.nil?
      flash[:error] = 'You must be logged in to manage maps. <a href="/login?redirect=maps">Log in</a>'
      redirect_to root_path
    elsif MapsUser.find_by_computing_id(current_user[:login]).nil?
      flash[:error] = 'You are not authorized to manage maps.'
      redirect_to root_path
    end
  end
  
  def notices_update(force_update=false)
    if !session[:notices_expiration] or session[:notices_expiration] < Time.now or force_update
      return if current_user.nil?
      user = get_patron(current_user.login)
      return if !user
      half_hour = 1800
      session[:notices_expiration] = half_hour.seconds.from_now
      session[:notice_count] = user.overdue_count + user.recalled_count
      return
    end
  end
  
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  # The following methos are required by blacklight in order to interact with the user.

  def current_user_session
    user_session
  end

  def user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end
  
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = user_session && user_session.record
  end

  def new_user_session_path
    return login_path
  end

  def destroy_user_session_path
    return logout_path
  end
  
  #over-ride this one locally to change what layout BL controllers use, usually
  #by defining it in your own application_controller.rb
  def layout_name
    'application'
  end
  
end
