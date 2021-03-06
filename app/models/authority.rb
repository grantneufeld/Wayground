require 'user'

# Gives authority to a user, on a given item or area, for performing specific actions.
class Authority < ApplicationRecord
  belongs_to :user
  belongs_to :authorized_by, class_name: 'User'
  belongs_to :item, polymorphic: true

  validates :user, presence: true
  # validates(area:, inclusion: { in: %w(global User Authority Page Event),
  #   allow_nil: true, allow_blank: true,
  #   message: "{{value}} is not a recognized area" })
  validates :area, presence: { if: proc { |authority| authority.item_type.blank? } }
  validates :item_id, presence: { if: proc { |authority| authority.item_type.present? } }

  scope :for_area, ->(area) { where(area: area) }
  scope :for_area_or_global, lambda { |area|
    where("(authorities.area = ? OR authorities.area = 'global')", area)
  }
  scope :for_item, ->(item) { where(item_id: item.id, item_type: item.class.name) }
  scope :for_item_or_area, lambda { |item|
    where(
      '((authorities.item_id = ? AND authorities.item_type = ?)' \
      " OR authorities.area = ? OR authorities.area = 'global')",
      item.id, item.class.name, item.authority_area
    )
  }
  scope :for_user, ->(user) { where(user_id: user.id) }
  scope :for_action, lambda { |action|
    raise "invalid action “#{action}”" unless action.match?(/\A(can_[a-z]+|is_owner)\z/)
    where("(authorities.#{action} = ? OR authorities.is_owner = ?)", true, true)
  }
  scope :where_owner, -> { where(is_owner: true) }

  def self.build_from_params(params)
    authority_params = params[:authority_params] || {}
    user = User.from_string(authority_params[:user_proxy].to_s)
    authority = user ? user.authorizations.build(authority_params) : Authority.new(authority_params)
    authority.authorized_by = params[:authorized_by]
    authority
  end

  # Find an Authority that gives the +user+ permission to perform the +action_type+ on the +item+.
  # Prefers authority instances designating the +user+ as the owner of the +item+.
  # +action_type+:: an access_control action symbol. If +nil+, does not restrict by action.
  #   Default: +:can_view+
  def self.user_has_for_item(user, item, action_type = :can_view)
    user_authorizations = Authority.for_user(user).for_item_or_area(item)
    user_authorizations = user_authorizations.for_action(action_type) unless action_type.nil?
    authority_that_gives_permission(user_authorizations, item, action_type)
  end

  # From a list of authorities, try to find an authority that gives permission,
  # prioritizing an authority that identifies the user as the owner of the item
  def self.authority_that_gives_permission(user_authorizations, item, action_type)
    valid_authority = nil
    user_authorizations.each do |authority|
      if authority.is_owner? && authority.item == item
        valid_authority = authority
        break
      elsif (action_type.nil? || authority[action_type]) && authority.item == item
        # second priority is for authorities on the item
        valid_authority = authority
      elsif (action_type.nil? || authority[action_type]) || authority.is_owner?
        valid_authority ||= authority
      end
    end
    valid_authority
  end

  # Setting the user via a string value (e.g., either an email address or id) or a User instance.

  # Returns the user’s email address as a proxy string for the user, or +false+ if missing.
  def user_proxy
    user && user.email
  end

  # Assigns the +user+ based on a string or User instance.
  # If +item+ is blank, user is set to nil.
  # If +item+ is a string matching an user email, id, or name, sets the user.
  # If +item+ is a User instance, sets the user.
  def user_proxy=(item)
    self.user =
      if item.blank?
        nil
      elsif item.is_a? String
        User.from_string(item)
      else
        item
      end
  end

  # def user_has_for_area(user, area, action_type = :can_view)
  #   if action_type.nil?
  #     Authority.for_user(user).for_area(area)
  #   else
  #     Authority.for_user(user).for_area(item).for_action(action_type)
  #   end
  # end

  def action!(action_type)
    return if self[action_type]
    self[action_type] = true
    save!
  end

  # Merge this authority into another authority (must be for the same user).
  # The various permission fields are OR’d,
  # the destination authority is saved,
  # and then this authority is destroyed.
  def merge_into!(destination_authority)
    raise TypeError unless destination_authority.is_a? Authority
    raise Wayground::UserMismatch unless destination_authority.user == user
    merge_values(destination_authority)
    if destination_authority.save
      destroy
      true
    else
      false
    end
  end

  private

  def merge_values(destination_authority)
    destination_authority.is_owner ||= is_owner
    destination_authority.can_create ||= can_create
    destination_authority.can_view ||= can_view
    destination_authority.can_update ||= can_update
    destination_authority.can_delete ||= can_delete
    destination_authority.can_invite ||= can_invite
    destination_authority.can_permit ||= can_permit
    destination_authority.can_approve ||= can_approve
  end
end
