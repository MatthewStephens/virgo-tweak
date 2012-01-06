require 'lib/firehose/patron'
require 'lib/firehose/checkouts'
require 'lib/firehose/holds'
require 'lib/firehose/reserves'
class AccountController < ApplicationController

  include Firehose::Patron
  include Firehose::Checkouts
  include Firehose::Holds
  include Firehose::Reserves
  before_filter :verify_login, :except => "select"
  before_filter :notices_update

  def index
    @user_patron = get_patron(current_user.login) or render :not_found
  end
  
  def checkouts
    @user_checkouts = get_checkouts(current_user.login) or render :not_found
  end
  
  def holds
    @user_holds = get_holds(current_user.login) or render :not_found
  end
  
  def reserves
    @user_reserves = get_reserves(current_user.login) or render :not_found
  end
  
  def notices
    @user_checkouts = get_checkouts(current_user.login) or render :not_found
  end    
  
  def not_found
    @user_patron = get_patron(current_user.login) or render :not_found
  end
  
  def select
  end
  
  protected
  def verify_login
    if current_user.nil?
      flash[:error] = "Please log in to access your account."
      redirect_to catalog_index_path 
    end
  end

end