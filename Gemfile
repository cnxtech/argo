# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.1'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'almond-rails'
gem 'barby'
gem 'bootstrap-sass'
gem 'cancancan'
gem 'coderay'
gem 'config'
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'equivalent-xml', '>= 0.6.0' # For ignoring_attr_values() with arguments
gem 'eye' # NOTE: if eye is upgraded, see the note in the 'bin/eye' script about checking to see whether that script needs upgrading (which won't happen automatically).
gem 'faraday'
gem 'honeybadger', '~> 4.1'
gem 'jqgrid-jquery-rails'
gem 'jquery-ui-rails', '~> 5.0'
gem 'jquery-validation-rails'
gem 'mysql2', '~> 0.4.5'
gem 'net-sftp'
gem 'newrelic_rpm'
gem 'nokogiri', '~> 1.6'
gem 'prawn', '~> 1'
gem 'prawn-table'
gem 'rake'
gem 'retries'
gem 'ruby-prof'
gem 'rubyzip'
gem 'sprockets-es6'

# Stanford/Hydra related gems
gem 'blacklight', '~> 6.0'
gem 'blacklight-hierarchy'
gem 'dor-services', '~> 7.0'
gem 'dor-workflow-client', '~> 3.3'
gem 'mods_display'
gem 'okcomputer' # monitors application and its dependencies
gem 'responders', '~> 2.0'
gem 'rsolr'
gem 'sul_styles', '~> 0.3'

gem 'devise'
gem 'devise-remote-user', '~> 1.0'

# useful for debugging, even in prod
gem 'pry-byebug' # Adds step-by-step debugging and stack navigation capabilities to pry using byebug
gem 'pry-rails' # use pry as the rails console shell instead of IRB

group :test, :development do
  gem 'factory_bot_rails'
  gem 'http_logger', require: false # Change this to `true` to see all http requests logged
  gem 'pry-remote' # allows you to attach remote session to pry
  gem 'rails-controller-testing'
  gem 'rspec-rails', '~> 3.5'
  gem 'rubocop', '~> 0.60.0', require: false
  gem 'rubocop-rspec', '~> 1.31.0', require: false
  gem 'sqlite3', '~> 1.3.13'
end

group :development do
  gem 'rack-mini-profiler', require: false # used for performance profiling
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver' # for js testing
  gem 'simplecov', require: false
  gem 'webdrivers' # installs the chrome for selenium tests
  gem 'webmock', require: false
end

group :deployment do
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano3-delayed-job', '~> 1.0'
  gem 'dlss-capistrano', '~> 3.1'
end
