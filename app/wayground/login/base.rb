# encoding: utf-8
require 'active_record'
require 'user'

module Wayground
  module Login

    # USAGE
    # Create a new Login object, passing in the relevant parameters.
    # Then call `user` on the login object to get a validated user
    # (or nil if the parameters didn’t match a user).
    # Call `user_class=` to override the default `User` class used.

    # ABSTRACT CLASS
    # Use a subclass to perform a specific type of login.
    class Base
      attr_writer :user_class

      def initialize(args={})
        user_class_arg = args[:user_class]
        self.user_class = user_class_arg if user_class_arg.present?
        post_initialize(args)
      end

      def user_class
        @user_class ||= User
      end

      def user
        @user ||= find_user
      rescue ActiveRecord::RecordNotFound
        nil
      end

      protected

      # Implement in subclasses:

      def post_initialize(args={})
        args
      end

      def find_user
        nil
      end

    end

  end
end
