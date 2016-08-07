require_relative 'base'

module Wayground
  module Login

    # Handle logging in with a username and password.
    # Depends on the methods `user_class` and `user` from the superclass.
    # The user_class must have a `name` attribute.
    # The user_class must respond to `login_name_attribute`, returning the symbol for the login name field.
    # The user must respond to `password_hash`,
    # which should return a CryptedPassword-like object that accepts an equality check `==`.
    class PasswordLogin < Base
      attr_accessor :username, :password

      protected

      def post_initialize(username: nil, password: nil)
        self.username = username
        self.password = password
      end

      def find_user
        user = user_class.where(user_class.login_name_attribute => username).first!
        user = nil unless user.password_hash == password
        user
      end
    end

  end
end
