Villagecraft::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true  # set to false to test dynamic not_found and server_error views
  config.action_controller.perform_caching = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  #in production :host must be set to actual host
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :letter_opener_web
  config.action_mailer.default_url_options = { :host => 'localhost', :port => 3000 }
  
  config.facebook_app_id = ENV["FACEBOOK_DEV_APP_ID"]
  config.facebook_app_secret = ENV["FACEBOOK_DEV_APP_SECRET"]

  # Precompile handlebars.js templates
  config.assets.precompile += %w( hosts_only.js hosts_only.css ./templates/* )
  
  # Adding Webfonts to the Asset Pipeline
  config.assets.precompile << Proc.new { |path|
    if path =~ /\.(eot|svg|ttf|woff)\z/
      true
    end
  }
  
  config.middleware.insert_before(Rack::Lock, Rack::Rewrite) do
    r301 %r{/system/images/(.*)}, 'https://villagecraft.org/system/images/$1'
  end
end
