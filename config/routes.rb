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
  resources :e, :controller => :events, :as => :events do
    resources :comments
  end
  resources :meetings, :only => [:update, :show]

  post 'activities/fetch' => 'activities#fetch', :as => :fetch_activities
  post 'activities/more' => 'activities#more', :as => :more_activities
  
  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks", :registrations => "registrations" }
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

#          users_controller_users GET      /users_controller/users(.:format)        users_controller#users
#               manage_workshop GET      /w/:id/manage(.:format)                  workshops#manage
#       reruns_partial_workshop GET      /w/:id/reruns_partial(.:format)          workshops#reruns_partial
#         upload_photo_workshop          /w/:id/upload_photo(.:format)            workshops#upload_photo
#       auto_add_rerun_workshop POST     /w/:id/auto_add_rerun(.:format)          workshops#auto_add_rerun
# simple_index_partial_workshop GET      /w/:id/simple_index_partial(.:format)    workshops#simple_index_partial
#     manage_attendees_workshop GET      /w/:id/manage_attendees(.:format)        workshops#manage_attendees
#        sms_attendees_workshop POST     /w/:id/sms_attendees(.:format)           workshops#sms_attendees
#                     workshops GET      /w(.:format)                             workshops#index
#                               POST     /w(.:format)                             workshops#create
#                  new_workshop GET      /w/new(.:format)                         workshops#new
#                 edit_workshop GET      /w/:id/edit(.:format)                    workshops#edit
#                      workshop GET      /w/:id(.:format)                         workshops#show
#                               PUT      /w/:id(.:format)                         workshops#update
#                               DELETE   /w/:id(.:format)                         workshops#destroy
#            oldstyle_workshops GET      /workshops(.:format)                     workshops#index
#                               POST     /workshops(.:format)                     workshops#create
#         new_oldstyle_workshop GET      /workshops/new(.:format)                 workshops#new
#        edit_oldstyle_workshop GET      /workshops/:id/edit(.:format)            workshops#edit
#             oldstyle_workshop GET      /workshops/:id(.:format)                 workshops#show
#                               PUT      /workshops/:id(.:format)                 workshops#update
#                               DELETE   /workshops/:id(.:format)                 workshops#destroy
#                         image GET      /images/:id(.:format)                    images#show
#                               DELETE   /images/:id(.:format)                    images#destroy
#                    add_review POST     /w/:id/reviews(.:format)                 reviews#create
#           reviews_by_workshop GET      /w/:id/reviews(.:format)                 reviews#index
#                   plus_review POST     /reviews/:id/plus(.:format)              reviews#plus
#                  minus_review POST     /reviews/:id/minus(.:format)             reviews#minus
#                       reviews GET      /reviews(.:format)                       reviews#index
#                               POST     /reviews(.:format)                       reviews#create
#                        review DELETE   /reviews/:id(.:format)                   reviews#destroy
#                     attendees GET      /events/:id/attendees(.:format)          events#attendees
#                confirm_attend POST     /events/:id/confirm(.:format)            events#confirm
#               accept_attendee GET      /events/:id/accept_attendee(.:format)    events#accept_attendee
#                  manage_event GET      /events/:id/manage(.:format)             events#manage_attendees
#                    lock_event POST     /events/:id/lock(.:format)               events#lock
#                  unlock_event POST     /events/:id/unlock(.:format)             events#unlock
#                 sms_attendees POST     /events/:id/sms_attendees(.:format)      events#sms_attendees
#                event_comments GET      /e/:event_id/comments(.:format)          comments#index
#                               POST     /e/:event_id/comments(.:format)          comments#create
#             new_event_comment GET      /e/:event_id/comments/new(.:format)      comments#new
#            edit_event_comment GET      /e/:event_id/comments/:id/edit(.:format) comments#edit
#                 event_comment GET      /e/:event_id/comments/:id(.:format)      comments#show
#                               PUT      /e/:event_id/comments/:id(.:format)      comments#update
#                               DELETE   /e/:event_id/comments/:id(.:format)      comments#destroy
#                        events GET      /e(.:format)                             events#index
#                               POST     /e(.:format)                             events#create
#                     new_event GET      /e/new(.:format)                         events#new
#                    edit_event GET      /e/:id/edit(.:format)                    events#edit
#                         event GET      /e/:id(.:format)                         events#show
#                               PUT      /e/:id(.:format)                         events#update
#                               DELETE   /e/:id(.:format)                         events#destroy
#                       meeting GET      /meetings/:id(.:format)                  meetings#show
#                               PUT      /meetings/:id(.:format)                  meetings#update
#              fetch_activities POST     /activities/fetch(.:format)              activities#fetch
#               more_activities POST     /activities/more(.:format)               activities#more
#              new_user_session GET      /users/sign_in(.:format)                 devise/sessions#new
#                  user_session POST     /users/sign_in(.:format)                 devise/sessions#create
#          destroy_user_session DELETE   /users/sign_out(.:format)                devise/sessions#destroy
#       user_omniauth_authorize GET|POST /users/auth/:provider(.:format)          omniauth_callbacks#passthru {:provider=>/facebook/}
#        user_omniauth_callback GET|POST /users/auth/:action/callback(.:format)   omniauth_callbacks#(?-mix:facebook)
#                 user_password POST     /users/password(.:format)                devise/passwords#create
#             new_user_password GET      /users/password/new(.:format)            devise/passwords#new
#            edit_user_password GET      /users/password/edit(.:format)           devise/passwords#edit
#                               PUT      /users/password(.:format)                devise/passwords#update
#      cancel_user_registration GET      /users/cancel(.:format)                  registrations#cancel
#             user_registration POST     /users(.:format)                         registrations#create
#         new_user_registration GET      /users/sign_up(.:format)                 registrations#new
#        edit_user_registration GET      /users/edit(.:format)                    registrations#edit
#                               PUT      /users(.:format)                         registrations#update
#                               DELETE   /users(.:format)                         registrations#destroy
#             admin_mode_toggle POST     /admin_mode_toggle(.:format)             sessions#admin_mode_toggle
#              hostify_me_users GET      /users/hostify_me(.:format)              users#hostify_me
#                         users GET      /users(.:format)                         users#index
#                               POST     /users(.:format)                         users#create
#                      new_user GET      /users/new(.:format)                     users#new
#                     edit_user GET      /users/:id/edit(.:format)                users#edit
#                          user GET      /users/:id(.:format)                     users#show
#                               PUT      /users/:id(.:format)                     users#update
#                               DELETE   /users/:id(.:format)                     users#destroy
#                 edit_settings GET      /settings(/:id)(.:format)                users#edit_settings
#               update_settings PUT      /update_settings(/:id)(.:format)         users#update_settings
#                        attend          /attend/:id(.:format)                    events#attend
#               attend_by_email POST     /attend_by_email/:id(.:format)           events#attend_by_email
#                 cancel_attend POST     /cancel_attend/:id(.:format)             events#cancel_attend
#                  my_workshops GET      /my_workshops(.:format)                  workshops#my_workshops
#                     my_venues GET      /my_venues(.:format)                     venues#my_venues
#             get_venue_address GET      /get_venue_address/:id(.:format)         venues#get_venue_address
#                        venues GET      /venues(.:format)                        venues#index
#                               POST     /venues(.:format)                        venues#create
#                     new_venue GET      /venues/new(.:format)                    venues#new
#                    edit_venue GET      /venues/:id/edit(.:format)               venues#edit
#                         venue GET      /venues/:id(.:format)                    venues#show
#                               PUT      /venues/:id(.:format)                    venues#update
#                               DELETE   /venues/:id(.:format)                    venues#destroy
#        counties_neighborhoods GET      /neighborhoods/counties(.:format)        neighborhoods#counties
#                 neighborhoods GET      /neighborhoods(.:format)                 neighborhoods#index
#                               POST     /neighborhoods(.:format)                 neighborhoods#create
#              new_neighborhood GET      /neighborhoods/new(.:format)             neighborhoods#new
#             edit_neighborhood GET      /neighborhoods/:id/edit(.:format)        neighborhoods#edit
#                  neighborhood GET      /neighborhoods/:id(.:format)             neighborhoods#show
#                               PUT      /neighborhoods/:id(.:format)             neighborhoods#update
#                               DELETE   /neighborhoods/:id(.:format)             neighborhoods#destroy
#                      location PUT      /locations/:id(.:format)                 locations#update
#                     sightings GET      /sightings(.:format)                     sightings#index
#                      messages GET      /messages(.:format)                      messages#index
#                               POST     /messages(.:format)                      messages#create
#                   new_message GET      /messages/new(.:format)                  messages#new
#                       message GET      /messages/:id(.:format)                  messages#show
#           clear_notifications POST     /notifications/clear(.:format)           notifications#clear
#                 notifications GET      /notifications(.:format)                 notifications#index
#                  notification GET      /notifications/:id(.:format)             notifications#show
#                 letter_opener          /letter_opener                           LetterOpenerWeb::Engine
#                           tos GET      /tos(.:format)                           application#tos
#                           faq GET      /faq(.:format)                           pages#faq
#                         admin GET      /admin(.:format)                         admin/dashboard#index
#         admin_recent_activity GET      /admin/recent_activity(.:format)         admin/dashboard#recent_activity
#     admin_send_system_mailing          /admin/send_system_mailing(.:format)     admin/dashboard#send_system_mailing
#                   admin_users GET      /admin/users(.:format)                   admin/users#index
#                               POST     /admin/users(.:format)                   admin/users#create
#                new_admin_user GET      /admin/users/new(.:format)               admin/users#new
#               edit_admin_user GET      /admin/users/:id/edit(.:format)          admin/users#edit
#                    admin_user GET      /admin/users/:id(.:format)               admin/users#show
#                               PUT      /admin/users/:id(.:format)               admin/users#update
#                               DELETE   /admin/users/:id(.:format)               admin/users#destroy
#                                        /404(.:format)                           errors#not_found
#                                        /422(.:format)                           errors#server_error
#                                        /500(.:format)                           errors#server_error
#                          home GET      /home-workshops(.:format)                pages#home
#              home_events_page GET      /home/:page(.:format)                    pages#home_events_page
#                          root          /                                        pages#home_events

# Routes for LetterOpenerWeb::Engine:
# clear_letters DELETE /clear(.:format)                 letter_opener_web/letters#clear
#       letters GET    /                                letter_opener_web/letters#index
#        letter GET    /:id(/:style)(.:format)          letter_opener_web/letters#show
#               GET    /:id/attachments/:file(.:format) letter_opener_web/letters#attachment
end
