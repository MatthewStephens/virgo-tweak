class AccountRequestsController < ApplicationController

  include Firehose::Libraries
  include Firehose::Patron
  include Firehose::Holds
  include Firehose::Checkouts
  include Firehose::Common
  include Blacklight::SolrHelper
  include UVA::SolrHelper
  
  before_filter :solr_lookup, :only=>[:start_hold, :create_hold, :renew]
  before_filter :verify_account
  before_filter :verify_hold_request, :only=>[:start_hold, :create_hold]
  before_filter :verify_renew_request, :only=>:renew
  
  rescue_from RenewError do |error| 
    flash[:notice] = "Sorry, you seem to have encountered an error: #{error}"
    redirect_to checkouts_account_path
  end
  
  rescue_from HoldError do |error| 
    flash[:notice] = "Sorry, you seem to have encountered an error: #{error}"
    render 'error', :layout => params[:popup].blank? ? "application" : "popup"
  end
  
  def start_hold
    @library_list = get_library_list
    render :layout => params[:popup].blank? ? "application" : "popup"
  end
  
  def create_hold
    place_hold(current_user.login, params[:id], params[:library_id], params[:call_number])
    render :layout => params[:popup].blank? ? "application" : "popup"
  end
  
  def renew_all
    do_renew_all(current_user.login)
    flash[:notice] = "Items successfully renewed."
    notices_update(true)
    redirect_to checkouts_account_path
  end
  
  def renew
    do_renew(current_user.login, params[:checkout_key])
    flash[:notice] = "Item successfully renewed."
    notices_update(true)
    redirect_to checkouts_account_path
  end
  
  protected
  
  def solr_lookup
    ckey = params[:id]
    ckey = "u#{ckey}" unless ckey.start_with?("u")
    @response, @document = get_solr_response_for_doc_id(ckey, params)
  end
  
  def verify_renew_request
    selected = @account.checkouts.select{ |checkout| checkout.key == params[:checkout_key] }
    unless selected.size > 0
      flash[:error] = "Selected item is not eligible for renewal."
      redirect_to checkouts_account_path
    end
  end
  
  def verify_hold_request
    @document.availability = Firehose::Availability.find(@document)
    if !@document.availability.might_be_holdable?
      flash[:error] = @document.availability.holdability_error
      render 'error', :layout => params[:popup].blank? ? "application" : "popup"
    end
    unless params[:call_number].blank?
      unless @document.availability.has_holdable_holding?(params[:call_number])
        flash[:error] = "Selected item is not eligible for holds or recalls"
        render 'error', :layout => params[:popup].blank? ? "application" : "popup"
      end
    end
    if @document.availability.user_has_checked_out?(@account, params[:call_number])
      flash[:error] = "Selected item is already checked out to you."
      render 'error', :layout => params[:popup].blank? ? "application" : "popup"
    end
  end
  
  def verify_account
    if current_user.nil?
      if params[:id]
        ckey = params[:id].slice(1..(params[:id].length - 1))      
        flash[:error] = "<p>Please <a class='btn small' href='/login?redirect=recall&id=#{params[:id]}'>sign in with NetBadge</a> to request this item.</p><p>Don't have a U.Va. account?  Request this item from <a class='btn small' href='http://virgo.lib.virginia.edu/uhtbin/cgisirsi/uva/0/0/5?searchdata1=#{ckey}{CKEY}'>Virgo Classic</a>.</p>"
        redirect_to catalog_path(params[:id]) and return
      else
        flash[:error] = "<p>Please <a class='btn small' href='/login'>sign in with NetBadge</a>.</p><p>Don't have a U.Va. account?  Sign into <a class='btn small' href='http://virgo.lib.virginia.edu/uhtbin/cgisirsi/0/UVA-LIB/0/1/1166/X/BLASTOFF'>Virgo Classic</a>.</p>"
        redirect_to catalog_path and return
      end
    end
    @account = get_patron(current_user.login) or (render('account/not_found', :layout => params[:popup].blank? ? "application" : "popup") and return)
    if @account.barred
      render 'account/_barred',:layout => params[:popup].blank? ? "application" : "popup" and return
    end
  end
  
end
