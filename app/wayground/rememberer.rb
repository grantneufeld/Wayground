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
    # :remember => the thing to be remembered (e.g., a User)
    # :token => the token used to remember it (a new one will be generated if blank)
    def initialize(params={})
      self.remember = params[:remember]
      self.token = params[:token]
    end

    def cookie_token
      self.token ||= get_existing_token || create_token_for_cookie!
      Wayground::CookieToken.new(remember: remember, token: token.token).to_s
    end

    protected

    def get_existing_token
      remember.tokens.first
    end

    def create_token_for_cookie!
      token_string = get_new_token
      self.token = remember.tokens.create!(token: token_string)
    end

    # Generate a unique token to be used to remember the remember for future sessions.
    def get_new_token
      token_class = self.token_class
      begin
        token_string = get_random_token_string
      end while token_class.exists?(token: token_string.to_s)
      token_string
    end

    def get_random_token_string
      SecureRandom.urlsafe_base64(64 + rand(64))[0..126]
    end

    def token_class
      remember.class.reflect_on_association(:tokens).klass
    end

  end
end
