# encoding: utf-8

# Configuration and adjustments to Capybara for use with Cucumber.

# this might be extraneous:
#require 'capybara/rails'

# Capybara defaults to XPath selectors rather than Webrat's default of CSS3. In
# order to ease the transition to Capybara we set the default here. If you'd
# prefer to use XPath just remove this line and adjust any selectors in your
# steps to use the XPath syntax.
Capybara.default_selector = :css

# Get Capybara to play nice with Rack - use the same default host domain.
# Issue: https://github.com/jnicklas/capybara/issues/36
#Capybara.default_host = 'example.org'
# this monkey-patch via: https://gist.github.com/951208
#class Capybara::RackTest::Browser
#  def build_rack_mock_session
#    Rack::MockSession.new(app, URI.parse(current_host).host)
#  end
#end

# You can change which driver Capybara uses for JavaScript:
#Capybara.javascript_driver = :culerity
# “There are also explicit @selenium, @culerity and @rack_test tags set up for you.”
