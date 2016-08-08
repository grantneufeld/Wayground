require 'securerandom'
require 'cookie_token'

module Wayground

  # Used to set a token that can act as an identifier for “remembering” an object.
  # E.g., used in a cookie for cookie-based login of users.
  #
  # Requires the object being remembered to have a “tokens” association. (called the `remember` attribute.)
  # Requires the tokens association to support the `first` method.
  # Requires the tokens association to support the `create!` method.
  # Requires the tokens associated class to have the `exists?` method (as per ActiveRecord).
  class Rememberer
    attr_accessor :remember, :token

    # takes hash of parameters:
    # remember: the thing to be remembered (e.g., a User)
    # token: the token used to remember it (a new one will be generated if blank)
    def initialize(remember: nil, token: nil)
      self.remember = remember
      self.token = token
    end

    def cookie_token
      self.token ||= existing_token || create_token_for_cookie!
      Wayground::CookieToken.new(remember: remember, token: token.token).to_s
    end

    protected

    def existing_token
      remember.tokens.first
    end

    def create_token_for_cookie!
      token_string = new_token
      self.token = remember.tokens.create!(token: token_string)
    end

    # Generate a unique token to be used to remember the remember for future sessions.
    def new_token
      klass = token_class
      token_string = ''
      loop do
        token_string = random_token_string
        break unless klass.exists?(token: token_string.to_s)
      end
      token_string
    end

    def random_token_string
      SecureRandom.urlsafe_base64(64 + rand(64))[0..126]
    end

    def token_class
      remember.class.reflect_on_association(:tokens).klass
    end
  end
end
