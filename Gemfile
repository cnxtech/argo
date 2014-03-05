source "https://rubygems.org"
source "http://sul-gems.stanford.edu"


gem 'stanford-mods'
gem 'mods_display'
gem 'dor-services', ">= 4.4.9"
gem 'dor-workflow-service', '=1.4.1'
gem "druid-tools", "~> 0.3.0"
gem "moab-versioning", "=1.3.1"
gem 'rails', '3.2.17'
gem "blacklight", '~>3.7'
gem 'blacklight-hierarchy', "~> 0.0.3"
gem 'net-sftp'
gem 'rake'
gem 'about_page'
gem 'is_it_working-cbeer'
gem 'rack-webauth', :git => "https://github.com/sul-dlss/rack-webauth.git"
gem 'thin' # or mongrel
gem 'prawn', ">=0.12.0"
gem 'barby'
gem 'ruby-graphviz'
gem "solrizer-fedora"
gem "rsolr", :git => "https://github.com/sul-dlss/rsolr.git", :branch => "nokogiri"
gem "rsolr-client-cert", "~> 0.5.2"
gem 'confstruct', "~> 0.2.4"
gem "mysql2", "= 0.3.13"
gem "progressbar"
gem "haml"
gem "coderay"
gem "dalli"
gem "kgio"  
gem 'jettywrapper'
gem 'kaminari'
gem 'thread', :git => 'https://github.com/meh/ruby-thread.git'

group :test, :development do
  gem 'selenium-webdriver'
	gem 'unicorn'
  gem 'rspec-rails'
  gem 'capybara'
  gem "rack-test", :require => "rack/test"
	gem 'simplecov', :require => false
end

group :development do
  gem 'pry'
  gem 'ruby-prof'
  gem 'sqlite3'
end

group :assets do
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'jquery-rails', '=2.1.4'
  gem 'therubyracer', "~> 0.10.0" #, '0.11.0beta5'
  gem 'sass-rails', '~> 3.2.0'
  gem 'compass-rails', '~> 1.0.0'
  gem 'compass-susy-plugin', '~> 0.9.0'
end

group :production do
  gem 'squash_rails'
  gem 'squash_ruby'
end

group :development,:deployment do
  gem 'capistrano', '~>2'
  gem 'capistrano-ext'
  gem 'rvm-capistrano'
  gem 'lyberteam-devel', '>=1.0.0'
  gem 'lyberteam-gems-devel', '>=1.0.0'
	gem 'lyberteam-capistrano-devel', '>= 1.1.0'
  gem 'net-ssh-krb'
end
gem 'gssapi', :git => 'https://github.com/cbeer/gssapi.git'
