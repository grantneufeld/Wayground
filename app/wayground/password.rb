require 'bcrypt'
require 'crypted_password'

module Wayground

  # Handler for password strings to be crypted.
  class Password
    attr_accessor :crypted_password

    # Takes a plain-text string to be crypted.
    def initialize(pass)
      crypted_pass = bcrypt_password(pass)
      self.crypted_password = CryptedPassword.new(crypted_pass)
    end

    # Tests whether the given password string matches the one that was used
    # to create the crypted password.
    delegate :==, to: :crypted_password

    private

    def bcrypt_password(pass)
      BCrypt::Password.create(pass)
    end
  end

end
