require 'spec_helper'
require 'login/password_login'
require_relative 'login_interface'

module Wayground
  module Login
    describe Wayground::Login::PasswordLogin do

      it_behaves_like 'Login Interface', PasswordLogin.new

      describe "initialization" do
        it "should set the username" do
          expect( PasswordLogin.new(username: 'testuser').username ).to eq 'testuser'
        end
        it "should set the password" do
          expect( PasswordLogin.new(password: 'test pass').password ).to eq 'test pass'
        end
      end

      describe "#user" do
        it "should return nil when no user matches the username" do
          query_result = []
          rspec_stubs_lazy
          allow(query_result).to receive(:first!).and_raise(ActiveRecord::RecordNotFound)
          rspec_stubs_strict
          allow(User).to receive(:where).with(email: 'missing user').and_return(query_result)
          expect( PasswordLogin.new(username: 'missing user', password: 'password').user ).to be_nil
        end
        it "should raise exception when the password doesn’t match the username" do
          user = User.new(name: 'testuser', password: 'password')
          query_result = [user]
          rspec_stubs_lazy
          allow(query_result).to receive(:first!).and_return(user)
          rspec_stubs_strict
          allow(User).to receive(:where).and_return(query_result)
          expect( PasswordLogin.new(username: 'testuser', password: 'bad pass').user ).to be_nil
        end
        it "should return the user when the username and password match" do
          user = User.new(name: 'testuser', password: 'password')
          query_result = [user]
          rspec_stubs_lazy
          allow(query_result).to receive(:first!).and_return(user)
          rspec_stubs_strict
          allow(User).to receive(:where).and_return(query_result)
          login_user = PasswordLogin.new(username: 'testuser', password: 'password').user
          expect( login_user ).to eq user
        end
      end

    end
  end
end
