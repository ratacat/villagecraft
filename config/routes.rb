Villagecraft::Application.routes.draw do
  get "users_controller/users"

  resources :w, controller: 'workshops', as: 'workshops' do
    member do
      get 'manage'
      get 'reruns_partial'
      match 'upload_photo'
      post 'auto_add_rerun'
      get 'simple_index_partial'
      get 'manage_attendees'
      post 'sms_attendees'
    end
  end
  resources :workshops, as: 'oldstyle_workshops'

  resources :images, only: [:destroy, :show]

  post 'w/:id/reviews(.:format)' => 'reviews#create', :as => :add_review
  get 'w/:id/reviews(.:format)' => 'reviews#index', :as => :reviews_by_workshop
  #post 'w/:id/plus_rating(.:format)' => 'reviews#plus_rating', :as => :plus_rating_review
  #post 'w/:id/minus_rating(.:format)' => 'reviews#minus_rating', :as => :minus_rating_review

  resources :reviews, only: [:index, :destroy, :create] do
    member do
      post :plus
      post :minus
    end
  end

  get 'events/:id/attendees(.:format)' => 'events#attendees', :as => :attendees
  post 'events/:id/confirm(.:format)' => 'events#confirm', :as => :confirm_attend
  get 'events/:id/accept_attendee(.:format)' => 'events#accept_attendee', :as => :accept_attendee
  get 'events/:id/manage' => 'events#manage_attendees', :as => :manage_event
  post 'events/:id/lock' => 'events#lock', :as => :lock_event
  post 'events/:id/unlock' => 'events#unlock', :as => :unlock_event
  post 'events/:id/sms_attendees' => 'events#sms_attendees', :as => :sms_attendees
  resources :e, :controller => :events, :as => :events
  resources :meetings, :only => [:update, :show]

  # resources :charges commented out to disable stripe

  post 'activities/fetch' => 'activities#fetch', :as => :fetch_activities
  post 'activities/more' => 'activities#more', :as => :more_activities
  
  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks", :registrations => "registrations", :confirmations => "confirmations" }
  post 'admin_mode_toggle' => 'sessions#admin_mode_toggle', :as => :admin_mode_toggle
  
  resources :users do
    collection do
      get 'hostify_me'
    end
  end
  get 'settings(/:id)' => 'users#edit_settings', :as => :edit_settings
  put 'update_settings(/:id)' => 'users#update_settings', :as => :update_settings
    
  match 'attend/:id(.:format)' => 'events#attend', :as => :attend
  post 'attend_by_email/:id(.:format)' => 'events#attend_by_email', :as => :attend_by_email
  post 'cancel_attend/:id(.:format)' => 'events#cancel_attend', :as => :cancel_attend
  get 'my_workshops' => 'workshops#my_workshops', :as => :my_workshops

  get 'my_venues(.:format)' => 'venues#my_venues', :as => :my_venues
  get 'get_venue_address/:id' => 'venues#get_venue_address', :as => :get_venue_address
  resources :venues  
  resources :neighborhoods do
    collection do
      get 'counties'
    end
  end

  resources :locations, :only => [:update]
  resources :sightings, :only => [:index]
  resources :messages, :only => [:index, :show, :new, :create]

  resources :notifications, :only => [:index, :show] do
    collection do
      post 'clear'
    end
  end
  
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener", as: 'letter_opener'
  end

  get '/tos' => 'application#tos', :as => :tos

  get 'faq' => 'pages#faq'
  namespace :admin do 
    get '' => 'dashboard#index', as: '/'
    get 'recent_activity' => 'dashboard#recent_activity', :as => :recent_activity
    match 'send_system_mailing' => 'dashboard#send_system_mailing', :as => :send_system_mailing
    resources :users
  end
  
  match '/404' => 'errors#not_found'
  match '/422' => 'errors#server_error'
  match '/500' => 'errors#server_error'

  # get '/new-home' => 'pages#home_events', :as => :home_events
  get '/home-workshops' => 'pages#home', :as => :home
  get '/home/:page' => 'pages#home_events_page', :as => :home_events_page
  # root :to => 'pages#home'
  root :to => 'pages#home_events'


  get 'terms_of_use' => 'pages#villagecraft_terms_of_use'
  get 'privacy_policy' => 'pages#villagecraft_privacy_policy'
  get 'what_is_stripe' => 'pages#what_is_stripe'

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
