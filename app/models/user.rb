require 'bcrypt'

# Source References:
# * http://railscasts.com/episodes/250-authentication-from-scratch
# * https://github.com/rails/rails/commit/bd9dc4ff23ab1e185df6ccf35d6058c0a3d234ce
class User < ActiveRecord::Base
	attr_accessible :email, :password, :password_confirmation
	
	attr_accessor :password
	before_save :encrypt_password
	
	validates :password,
		:presence => true,
		:length => { :within => 8..63 }
	validates_confirmation_of :password
	validates_presence_of :password_confirmation, :if => :password_required?
	validates :email,
		:presence => true,
		:format => /.+@.+\.[A-Za-z0-9]+/
	validates_uniqueness_of :email, :case_sensitive => false

	def password_required?
		password.present?
	end

	def self.authenticate(email, password)
		user = find_by_email(email)
		if user && (BCrypt::Password.new(user.password_hash) == password)
			user
		else
			nil
		end
	end

	def encrypt_password
		if password.present?
			self.password_hash = BCrypt::Password.create(password)
		end
	end
end
