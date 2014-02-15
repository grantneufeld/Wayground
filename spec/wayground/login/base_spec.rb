require 'spec_helper'
require 'login/base'
require_relative 'login_interface'
require 'user'
require 'active_record'

module Wayground
  module Login
    describe Wayground::Login::Base do

      it_behaves_like 'Login Interface', Base.new

      describe "initialization" do
        it "should accept a user_class" do
          expect( Base.new(user_class: :test_class).user_class ).to eq :test_class
        end
      end

      describe "#user_class" do
        it "should default to User for the user_class" do
          expect( Base.new.user_class ).to eq User
        end
      end

      describe "#user_class=" do
        it "should assign the given user class" do
          login = Base.new
          login.user_class = :login_user_class
          expect( login.user_class ).to eq :login_user_class
        end
      end

      describe "#user" do
        it "should always return nil" do
          expect( Base.new.user ).to be_nil
        end
        it "should return nil on an ActiveRecord::RecordNotFound exception" do
          Base.any_instance.stub(:find_user).and_raise(ActiveRecord::RecordNotFound)
          expect( Base.new.user ).to be_nil
        end
      end

    end
  end
end
