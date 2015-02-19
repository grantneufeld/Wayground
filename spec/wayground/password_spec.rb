require 'spec_helper'
require 'password'
require 'crypted_password'
require 'bcrypt'

module Wayground

  describe Password do
    describe "#initialize" do
      it "should save the given plain text password as a crypted password" do
        expect( Password.new('pass').crypted_password ).to be_a CryptedPassword
      end
    end

    describe "#==" do
      it "should call through to the crypted password" do
        expect_any_instance_of(CryptedPassword).to receive(:==).with('pass').and_return(true)
        Password.new('pass') == 'pass'
      end
    end
  end

end
