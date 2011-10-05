# PubCookie will only be used to trigger the authentication server once.
# After the user succesfully logs in, PubCookie will redirect back to the "new" action here.
# Once we get the REMOTE_USER value from PubCookie (Apache)
# we set our own session value and never bother with PubCookie again.
#
# In production, for the :80 section of the configs, Apache should be set up to do a 
# redirect for /login and /logout to an SSL request.  Also, for the :443 section of the
# congis, /login and /logout should be set up to turn on and off NetBadge authentication.
# If these steps aren't in place, a temp account will be created
#
### Example for the :80 section 
# RewriteEngine On
# RewriteLog  "/var/log/httpd/blacklight_rewrite_log"
# RewriteLogLevel 2
# RewriteCond %{HTTPS} !=on
# RewriteRule ^/login https://%{HTTP_HOST}/login [R=301,L]
# RewriteRule ^/logout https://%{HTTP_HOST}/logout [R=301,L]
### Example for the :443 section
# <Location /login>
#   AuthType NetBadge
#   require valid-user
#   PubcookieAppId blacklight
#   PubcookieInactiveExpire -1
# </Location>
# <Location /logout>
#   PubcookieEndSession on
# </Location>

class UserSessionsController < ApplicationController
   
   # processes the user id from the environment, and then logs the user in
   # if there is no id, create a demo account
   def new
     # if the session is already set, use the session login
       if session[:login]
         user = User.find_by_login(session[:login])
       # request coming from PubCookie... get login from REMOTE_USER
       elsif request.env['REMOTE_USER']
         if (request.env['REMOTE_USER'] == 'mjb7q')
           user = User.find_or_create_by_login(:login=>params[:login]) if user.nil?
         else
           user = User.find_or_create_by_login(request.env['REMOTE_USER']) if user.nil?
         end
       elsif (RAILS_ENV == 'cucumber' or RAILS_ENV == 'test') and !params[:login].blank?
         user = User.create(:login=>params[:login]) if user.nil?
       elsif RAILS_ENV == 'cucumber' or RAILS_ENV == 'test' and !params[:login].blank?
         user = User.create(:login=>params[:login]) if user.nil?
       elsif RAILS_ENV == 'development' and !params[:login].blank?
         user = User.create(:login=>params[:login]) if user.nil?
       else
         # Create the temp/demo user if the above methods didn't work
         user = User.create(:login=>'demo_' + User.count.to_s) if user.nil? 
       end
       do_redirect(user) and return
   end
   
   def do_patron_login
      if session[:login]
        user = User.find_by_login(session[:login])
      else
        patron = get_patron(params[:login]) or render 'account/not_found'
        unless patron.virginia_borrower?
          flash[:error] = 'UVa members should use NetBadge to authenticate'
          redirect_to catalog_index_path
        else 
           user = User.find_or_create_by_login(params[:login])
           do_redirect(user) and return
        end
      end
   end
   
   def do_redirect(user)
     # store the user_id in the session
      session[:login] = user.login
      @user_session = UserSession.create(user, true)
      
     # redirect to the catalog with http protocol
      # make sure there is a session[:search] hash, if not just use an empty hash
      # and merge in the :protocol key
      redirect_params = {:protocol=>'http'}
      if params[:redirect] == 'maps'
        redirect_to maps_url(redirect_params)
      elsif params[:redirect] == 'special_collections_user'
        redirect_params.merge!(:id => params[:id], :qt => 'document')
        redirect_to new_special_collections_request_url(redirect_params)
      elsif params[:redirect] == 'special_collections_admin'
        redirect_to special_collections_requests_url(redirect_params)
      elsif params[:redirect] == 'recall'
        redirect_params[:id] = params[:id]
        redirect_to start_hold_account_request_url(redirect_params)
      else
        redirect_params.merge!(session[:search] || {})
        redirect_to root_url(redirect_params)
      end
   end
   
   # logs out the user. maintains the special collections lens, if appropriate.
   def destroy
      keep_special_collections = true if session[:special_collections] == true
      reset_session
      current_user_session.destroy if current_user_session
      session[:special_collections] = true if keep_special_collections
      redirect_params = (session[:search] || {}).merge(:protocol=>'http')
      redirect_to logged_out_url(redirect_params)
    end
    
  # dispatches to patron login
  def patron_login
  end
  
  # dummy method so that we can dispatch to a logged out page  
  def logged_out
  end

end
