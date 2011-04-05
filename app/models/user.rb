# encoding: utf-8
require 'bcrypt'

# Source References:
# * http://railscasts.com/episodes/250-authentication-from-scratch
# * https://github.com/rails/rails/commit/bd9dc4ff23ab1e185df6ccf35d6058c0a3d234ce
class User < ActiveRecord::Base
  acts_as_authority_controlled :item_authority_flag_field => :always_private

	attr_accessible :email, :name, :password, :password_confirmation
	attr_accessor :password

	# from oauth sources, so user can login from an external authenticating site
	has_many :authentications
	# the authorities (permissions) this user has to access items and areas
  # (not to be confused with has_many :authorities which are the authorities other users have to access this user)
	has_many :authorizations, :class_name => 'Authority', :dependent => :delete_all

	before_save :encrypt_password
	before_create :generate_email_confirmation_token
  after_create :first_user_is_admin
	
	validates_presence_of :password, :on => :create, :if => :local_authentication_required?
	validates_length_of :password, :within => 8..63, :allow_blank => true
	validates_confirmation_of :password, :if => :password_present?
	validates_presence_of :password_confirmation, :if => :password_present?
	validates_presence_of :email, :if => :local_authentication_required?
	validates_format_of :email, :with => /.+@.+\.[A-Za-z0-9]+/, :allow_blank => true
	validates_uniqueness_of :email, :case_sensitive => false, :if => :email_present?

	def local_authentication_required?
		authentications[0].nil?
	end
	def password_present?
		password.present?
	end
	def email_present?
		email.present?
	end

	def self.create_from_authentication!(authentication)
		user = User.new({:name => authentication.name, :email => authentication.email})
		user.authentications << authentication
		user.save!
		user
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

	def generate_email_confirmation_token
		unless email_confirmed || confirmation_token.present?
			self.confirmation_token = Digest::SHA1.hexdigest("=#{email}-#{created_at.to_s}.")
		end
	end

	# Set the user’s email_confirmed status, if the code matches the token,
	# and the user has not already been confirmed.
	def confirm_code!(in_code)
		if !email_confirmed && (in_code == confirmation_token)
			self.confirmation_token = nil
			self.email_confirmed = true
			self.save!
			return true
		else
			return false
		end
	end

  # The first user created is automatically an admin.
  def first_user_is_admin
    self.make_admin if User.count == 1
  end

  # give the user ownership of, and full access to, the specified area
  def make_admin(area = 'global')
    authority = self.authorities.for_area(area).first
    if authority
      authority.update_attributes!({
        :is_owner => true, :can_create => true, :can_view => true,
        :can_edit => true, :can_delete => true, :can_invite => true,
        :can_permit => true
      })
    else
      self.authorizations.create!(:area => area,
        :is_owner => true, :can_create => true, :can_view => true,
        :can_edit => true, :can_delete => true, :can_invite => true,
        :can_permit => true
      )
    end
  end

  def set_authority_on_area(area, action_type = :can_view)
    authority = self.authorities.for_area(area).first
    if authority
      authority.set_action!(action_type)
    else
      self.authorizations.create!(:area => area, action_type => true)
    end
  end
  def set_authority_on_item(item, action_type = :can_view)
    authority = self.authorizations.for_item(item).first
    if authority
      authority.set_action!(action_type)
    else
      self.authorizations.create!(:item => item, action_type => true)
    end
  end

  def has_authority_for_area(area, action_type = :can_view)
    if action_type.nil?
      self.authorizations.for_area_or_global(area).first
    elsif action_type == :is_owner
      self.authorizations.for_area_or_global(area).where_owner.first
    else
      self.authorizations.for_area_or_global(area).for_action(action_type).first
    end
  end
end
