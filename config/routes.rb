MmdbFotoportal::Application.routes.draw do

  root :to => 'home#index'
  
  match '/login'    => 'user#login', :as => :login
  match '/register' => 'user#register', :as => :register
  match '/logout'   => 'user#logout', :as => :logout
  match '/upload'   => 'picture#upload', :as => :upload

  match '/pictures'                 => 'gallery#show_folder', :as => :gallery
  match '/folder/:folder_id'        => 'gallery#show_folder', :as => :folder
  match '/folder/add/:parent_id'    => 'gallery#add_folder', :as => :new_folder
  match '/folder/remove/:folder_id' => 'gallery#remove_folder', :as => :delete_folder
  
  match '/:picture_id'       => 'gallery#show_picture', :as => :picture, 
        :constraints => { :picture_id => /\d+/ }
          
  match '/pictures/load' => 'gallery#load_more_pictures', :as => :load_more_pictures
  match '/pictures/faces_and_keywords' => 'gallery#load_faces_and_keywords', :as => :load_faces_and_keywords
  match '/:picture_id/edit' => 'picture#edit', :as => :edit_picture,
        :constraints => { :picture_id => /\d+/ }

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
