source 'https://rubygems.org'

gem 'rails', '3.2.13'
gem 'capistrano', '~> 2.15.5'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'

gem 'devise'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'paranoia', '~> 1.0'

gem 'simple_form'
gem 'validates_timeliness', '~> 3.0'
gem 'bootstrap-generators', '~> 2.3'
gem 'sass-rails',   '~> 3.2.3'

gem 'attribute_normalizer'

gem 'geocoder'
gem  'googlestaticmap'

gem 'google_timezone'
gem 'uuidtools'

gem 'public_activity'

gem "paperclip", "~> 3.0"

gem 'state_machine'

gem 'verbs'
gem 'zeroclipboard-rails'
gem 'nexmo'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails', '~> 3.2.1'
  gem 'bootstrap-sass', '~> 2.2.2.0'
  gem 'font-awesome-sass-rails', :git => 'git://github.com/pduersteler/font-awesome-sass-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
  gem 'handlebars_assets'
end

gem 'awesome_print'

gem 'jquery-rails'

group :development do
  gem 'factory_girl_rails', :require => false
  gem 'rspec-rails', '~> 2.13'
  gem 'capistrano-unicorn', :require => false
  gem "letter_opener"

  # To use debugger
  # If uncommenting gem 'debugger' doesn't work, try first uncommenting the following two lines and doing:
  # pushd `bundle show debugger-ruby_core_source`; rake add_source --trace VERSION=1.9.3-rc1; pushd
  # gem 'archive-tar-minitar'
  # gem 'debugger-ruby_core_source'
  # OR, you might want to install the gem manually from the command line like this:
  # gem install debugger -- --with-ruby-include=~/.rbenv/versions/1.9.3-p448/include/ruby-1.9.1/ruby
  gem 'debugger'
end

group :production do
  gem 'therubyracer'
  gem 'execjs'
  gem 'unicorn'
  gem 'rack-google_analytics', :require => "rack/google_analytics"
end

group :test do
  gem 'factory_girl_rails'
  gem 'capybara', '1.1.2'
  gem 'simplecov', :require => false
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'
