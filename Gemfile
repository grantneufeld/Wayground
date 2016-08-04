source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0'

# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# gem 'pg_search'
# gem 'queue_classic', '2.0.0rc12'

# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# To support OAuth access
gem 'omniauth', '>= 1.1.0'
gem 'omniauth-facebook', '>= 1.3.0'
gem 'omniauth-twitter', '>= 0.0.11'

gem 'tzinfo', '>= 0.3.38'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # code analysis tools:
  gem 'brakeman', require: false # http://brakemanscanner.org/
  gem 'churn', require: false # https://github.com/danmayer/churn
  gem 'flay', require: false # https://github.com/seattlerb/flay
  gem 'rails_best_practices', require: false # https://github.com/railsbp/rails_best_practices
  gem 'reek', require: false # https://github.com/troessner/reek/wiki
  gem 'rubocop', require: false # https://github.com/bbatsov/rubocop
  # gem validation
  gem 'bundler-audit', require: false # https://github.com/postmodern/bundler-audit
end

group :test do
  # specs/testing:
  gem 'rails-controller-testing'
  gem 'rspec-rails', '~> 3.0', require: false
  gem 'rspec-activemodel-mocks', require: false
  gem 'rspec-autotest', require: false, github: 'grantneufeld/rspec-autotest'
  gem 'rspec-html-matchers', require: false
  # features / acceptance tests:
  gem 'cucumber', '>= 1.2.1', require: false
  gem 'cucumber-rails', '>= 1.3.0', require: false
  gem 'launchy', '>= 2.1.2', require: false # for opening saved html files in browser for review
  gem 'pickle', require: false
  # code test coverage analysis:
  gem 'simplecov', '>= 0.7.1', require: false
  gem 'simplecov-html', '>= 0.7.1', require: false
  # continuous testing:
  gem 'autotest-fsevent', '>= 0.2.8', require: false
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
