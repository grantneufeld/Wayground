module Wayground

  # Turns a token for an object to remember (i.e., User) into a string usable in cookies.
  # Usage: CookieToken.new(remember: user, token: token_string).to_s
  class CookieToken
    attr_accessor :id, :token

    def initialize(params={})
      self.id = params[:remember].id
      self.token = params[:token]
    end

    # Return a string with the token and id of the object to remember, for use in cookies.
    def to_s
      "#{token}/#{id}"
    end
  end

end
