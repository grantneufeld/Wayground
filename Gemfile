source 'http://rubygems.org'

gem 'rails', '3.0.11'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'sqlite3', '>= 1.3.3'

# Deploy with Capistrano
gem 'capistrano', :require => false #, '2.12.0'

gem 'bcrypt-ruby' #, '2.1.4'
gem 'omniauth', '~> 1.1.0'
gem 'omniauth-facebook', '~> 1.3.0'
gem 'omniauth-twitter', '>= 0.0.11'

gem 'rake', '>= 0.9.2'

group :development, :test do
  gem 'chronic', '>= 0.6.7'
  # metric_fu dropped because of messy dependencies interfering with some other gems
  #gem 'metric_fu', '>= 2.0.1', :require => false
  gem 'rails_best_practices', '>= 1.9.1', :require => false
  # FIXME: ruby-debug19 breaks under ruby 1.9.3. There is apparently a fix for the gem, but it’s not yet on the gem servers. The following are some commented-out attempts I made to get this working. Until this is fixed, we’re stuck with ruby 1.9.3, or no debugging.
  ## FIXME: using a manually installed linecache19 0.5.13 from http://rubyforge.org/frs/?group_id=8883
  #gem 'linecache19', '0.5.13', :require => 'linecache19', :path => 'vendor/gems'
  ##  :git => 'git://github.com/mark-moseley/linecache.git'
  #gem 'ruby-debug-base19x', '0.11.30.pre7', :require => 'ruby-debug-base'
  ## FIXME: using a manually installed ruby-debug19 0.11.26 from http://rubyforge.org/frs/?group_id=8883
  #gem 'ruby-debug19', '0.11.26', :require => 'ruby-debug', :path => 'vendor/gems'
  ##  :git => 'git://github.com/mark-moseley/ruby-debug.git'
  gem 'ruby-debug19', '>= 0.11.6', :require => 'ruby-debug'
end

group :test do
  gem 'autotest-fsevent', '>= 0.2.8'
  gem 'autotest-growl', '>= 0.2.9'
  gem 'autotest-rails', '>= 4.1.2'
  gem 'capybara'
  gem 'cucumber', '>= 1.2.0'
  gem 'cucumber-rails', '~> 1.3.0'
  gem 'database_cleaner', '~> 0.7.2'
  gem 'factory_girl', '~> 3.2.0'
  gem 'factory_girl_rails', '~> 3.2.0'
  gem 'launchy', '>= 2.1.0' # for opening saved html files in browser for review
  gem 'pickle' #, '0.4.7', :require => false # additions for Cucumber
  gem 'rspec', '~> 2.10.0' #, '2.5.0' # core testing framework
  gem 'rspec-rails', '~> 2.10.1' #, '2.5.0'
  gem 'simplecov', '>= 0.6.4', :require => false
  gem 'simplecov-html', '>= 0.4.3', :require => false
  gem 'timecop', '>= 0.3.5'
  gem 'ZenTest', '>= 4.8.0', :require => false
end
