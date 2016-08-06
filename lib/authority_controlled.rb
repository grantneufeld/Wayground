# Add the ‘acts_as_authority_controlled’ line to your ActiveRecord models as desired.
# See the method definition below for options.
#
# Note that this relies on the User and Authority classes as defined in the wayground project.

# extensions to ActiveRecord to support setting classes up as being Authority controlled.
ApplicationRecord.class_eval do
  # options is a hash of optional parameters:
  # - :authority_area => A string defining the area of authority the model is to fall under.
  #    Defaults to the model’s class name.
  # - :item_authority_flag_field => A boolean field name string that is used to track
  #    whether individual records on the model will require authority to view.
  #    Defaults to ‘"is_authority_controlled"’.
  #    Set to ‘:always_private’ to have all of the model’s records require authority to be viewed.
  #    Set to ‘:always_viewable’ to have all of the model’s records not require authority to be viewed.
  # - :inherits_from => A symbol for the method name to access an object that is authority controlled.
  #    E.g., Path (custom url) gets it’s authority info through it’s item (typically a Page).
  def self.acts_as_authority_controlled(
    authority_area: nil, item_authority_flag_field: nil, inherits_from: nil
  )
    # check if already loaded
    inst_meth_incl = included_modules.include?(AuthorityControlled::InstanceMethods)
    return if inst_meth_incl || included_modules.include?(AuthorityControlled::InheritInstanceMethods)

    # support a custom authority flag field (or none at all if all records private)
    if inherits_from.present?
      class_eval "
        def authority_restricted?
          self.#{inherits_from}.present? && self.#{inherits_from}.authority_restricted?
        end
        def authority_area
          if self.#{inherits_from}
            self.#{inherits_from}.authority_area
          else
            self.class.authority_area
          end
        end
      "
    elsif item_authority_flag_field == :always_private
      class_eval do
        def authority_restricted?
          true
        end
      end
    # TODO: implement the following when there’s a class that needs non-private viewable items (e.g., Page)
    elsif item_authority_flag_field == :always_viewable
      # use the default methods set on ActiveRecord
    else
      # use the field name defined by item_authority_flag_field if present,
      # otherwise, use the default field name: is_authority_controlled
      method_name = item_authority_flag_field
      method_name = 'is_authority_controlled' unless method_name.present?
      class_eval "
        def authority_restricted?
          self.#{method_name}
        end
      "
    end

    # define the authority area for the model
    if authority_area == 'global'
      raise(
        Wayground::ModelAuthorityAreaCannotBeGlobal,
        'cannot use "global" as an authority area, it is reserved'
      )
    elsif authority_area.present?
      # override the authority area for the class
      class_eval "
        def self.authority_area
          '#{authority_area}'
        end"
    end
    # else, just fall back on the authority_area method inherited from ActiveRecord (defined below)

    class_eval do
      # FIXME: make this work with scopes somehow so it can be used with restrictions like order and where
      # Find all except those the user does not have authority to access.
      def self.allowed_for_user(user = nil, action = :can_view)
        # TODO: there is probably a more efficient way to do this
        items = []
        all.each do |item|
          items << item if item.authority_for_user_to?(user, action)
        end
        items
      end
    end

    if inherits_from.present?
      class_eval "
        def authorities
          self.#{inherits_from} && self.#{inherits_from}.authorities
        end
        def as_authority_controlled_item
          self.#{inherits_from}
        end
      "
      include AuthorityControlled::InheritInstanceMethods
    else
      class_eval do
        has_many :authorities, as: :item, dependent: :delete_all
      end
      include AuthorityControlled::InstanceMethods
    end
  end

  def self.allowed_for_user(user = nil, action = :can_view)
    if user
      # TODO: there is probably a more efficient way to do this
      items = []
      all.each do |item|
        items << item if item.authority_for_user_to?(user, action)
      end
      items
    else
      action == :can_view ? all : []
    end
  end

  # ActiveRecord descendants have their authority area defined as their class name by default
  def self.authority_area
    name
  end

  def authority_area
    self.class.authority_area
  end

  # ActiveRecord descendants are not authority controlled unless specifically set to be
  def authority_restricted?
    false
  end
  # def is_authority_controlled=(value); end

  def authority_for_user_to?(user = nil, action_type = :can_view)
    if action_type == :can_view && !authority_restricted?
      # anyone can view a non-controlled item
      true
    elsif user
      Authority.for_user(user).for_area_or_global(authority_area).for_action(action_type)
    end
  end
end

# Additions for classes to be set up as Authority controlled.
module AuthorityControlled
  # Standard instance methods for authority controlled models.
  module InstanceMethods
    # action_type = :can_create, :can_view, :can_update, :can_delete, :can_invite, :can_permit, :can_approve

    def set_authority_for!(user, action_type)
      # check for existing authorization
      authority = authorities.for_user(user).first
      if authority
        authority.action!(action_type)
      else
        authority = authorities.build(action_type => true)
        authority.user = user
        authority.save!
      end
    end

    def authority_for_user_to?(user, action_type = :can_view)
      if action_type == :can_view && !authority_restricted?
        # anyone can view a non-controlled item
        true
      elsif user
        Authority.user_has_for_item(user, self, action_type)
      end
    end
  end

  # Use these instead of the normal instance methods when a model is inheriting
  # its authority controls from a related model.
  module InheritInstanceMethods
    # action_type = :can_create, :can_view, :can_update, :can_delete, :can_invite, :can_permit, :can_approve

    def set_authority_for!(_user, _action_type)
      raise Wayground::WrongModelForSettingAuthority, 'set authority on the related item instead'
    end

    def authority_for_user_to?(user, action_type = :can_view)
      if action_type == :can_view && !authority_restricted?
        # anyone can view a non-controlled item
        true
      elsif user
        item = as_authority_controlled_item
        if item
          Authority.user_has_for_item(user, item, action_type)
        else
          # if there is no inherited item, go with self
          Authority.user_has_for_item(user, self, action_type)
        end
      else
        false
      end
    end
  end
end
