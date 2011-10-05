ActionController::Routing::Routes.draw do |map|
  
   Blacklight::Routes.build map

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'

  map.image 'catalog/:id/image', :controller => 'catalog', :action => 'image'
  map.image_load 'catalog/:id/image_load', :controller => 'catalog', :action => 'image_load'
  map.firehose 'catalog/:id/firehose', :controller => 'catalog', :action => 'firehose'
  map.album 'catalog/:id/album', :controller => 'catalog', :action => 'album'
  map.album_image 'catalog/:id/album_image/:mbid.:format', :controller => 'catalog', :action => 'album_image'
  map.page_turner 'catalog/:id/page_turner', :controller => 'catalog', :action => 'page_turner'
  map.fedora_metadata 'fedora_metadata/:id/:pid.:format', :controller => 'catalog', :action => 'fedora_metadata'
  map.refworks_texts 'folder/refworks_texts', :controller => 'folder', :action => 'refworks_texts'
  map.csv 'folder/csv', :controller => 'folder', :action => 'csv'
  
  map.citation 'folder/citation', :controller => 'folder', :action => 'citation'
  map.email 'folder/email', :controller => 'folder', :action => 'email'
  map.endnote 'folder/endnote', :controller => 'folder', :action => 'endnote'

  map.advanced 'advanced', :controller => 'advanced', :action => 'index'

  map.logged_out 'logged_out', :controller => 'user_sessions', :action => 'logged_out'

  map.patron_login 'patron_login', :controller => 'user_sessions', :action => 'patron_login'
  map.do_patron_login 'do_patron_login', :controller => 'user_sessions', :action => 'do_patron_login'

  map.resources(:account,
      :only => [:index],
      # /resources/checkouts
      :collection => {:checkouts => :get, :holds => :get, :reserves => :get, :notices => :get, :select => :get},
      :member => {:not_found => :get}
  )
  map.resources :maps
  map.resources :maps_users
  map.resources :locations
  map.resources :map_guides
  map.resources(:special_collections_requests,
      :member=>{:start=>:get, :non_uva=>:get}
  )

  map.resources(:articles,
                  :only => [:index],
                  :collection =>{:facet=>:get, :advanced=>:get})

  map.catalog_facet "catalog/facet/:id.:format", :controller=>'catalog', :action=>'facet'

  map.renew 'account_requests/:id/renew/:checkout_key', :controller => 'account_requests', :action => 'renew'
  map.renew_all 'account_requests/renew_all', :controller => 'account_requests', :action => 'renew_all'
  map.resources(:account_requests, 
                :only => [],
                :member=>{:start_hold=>:get, :create_hold=>:post} )

  map.resources(:reserves, :only=>[:index])
  map.reserve_course 'reserves/:computing_id/:key', :controller => 'reserves', :action => 'course'

end
