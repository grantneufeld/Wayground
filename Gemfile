source 'https://rubygems.org'

gem 'rails', '3.2.11'
# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'sqlite3', '>= 1.3.3'

gem 'jquery-rails'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '>= 3.0.0'
# To support OAuth access
gem 'omniauth', '~> 1.1.0'
gem 'omniauth-facebook', '~> 1.3.0'
gem 'omniauth-twitter', '>= 0.0.11'

gem 'tzinfo', '>= 0.3.33'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 3.2.5'
  gem 'coffee-rails', '~> 3.2.1'
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platform => :ruby
  gem 'uglifier', '>= 1.2.6'
end

group :development do
  # code analysis tools:
  gem 'brakeman', require: false # http://brakemanscanner.org/
  gem 'churn', require: false # https://github.com/danmayer/churn
  gem 'flay', require: false # https://github.com/seattlerb/flay
  gem 'flog', require: false # https://github.com/seattlerb/flog
  gem 'rails_best_practices', require: false # https://github.com/railsbp/rails_best_practices
  gem 'reek', require: false # https://github.com/troessner/reek/wiki
end

group :development, :test do
  gem 'debugger'
end

group :test do
  # specs/testing:
  gem 'rspec', '>= 2.11.0', require: false # core testing framework
  gem 'rspec-rails', '>= 2.11.0', require: false
  # features / acceptance tests:
  gem 'cucumber', '>= 1.2.1', require: false
  gem 'cucumber-rails', '>= 1.3.0', require: false
  gem 'launchy', '>= 2.1.2', require: false # for opening saved html files in browser for review
  gem 'pickle', require: false
  # code test coverage analysis:
  gem 'simplecov', '>= 0.7.1', require: false
  gem 'simplecov-html', '>= 0.7.1', require: false
  # continuous testing:
  gem 'ZenTest', '>= 4.8.3', require: false
  gem 'autotest-fsevent', '>= 0.2.8', require: false
  gem 'autotest-growl', '>= 0.2.9', require: false
  gem 'autotest-rails', '>= 4.1.2', require: false
  # data factories:
  gem 'factory_girl', '>= 3.5.0', require: false
  gem 'factory_girl_rails', '>= 3.5.0', require: false
  # miscellaneous:
  gem 'capybara', require: false
  gem 'chronic', '>= 0.8.0', require: false
  gem 'database_cleaner', '>= 0.8.0', require: false
  gem 'timecop', '>= 0.5.4', require: false
end
