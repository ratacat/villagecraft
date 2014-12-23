Villagecraft::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  #precompile images
  config.assets.precompile += %w[*.png *.jpg *.jpeg *.gif] 

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store  # FIXME: consider using memcache someday
  config.cache_store = :file_store, './tmp/cache'

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  config.assets.precompile += %w( hosts_only.js hosts_only.css )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address => 'smtp.sendgrid.net',
    :port => 587,
    :authentication => :plain,
    :enable_starttls_auto => true,
    :user_name => ENV["SENDGRID_USERNAME"],
    :password => ENV["SENDGRID_PASSWORD"]
  }

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.2
  
  config.facebook_app_id = ENV["FACEBOOK_DEV_APP_ID"]
  config.facebook_app_secret = ENV["FACEBOOK_DEV_APP_SECRET"]
  
  config.middleware.use ExceptionNotification::Rack,
    :email => {
      :email_prefix => "[Villagecraft Exception] ",
      :sender_address => %{"Villagecraft Exception Notifier" <notifications@villagecraft.org>},
      :exception_recipients => %w{ben@teitelbaum.us cheshire.in.darkness@gmail.com anthony@villagecraft.org}
    }
end

# Catching all emails with sanizite gem
STAGING_EMAIL = 'antmachine.test@gmail.com'
Mail.register_interceptor(SanitizeEmail::Bleach.new(:engage => true))
SanitizeEmail::Config.configure do |config|
  config[:sanitized_to] =         "#{STAGING_EMAIL}"
  config[:sanitized_cc] =         "#{STAGING_EMAIL}"
  config[:sanitized_bcc] =        "#{STAGING_EMAIL}"
  # run/call whatever logic should turn sanitize_email on and off in this Proc:
  config[:activation_proc] =      Proc.new { %w(staging).include?(Rails.env) }
  config[:use_actual_email_prepended_to_subject] = true         # or false
  config[:use_actual_environment_prepended_to_subject] = true   # or false
  config[:use_actual_email_as_sanitized_user_name] = true       # or false
end