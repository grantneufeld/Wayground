module Wayground

  # Takes a cookie token string (“token/id”) and extracts the “id” and “token”.
  # You can then use those to find a RememberToken for a given object (by id).
  # Usage:
  #   user = User.find(ParsedCookieToken.new(cookie_token).id)
  #   token = ParsedCookieToken.new(cookie_token).token
  class ParsedCookieToken
    attr_accessor :token, :id

    # The supplied token string does not match the required cookie token format.
    class InvalidToken < RuntimeError; end

    def initialize(cookie_token)
      raise InvalidToken unless cookie_token
      token_parsed = cookie_token.match(%r{\A(?<token>.+)/(?<id>[0-9]+)\z})
      raise InvalidToken unless token_parsed
      self.token = token_parsed[:token]
      self.id = token_parsed[:id].to_i
    end
  end

end
