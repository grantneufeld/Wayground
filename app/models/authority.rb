# encoding: utf-8

class Authority < ActiveRecord::Base
  attr_accessible :item_type, :item_id, :area, :is_owner, :can_create,
    :can_view, :can_edit, :can_delete, :can_invite, :can_permit

  belongs_to :user
  belongs_to :authorized_by, :class_name => 'User'
  belongs_to :item, :polymorphic => true

  validates_presence_of :user
  #validates_inclusion_of :area, :in => %w( global User Authority Page Event ),
  #  :allow_nil => true, :allow_blank => true,
  #  :message => "{{value}} is not a recognized area"
  validates_presence_of :area, :if => Proc.new {|authority| authority.item_type.blank?}
  validates_presence_of :item_id, :if => Proc.new {|authority| authority.item_type.present?}

  scope :for_area, lambda {|area|
    where(:area => area)
  }
  scope :for_area_or_global, lambda {|area|
    where("(authorities.area = ? OR authorities.area = 'global')", area)
  }
  scope :for_item, lambda { |item|
    where(:item_id => item.id, :item_type => item.class.name)
  }
  scope :for_item_or_area, lambda { |item|
    where("((authorities.item_id = ? AND authorities.item_type = ?) OR authorities.area = ? OR authorities.area = 'global')", item.id, item.class.name, item.authority_area)
  }
  scope :for_user, lambda {|user|
    where(:user_id => user.id)
  }
  scope :for_action, lambda {|action|
    raise "invalid action “#{action}”" unless action.match(/\Acan_[a-z]+\z/)
    where("(authorities.#{action} = ? OR authorities.is_owner = ?)", true, true)
  }
  scope :where_owner, where(:is_owner => true)

  def self.build_from_params(params)
    user_id = params[:user_id]
    if user_id.blank?
      authority = Authority.new(params)
    else
      if user_id.match(/\A[0-9]+\z/)
        @user = User.find(user_id)
      else
        @user = User.find_by_email(user_id)
      end
      if @user.nil?
        authority = Authority.new(params)
      else
        authority = @user.authorizations.new(params)
      end
    end
    authority
  end

  def self.user_has_for_item(user, item, action_type = :can_view)
    valid_authority = nil
    # FIXME: this could be done better
    if action_type.nil?
      user_authorities = Authority.for_user(user).for_item_or_area(item)
    else
      user_authorities = Authority.for_user(user).for_item_or_area(item).for_action(action_type)
    end
    # try to find an authority that gives permission,
    # prioritizing an authority that identifies the user as the owner of the item
    user_authorities.each do |authority|
      if authority.is_owner? && authority.item == item
        valid_authority = authority
        break
      elsif authority[action_type]
        valid_authority ||= authority
      end
    end
    valid_authority
  end

  #def user_has_for_area(user, area, action_type = :can_view)
  #  if action_type.nil?
  #    Authority.for_user(user).for_area(area)
  #  else
  #    Authority.for_user(user).for_area(item).for_action(action_type)
  #  end
  #end

  def set_action!(action_type)
    unless self[action_type]
      self[action_type] = true
      self.save!
    end
  end
end
