source 'https://rubygems.org'

gem 'rails', '3.2.6'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'sqlite3', '>= 1.3.3'

gem 'jquery-rails'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby' #, '2.1.4'
# To support OAuth access
gem 'omniauth', '~> 1.1.0'
gem 'omniauth-facebook', '~> 1.3.0'
gem 'omniauth-twitter', '>= 0.0.11'

# Deploy with Capistrano
gem 'capistrano', require: false #, '2.12.0'

#gem 'rake', '>= 0.9.2'

gem 'tzinfo', '>= 0.3.33'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platform => :ruby

  gem 'uglifier', '>= 1.0.3'
end

group :development, :test do
  # http://brakemanscanner.org/
  gem 'brakeman', '>= 1.6.2'
  gem 'chronic', '>= 0.6.7'
  # metric_fu dropped because of messy dependencies interfering with some other gems
  #gem 'metric_fu', '>= 2.0.1', require: false
  gem 'rails_best_practices', '>= 1.9.1', require: false
  gem 'ruby-debug19', '>= 0.11.6', require: 'ruby-debug'
end

group :test do
  gem 'autotest-fsevent', '>= 0.2.8'
  gem 'autotest-growl', '>= 0.2.9'
  gem 'autotest-rails', '>= 4.1.2'
  gem 'capybara'
  gem 'cucumber', '>= 1.2.0'
  gem 'cucumber-rails', '~> 1.3.0', require: false
  gem 'database_cleaner', '~> 0.7.2'
  gem 'factory_girl', '~> 3.3.0'
  gem 'factory_girl_rails', '~> 3.3.0'
  gem 'launchy', '>= 2.1.0' # for opening saved html files in browser for review
  gem 'pickle' #, require: false # additions for Cucumber
  gem 'rspec', '~> 2.10.0' # core testing framework
  gem 'rspec-rails', '~> 2.10.1'
  gem 'simplecov', '>= 0.6.4', require: false
  gem 'simplecov-html', '>= 0.4.3', require: false
  gem 'timecop', '>= 0.3.5'
  gem 'ZenTest', '>= 4.8.1', require: false
end
