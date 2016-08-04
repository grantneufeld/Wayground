require 'authority_controlled'
require 'email_validator'
require 'crypted_password'
require 'password'
require 'authority'
require 'active_support/values/time_zone'

# Source References:
# * http://railscasts.com/episodes/250-authentication-from-scratch
# * https://github.com/rails/rails/commit/bd9dc4ff23ab1e185df6ccf35d6058c0a3d234ce
class User < ApplicationRecord
  acts_as_authority_controlled :item_authority_flag_field => :always_private
  attr_reader :password

  # cookie tokens for keeping the user logged in
  has_many :tokens, class_name: 'UserToken', dependent: :destroy
  # from oauth sources, so user can login from an external authenticating site
  has_many :authentications
  # WARNING: it is easy to confuse authorizations with authorities:
  # authorizations: the Authority instances (permissions) this user has to access items and areas.
  # authorities: the Authority instances other users have to access this user.
  has_many :authorizations, :class_name => 'Authority', :dependent => :delete_all

  before_create :generate_email_confirmation_token
  after_create :first_user_is_admin

  # VALIDATION

  validates_presence_of :password, :on => :create, :if => :local_authentication_required?
  validates_length_of :password, :within => 8..63, :allow_blank => true
  validates_confirmation_of :password, :if => :password_present?
  validates_presence_of :password_confirmation, :if => :password_present?
  validates :email, presence: true, if: :local_authentication_required?
  validates :email, email: true, uniqueness: { case_sensitive: false }, allow_blank: true
  validate :validate_timezone

  # validation conditionals
  def local_authentication_required?
    !(authentications[0])
  end
  def password_present?
    password.present?
  end

  # If the timezone is set for a user, it must be valid.
  # TODO: make this some kind of helper since it shows up in both the User and Event models.
  def validate_timezone
    if timezone.present? && !(ActiveSupport::TimeZone[timezone])
      errors.add(:timezone, 'must be a recognized timezone name')
    end
  end

  # FINDERS

  # Returns user(s) that exactly match the string.
  # If string is an integer, searches by user.id.
  # If string is an email address, searches by user.email.
  # Otherwise, searches by user.name.
  def self.from_string(str)
    if str.blank?
      nil
    elsif str.match /\A[0-9]+\z/
      find(str.to_i)
    elsif str.match /[^ \r\n\t]+@[^ \r\n\t]+\.[A-Za-z0-9]+/
      where(email: str).first
    else
      where(name: str).first
    end
  rescue ActiveRecord::RecordNotFound
    nil
  end

  # Get the first administrative User.
  # Used for system generated items that require a User.
  def self.main_admin
    # TODO: come up with a better way to determine/set the main admin.
    User.order(:id).first
  end

  # LOGIN

  # label for the field used for logging in with a password (email)
  def self.login_name_attribute
    :email
  end

  # PASSWORD

  # Wrap the `password_hash` string attribute in a CryptedPassword object.
  def password_hash
    crypted_pass = read_attribute(:password_hash)
    if crypted_pass.blank?
      nil
    else
      Wayground::CryptedPassword.new(crypted_pass)
    end
  end

  # Generate the password hash when a password is assigned.
  def password=(pass)
    @password = pass
    self.password_hash = Wayground::Password.new(pass).crypted_password.to_s
  end

  # EMAIL CONFIRMATION

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

  # AUTHORITIES ASSIGNMENT

  # The first user created is automatically an admin.
  def first_user_is_admin
    self.make_admin! if User.count == 1
  end

  # give the user ownership of, and full access to, the specified area
  def make_admin!(area = 'global', authorizing_user = nil)
    authority = self.authorizations.for_area(area).first
    if authority
      authority.authorized_by = authorizing_user if authorizing_user
      authority.update!(
        :is_owner => true, :can_create => true, :can_view => true,
        :can_update => true, :can_delete => true, :can_invite => true,
        :can_permit => true, :can_approve => true
      )
    else
      authority = self.authorizations.build(:area => area,
        :is_owner => true, :can_create => true, :can_view => true,
        :can_update => true, :can_delete => true, :can_invite => true,
        :can_permit => true, :can_approve => true
      )
      authority.authorized_by = authorizing_user || self
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
      authority = self.authorizations.build(action_type => true)
      authority.item = item
      authority.save!
    end
  end

  # AUTHORITIES CHECKING

  # Shortcut for determining if the user has global authority.
  def admin?
    has_authority_for_area('global', :is_owner)
  end

  def has_authority_for_area(area, action_type = :can_view)
    if !action_type
      self.authorizations.for_area_or_global(area).first
    elsif action_type == :is_owner
      self.authorizations.for_area_or_global(area).where_owner.first
    else
      self.authorizations.for_area_or_global(area).for_action(action_type).first
    end
  end
end
