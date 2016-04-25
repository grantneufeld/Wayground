source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.6'

# Use postgresql as the database for Active Record
gem 'pg', '~> 0.15'
#gem 'pg_search'
#gem 'queue_classic', '2.0.0rc12'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0', require: false

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0', require: false

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0', require: false

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0', require: false

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', require: false, group: :doc

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# deprecated compatibility
gem 'protected_attributes', '>= 1.0.5'

# To support OAuth access
gem 'omniauth', '>= 1.1.0'
gem 'omniauth-facebook', '>= 1.3.0'
gem 'omniauth-twitter', '>= 0.0.11'

gem 'tzinfo', '>= 0.3.38'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # code analysis tools:
  gem 'brakeman', require: false # http://brakemanscanner.org/
  gem 'cane', require: false # https://github.com/square/cane
  gem 'churn', require: false # https://github.com/danmayer/churn
  gem 'flay', require: false # https://github.com/seattlerb/flay
  gem 'flog', require: false # https://github.com/seattlerb/flog
  gem 'rails_best_practices', require: false # https://github.com/railsbp/rails_best_practices
  gem 'reek', require: false # https://github.com/troessner/reek/wiki
  gem 'roodi', require: false # https://github.com/martinjandrews/roodi
  gem 'tailor', require: false # https://github.com/turboladen/tailor
  # gem validation
  gem 'bundler-audit', require: false # https://github.com/postmodern/bundler-audit
end

group :test do
  # specs/testing:
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
  gem 'autotest-rails', '>= 4.1.2', require: false
  gem 'autotest-fsevent', '>= 0.2.8', require: false
  # data factories:
  gem 'factory_girl', '>= 3.5.0', require: false
  gem 'factory_girl_rails', '>= 3.5.0', require: false
  # miscellaneous:
  gem 'capybara', require: false
  gem 'chronic', '>= 0.8.0', require: false
  gem 'database_cleaner', '>= 0.8.0', require: false
  gem 'timecop', '>= 0.5.4', require: false
end
