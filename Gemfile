source 'https://rubygems.org'

gem 'rails', '3.2.17'
gem 'capistrano', '~> 2.15.5'

gem 'daemons-rails'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'nokogiri'
gem 'pg'

gem 'devise'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'paranoia', '~> 1.0'

gem 'simple_form'
gem 'x-editable-rails', '1.5.2'
gem 'cancan'
gem 'validates_timeliness', '~> 3.0'
gem "validate_url", :git => "git://github.com/bteitelb/validates_url.git"

gem 'strong_parameters'
gem 'attribute_normalizer'

gem 'public_suffix'

gem 'geocoder'
gem 'googlestaticmap'

gem 'google_timezone'
gem 'uuidtools'

gem 'public_activity'

gem 'aws-sdk'
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

gem 'state_machine'
gem 'bluecloth'

gem 'verbs'
gem 'possessive'
gem 'nexmo'

gem 'exception_notification'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails', '~> 3.2.1'
  gem 'less-rails-bootstrap', :git => 'git://github.com/metaskills/less-rails-bootstrap.git'
  gem 'font-awesome-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
  gem 'handlebars_assets'
end

gem 'awesome_print'

gem 'jquery-rails'

group :development do
  gem 'thin'
  gem 'rack-rewrite'
  gem 'factory_girl_rails'
  gem 'rspec-rails', '~> 2.13'
  gem 'capistrano-unicorn', :require => false
  gem 'letter_opener_web', '~> 1.1.0'
  gem 'rails-footnotes', '>= 3.7.9'
  gem 'quiet_assets'
  
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
  gem 'god'
  gem 'therubyracer'
  gem 'execjs'
  gem 'unicorn'
  gem 'rack-google_analytics', :require => "rack/google_analytics"
end

group :test do
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
