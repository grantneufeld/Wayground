# Necessary evil thing: Rack::Test sports as default host
# "example.org", but Webrat and Ruby on Rails's integration test
# classes use "example.com"; this discrepancy leads to Webrat not
# being able to follow simple internal redirects.
#
# Drop in in features/support/

module Rack
  module Test
    DEFAULT_HOST = "example.com"
  end
end

# Source:
# https://gist.github.com/729996
# Described at:
# http://baldowl.github.com/2010/12/06/coercing-cucumber-and-webrat-to-cooperate.html
