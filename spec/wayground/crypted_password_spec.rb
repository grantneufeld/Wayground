require 'spec_helper'
require 'crypted_password'
require 'bcrypt'

module Wayground

  describe CryptedPassword do
    describe "#initialize" do
      it "should save the given crypted password" do
        expect( CryptedPassword.new('crypted-pass').crypted_password ).to eq 'crypted-pass'
      end
    end

    describe "#==" do
      it "should return true when the string matches the one used to generate the crypted password" do
        pass = 'test pass'
        expect( (CryptedPassword.new(BCrypt::Password.create(pass)) == pass) ).to be_truthy
      end
      it "should return false when string does not match the one used to generated the crypted password" do
        expect( (CryptedPassword.new(BCrypt::Password.create('pass1')) == 'pass2') ).to be_falsey
      end
    end

    describe "#to_s" do
      it "should return the crypted pass string" do
        expect( CryptedPassword.new('pass string').to_s ).to eq 'pass string'
      end
    end
  end

end
