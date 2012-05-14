# encoding: utf-8
require 'bcrypt'

# Source References:
# * http://railscasts.com/episodes/250-authentication-from-scratch
# * https://github.com/rails/rails/commit/bd9dc4ff23ab1e185df6ccf35d6058c0a3d234ce
class User < ActiveRecord::Base
  acts_as_authority_controlled :item_authority_flag_field => :always_private

  attr_accessible :email, :name, :password, :password_confirmation, :timezone
  attr_accessor :password

  # from oauth sources, so user can login from an external authenticating site
  has_many :authentications
  # WARNING: it is easy to confuse authorizations with authorities:
  # authorizations: the Authority instances (permissions) this user has to access items and areas.
  # authorities: the Authority instances other users have to access this user.
  has_many :authorizations, :class_name => 'Authority', :dependent => :delete_all

  before_save :encrypt_password
  before_create :generate_email_confirmation_token
  before_create :generate_remember_token
  after_create :first_user_is_admin

  validates_presence_of :password, :on => :create, :if => :local_authentication_required?
  validates_length_of :password, :within => 8..63, :allow_blank => true
  validates_confirmation_of :password, :if => :password_present?
  validates_presence_of :password_confirmation, :if => :password_present?
  validates_presence_of :email, :if => :local_authentication_required?
  validates_format_of :email, :with => /[^ \r\n\t]+@[^ \r\n\t]+\.[A-Za-z0-9]+/, :allow_blank => true
  validates_uniqueness_of :email, :case_sensitive => false, :if => :email_present?
  validate :validate_timezone

  # Returns user(s) that exactly match the string.
  # If string is an integer, searches by user.id.
  # If string is an email address, searches by user.email.
  # Otherwise, searches by user.name.
  def self.find_by_string(str)
    if str.blank?
      nil
    elsif str.match /\A[0-9]+\z/
      find(str.to_i)
    elsif str.match /[^ \r\n\t]+@[^ \r\n\t]+\.[A-Za-z0-9]+/
      find_by_email(str)
    else
      find_by_name(str)
    end
  end

  # Get the first administrative User.
  # Used for system generated items that require a User.
  def self.main_admin
    # TODO: come up with a better way to determine/set the main admin.
    User.order(:id).first
  end

  def local_authentication_required?
    authentications[0].nil?
  end
  def password_present?
    password.present?
  end
  def email_present?
    email.present?
  end

  # If the timezone is set for a user, it must be valid.
  # TODO: make this some kind of helper since it shows up in both the User and Event models.
  def validate_timezone
    if timezone.present? && ActiveSupport::TimeZone[timezone].nil?
      errors.add(:timezone, 'must be a recognized timezone name')
    end
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

  # REMEMBER ME

  # Generate a unique token to be used to remember the user for future sessions.
  def generate_remember_token
    begin
      self.remember_token = SecureRandom.urlsafe_base64
    end while User.exists?(:remember_token => self.remember_token)
  end

  # Generate a secure hash, based on the remember token and user id, for use in cookies.
  def remember_token_hash
    if remember_token.blank?
      generate_remember_token
      save!
    end
    Digest::SHA1.hexdigest([remember_token,id].join('—')) + "/#{id}"
  end

  # Determines whether the given token_hash correctly identifies this user
  def matches_token_hash?(token_hash)
    token_hash == remember_token_hash
  end

  # AUTHORITIES

  # Shortcut for determining if the user has global authority.
  def admin?
    has_authority_for_area('global', :is_owner)
  end

  # The first user created is automatically an admin.
  def first_user_is_admin
    self.make_admin! if User.count == 1
  end

  # give the user ownership of, and full access to, the specified area
  def make_admin!(area = 'global', authorizing_user = nil)
    authority = self.authorizations.for_area(area).first
    if authority
      authority.authorized_by = authorizing_user unless authorizing_user.nil?
      authority.update_attributes!({
        :is_owner => true, :can_create => true, :can_view => true,
        :can_update => true, :can_delete => true, :can_invite => true,
        :can_permit => true, :can_approve => true
      })
    else
      authority = Authority.new(:area => area,
        :is_owner => true, :can_create => true, :can_view => true,
        :can_update => true, :can_delete => true, :can_invite => true,
        :can_permit => true, :can_approve => true
      )
      authority.authorized_by = authorizing_user || self
      self.authorizations << authority
      self.save!
    end
  end

  def set_authority_on_area(area, action_type = :can_view)
    authority = self.authorizations.for_area(area).first
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
      authority = self.authorizations.new(action_type => true)
      authority.item = item
      authority.save!
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
