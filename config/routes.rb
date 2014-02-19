Villagecraft::Application.routes.draw do
  get "users_controller/users"

  get "w/:id/reruns_partial" => 'workshops#reruns_partial', :as => :reruns_partial
  post "w/:id/auto_add_rerun" => 'workshops#auto_add_rerun', :as => :auto_add_rerun
  resources :w, controller: 'workshops', as: 'workshops'
  resources :workshops, as: 'oldstyle_workshops'

  get 'events/:id/attendees(.:format)' => 'events#attendees', :as => :attendees
  post 'events/:id/confirm(.:format)' => 'events#confirm', :as => :confirm_attend
  get 'events/:id/accept_attendee(.:format)' => 'events#accept_attendee', :as => :accept_attendee
  get 'events/:id/manage' => 'events#manage_attendees', :as => :manage_event
  post 'events/:id/lock' => 'events#lock', :as => :lock_event
  post 'events/:id/unlock' => 'events#unlock', :as => :unlock_event
  post 'events/:id/sms_attendees' => 'events#sms_attendees', :as => :sms_attendees
  resources :events
  resources :meetings, :only => [:update, :show]

  post 'activies/fetch' => 'activities#fetch', :as => :fetch_activities

  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks", :registrations => "registrations" }
  post 'admin_mode_toggle' => 'sessions#admin_mode_toggle', :as => :admin_mode_toggle
  
  resources :users
  get 'preferences' => 'users#edit_preferences', :as => :edit_preferences
  put 'update_preferences' => 'users#update_preferences', :as => :update_preferences
    
  match 'attend/:id(.:format)' => 'events#attend', :as => :attend
  post 'attend_by_email/:id(.:format)' => 'events#attend_by_email', :as => :attend_by_email
  post 'cancel_attend/:id(.:format)' => 'events#cancel_attend', :as => :cancel_attend
  get 'my_workshops' => 'workshops#my_workshops', :as => :my_workshops

  get 'my_venues(.:format)' => 'venues#my_venues', :as => :my_venues
  resources :venues  
  resources :neighborhoods

  resources :locations, :only => [:update]
  resources :sightings, :only => [:index]

  resources :notifications, :only => [:index, :show] do
    collection do
      post 'clear'
    end
  end
  
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener", as: 'letter_opener'
  end

  get '/tos' => 'application#tos', :as => :tos

  get 'about' => 'pages#about'
  namespace :admin do 
    get '' => 'dashboard#index', as: '/'
    get 'recent_activity' => 'dashboard#recent_activity', :as => :recent_activity
    resources :users
  end
  
  match '/404' => 'errors#not_found'
  match '/422' => 'errors#server_error'
  match '/500' => 'errors#server_error'
  
  root :to => 'pages#home'

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
