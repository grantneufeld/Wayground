require 'bcrypt'

module Wayground

  # Wrapper for crypted password values.
  class CryptedPassword
    attr_accessor :crypted_password

    # Initialize from a string or an existing CryptedPassword.
    def initialize(crypted_pass)
      self.crypted_password = crypted_pass
    end

    # Checks whether the given password string matches the one that was used
    # to create the crypted password.
    def ==(pass)
      BCrypt::Password.new(crypted_password.to_s) == pass
    end

    def to_s
      crypted_password.to_s
    end
  end

end
