require_dependency 'vendor/plugins/blacklight/app/controllers/application_controller.rb'

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Account::Patron
  helper :all # include all helpers, all the time
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
    return if current_user.nil?
    if !session[:notices_expiration] or session[:notices_expiration] < Time.now or force_update
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
end
