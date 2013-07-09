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
          
  match '/pictures/search' => 'gallery#search', :as => :search
  match '/pictures/faces_and_keywords' => 'gallery#load_faces_and_keywords', :as => :load_faces_and_keywords
  match '/:picture_id/edit' => 'picture#edit', :as => :edit_picture,
        :constraints => { :picture_id => /\d+/ }
end
