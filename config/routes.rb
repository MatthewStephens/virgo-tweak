Rails.application.routes.draw do 

  Blacklight.add_routes(self)
  
  root :to => "catalog#index"
  
  match 'catalog/:id/image', :to => 'catalog#image', :as => 'image' 
  match 'catalog/:id/brief_availability', :to => 'catalog#brief_availability', :as => 'brief_availability'
  match 'catalog/:id/availability', :to => 'catalog#availability', :as => 'availability'
  match 'catalog/:id/status', :to => 'catalog#availability', :as => 'status'
  match 'catalog/:id/image_load', :to => 'catalog#image_load', :as => 'image_load'
  match 'catalog/:id/firehose', :to => 'catalog#firehose', :as => 'firehose', :defaults => { :format => 'xml'}
  match 'catalog/:id/view', :to => 'catalog#page_turner', :as => 'view'
  match 'catalog/:id/page_turner', :to => 'catalog#page_turner', :as => 'page_turner'
  match 'fedora_metadata/:id/:pid.:format', :to => 'catalog#fedora_metadata', :as => 'fedora_metadata'
  match 'folder/refworks_texts', :to => 'folder#refworks_texts', :as => 'refworks_texts'
  match 'folder/article_destroy', :to => 'folder#article_destroy', :as => 'folder_article_destroy'
  match 'folder/csv', :to => 'folder#csv', :as => 'csv'
  match 'folder/citation', :to => 'folder#citation', :as => 'citation'
  match 'folder/email', :to => 'folder#email', :as => 'email'
  match 'folder/endnote', :to => 'folder#endnote', :as => 'endnote'
  match 'advanced', :to => 'advanced#index', :as => 'advanced'
  match 'login', :to => 'user_sessions#new', :as => 'login'
  match 'logout', :to => 'user_sessions#destroy', :as => 'logout'
  match 'logged_out', :to => 'user_sessions#logged_out', :as => 'logged_out'
  match 'patron_login', :to => 'user_sessions#patron_login', :as => 'patron_login'
  match 'do_patron_login', :to => 'user_sessions#do_patron_login', :as => 'do_patron_login'
  match 'account_requests/:id/renew/:checkout_key', :to => 'account_requests#renew', :as => 'renew'
  match 'account_requests/renew_all', :to => 'account_requests#renew_all', :as => 'renew_all'
  match 'reserves/:computing_id/:key', :to => 'reserves#course', :as => 'reserve_course'
  match 'special_collections_requests/:id/new', :to => 'special_collections_requests#new', :as => 'new_special_collections_request'

  resources :account, :only => [:index] do
    member do
      get :not_found
    end
    collection do
      get :checkouts
      get :holds
      get :reserves
      get :notices
      get :renew
      get :review
      get :select
    end
  end

  resources :maps
  resources :maps_users
  resources :call_number_ranges

  resources :special_collections_requests, :except => [:new] do
    member do
      get :start
      get :non_uva
      get :show, :defaults => { :format => 'pdf'}
    end
  end

  resources :articles, :only => [:index] do
    collection do
      get :facet
      get :advanced
    end
  end

  resources :account_requests, :only => [] do
    member do
      get :start_hold
      post :create_hold
    end
  end

  resources :reserves, :only => [:index]

  resources :folder, :only => [:index, :create, :update, :destroy] do
    collection do
      delete :clear
    end
  end
  
end
