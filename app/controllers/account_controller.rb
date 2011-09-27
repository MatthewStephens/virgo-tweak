class AccountController < ApplicationController

  include Account::Patron
  include Account::Checkouts
  include Account::Holds
  include Account::Reserves
  before_filter :verify_login, :except => "select"

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