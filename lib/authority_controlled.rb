# encoding: utf-8

# Add the ‘acts_as_authority_controlled’ line to your ActiveRecord models as desired.
# See the method definition below for options.
#
# Note that this relies on the User and Authority classes as defined in the wayground project.

# extensions to ActiveRecord to support setting classes up as being Authority controlled.
ActiveRecord::Base.class_eval do
  # options is a hash of optional parameters:
  # - :authority_area => A string defining the area of authority the model is to fall under.
  #    Defaults to the model’s class name.
  # - :item_authority_flag_field => A boolean field name string that is used to track
  #    whether individual records on the model will require authority to view.
  #    Defaults to ‘"is_authority_controlled"’.
  #    Set to ‘:always_private’ to have all of the model’s records require authority to be viewed.
  #    Set to ‘:always_viewable’ to have all of the model’s records not require authority to be viewed.
  def self.acts_as_authority_controlled(options={})
    # check if already loaded
    return if self.included_modules.include?(AuthorityControlled::InstanceMethods)

    # support a custom authority flag field (or none at all if all records private)
    if options[:item_authority_flag_field] == :always_private
      class_eval do
        def is_authority_controlled?
          true
        end
      end
    # TODO: implement the following chunk of code when there’s a class that needs non-private viewable items (e.g., Page)
    #elsif options[:item_authority_flag_field] == :always_viewable
    #  # use the default methods set on ActiveRecord
    #else
    #  # use the field name defined by item_authority_flag_field if present,
    #  # otherwise, use the default field name: is_authority_controlled
    #  class_eval <<-EOV
    #    def is_authority_controlled?
    #      self.#{(options[:item_authority_flag_field].present? ?
    #      options[:item_authority_flag_field] : 'is_authority_controlled')}
    #    end
    #  EOV
    end

    # define the authority area for the model
    if options[:authority_area] == 'global'
      raise Wayground::ModelAuthorityAreaCannotBeGlobal, 'cannot use "global" as an authority area, it is reserved'
    elsif options[:authority_area].present?
      # override the authority area for the class
      class_eval <<-EOV
        def self.authority_area
          '#{options[:authority_area]}'
        end
      EOV
    else
      # just fall back on the inherited authority_area method attached to all ActiveRecord classes below
    end

    class_eval do
      has_many :authorities, :as => :item, :dependent => :delete_all
    end

    include AuthorityControlled::InstanceMethods
  end

  # ActiveRecord descendants have their authority area defined as their class name by default
  def self.authority_area
    self.name
  end
  def authority_area
    self.class.authority_area
  end

  # ActiveRecord descendants are not authority controlled unless specifically set to be
  def is_authority_controlled?
    false
  end
  def is_authority_controlled=(value); end

  def has_authority_to?(user = nil, action_type = :can_view)
    if action_type == :can_view && !(is_authority_controlled?)
      # anyone can view a non-controlled item
      true
    else
      if user
        self.class.for_user(user).for_area(authority_area)
      else
        nil
      end
    end
  end
end

# Additions for classes to be set up as Authority controlled.
module AuthorityControlled
  module InstanceMethods
    def set_authority_for!(user, action)
      # check for existing authorization
      authority = self.authorities.for_user(user).first
      if authority
        unless authority[action]
          authority[action] = true
          authority.save!
        end
      else
        authority = self.authorities.new(action => true)
        authority.user = user
        authority.save!
      end
    end
    # action_type = :can_create, :can_view, :can_edit, :can_delete, :can_invite, :can_permit
    def has_authority_to?(user, action_type = :can_view)
      if action_type == :can_view && !(is_authority_controlled?)
        # anyone can view a non-controlled item
        true
      else
        valid_authority = nil
        # FIXME: this could be done better
        user_authorities = Authority.for_user(user).for_item_or_area(self, authority_area).for_action(action_type)
        # try to find an authority that gives permission,
        # prioritizing an authority that identifies the user as the owner
        user_authorities.each do |authority|
          if authority.is_owner? && authority.item == self
            valid_authority = authority
            break
          elsif authority[action_type]
            valid_authority ||= authority
          end
        end
        valid_authority
      end
    end
  end
end
