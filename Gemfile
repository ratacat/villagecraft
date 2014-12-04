source 'https://rubygems.org'

# Sometime in the next year, upgrade to Rails 4, which shouldn't be very painful because we already use stong parameters in most places
gem 'rails', '3.2.17'

# For deployment and remote control of the server (e.g. cap deploy)
gem 'capistrano', '~> 2.15.5'

# Rake tasks and daemonization; all of our async code is in the daemon: lib/daemons/notifier.rb 
gem 'daemons-rails'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# HTTP requests
gem "typhoeus"

# XML parsing, used for KML processing (or maybe not used at all)
gem 'nokogiri'

# Postgres DB adapter
gem 'pg'

# authentication
gem 'devise'

# use of remote authentication providers like Facebook
gem 'omniauth'
gem 'omniauth-facebook'

# soft deletes
gem 'paranoia', '~> 1.0'

# syntactic sugar for form creation
gem 'simple_form'

# inline editing, used extensively on Workshops#edit
gem 'x-editable-rails', '1.5.2'

# centralized authentication and access control (see ability.rb); cancan is showing signs of being an abandoned project, consider replacing it with pundit
gem 'cancancan'

# date and time validation
gem 'validates_timeliness', '~> 3.0'

# url validation
gem "validate_url", :git => "git://github.com/bteitelb/validates_url.git"

# controller-based taining and filtering of parameters used for mass assignment
gem 'strong_parameters'

# strip leading/trailing spaces; turn empty strings to nil, etc
gem 'attribute_normalizer'

# used to normalize domains to their top-level domain name
gem 'public_suffix'

# API access to geocoding services (we are using Google's); see geocoded_by and reverse_geocoded_by in the Location model
gem 'geocoder'

# generate and retrieve maps from the Google static maps service
gem 'googlestaticmap'

# get timezone from lon/lat; used to assign a TZ to each Location
gem 'google_timezone'

# unique IDs for records (has_uuid in models)
gem 'uuidtools'

# activity tracking for models (this is what's behind the feeds)
gem 'public_activity'

# access the S3 API from Ruby
gem 'aws-sdk'

# attachment handling (uploaded photos)
gem "paperclip", "~> 3.0"

# fancy image optimization (requires a bunch of binaries)
gem 'image_optim'
=begin
sudo yum install -y advancecomp gifsicle jhead libjpeg optipng jpegoptim
cd /tmp
curl -O http://downloads.sourceforge.net/project/pmt/pngcrush/1.7.73/pngcrush-1.7.73.tar.xz
tar xvf pngcrush-1.7.73.tar.gz
cd pngcrush-1.7.73
make && sudo cp -f pngcrush /usr/local/bin
=end
gem 'paperclip-optimizer', :git => "git://github.com/janfoeh/paperclip-optimizer.git"

# state machine support for attendances (not really in use)
gem 'state_machine'

# convert markdown to HTML
gem 'bluecloth'

# self-descriptive natural language helpers
gem 'verbs'
gem 'possessive'

# access the Nexmo API from Ruby
gem 'nexmo'

# send email when there is an exception on the server
gem 'exception_notification'

# stripe payment system
# gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  # not used; I prefer to code directly in JavaScript
  gem 'coffee-rails', '~> 3.2.1'
  
  # compile Bootstrap asset files from LESS into CSS and include in the asset pipeline
  gem 'less-rails-bootstrap', '3.0.4'
  
  # awesome icons
  gem 'font-awesome-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  # Javascript minimization
  gem 'uglifier', '>= 1.0.3'
  
  # compile Handlebars.js templates from app/assets/javascripts/templates and include them in the asset pipeline
  gem 'handlebars_assets'
end

# fancy printing in the console (pp)
gem 'awesome_print'

# include JQuery and rails-ujs in assets
gem 'jquery-rails'

group :development do
  # a web server
  gem 'thin'
  
  # web server agnostic rack middleware for defining and applying rewrite rules; used in dev to rewrite system image paths to production; obsolete now that we have all images on S3; FIXME DEADCODE
  gem 'rack-rewrite'
  
  # generate test data from old db:seed task
  gem 'factory_girl_rails'
  
  # unused test support
  gem 'rspec-rails', '~> 2.13'
  
  # start / stop / restart unicorn web servers through Capistrano
  gem 'capistrano-unicorn', :require => false
  
  # handle email in development, reading it through the admin dash (you still need to run the notifier to make sure email is sent)
  gem 'letter_opener_web', '~> 1.1.0'
  
  # debugging info and textmate links in browser on exception
  gem 'rails-footnotes', '4.1.0'
  
  # turns off the Rails asset pipeline log
  gem 'quiet_assets'
  
  # To use debugger
  # If uncommenting gem 'debugger' doesn't work, try first uncommenting the following two lines and doing:
  # pushd `bundle show debugger-ruby_core_source`; rake add_source --trace VERSION=1.9.3-rc1; pushd
  # gem 'archive-tar-minitar'
  # gem 'debugger-ruby_core_source'
  # OR, you might want to install the gem manually from the command line like this:
  # gem install debugger -- --with-ruby-include=~/.rbenv/versions/1.9.3-p448/include/ruby-1.9.1/ruby
  gem 'pry'
end

group :production do
  # monitor the notifier daemon, restarting it as necessary and sending email (see god.rb); could/should also monitor the unicorns
  gem 'god'
  
  # embedded V8 Javascript interpreter
  gem 'therubyracer'
  
  # run JavaScript code from Ruby
  gem 'execjs'
  
  # the webserver; consider switching to puma
  gem 'unicorn'
  
  # Google analytics for all pages
  gem 'rack-google_analytics', :require => "rack/google_analytics"
end

group :test do
  gem 'capybara', '1.1.2'
  gem 'simplecov', :require => false
end

group :staging do
  gem 'sanitize_email'
end
# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

#event tracking & user communication
gem 'intercom-rails'
gem 'intercom'

gem 'will_paginate'