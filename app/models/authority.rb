# encoding: utf-8

class Authority < ActiveRecord::Base
  attr_accessible :item_type, :item_id, :area, :is_owner, :can_create,
    :can_view, :can_edit, :can_delete, :can_invite, :can_permit

  belongs_to :user
  belongs_to :item, :polymorphic => true

  validates_presence_of :user
  #validates_inclusion_of :area, :in => %w( global User Authority Page Event ),
  #  :allow_nil => true, :allow_blank => true,
  #  :message => "{{value}} is not a recognized area"
  validates_presence_of :area, :if => Proc.new {|authority| authority.item_type.blank?}
  validates_presence_of :item_id, :if => Proc.new {|authority| authority.item_type.present?}

  scope :for_area, lambda {|area|
    where("authorities.area = ? OR authorities.area = 'global'", area)
  }
  #scope :for_item, lambda {|item|
  #  where(:item_id => item.id, :item_type => item.class.name) # or area = #{item.area} or area = 'global'
  #}
  scope :for_item_or_area, lambda { |item, area|
    where("(authorities.item_id = ? AND authorities.item_type = ?) OR authorities.area = ? OR authorities.area = 'global'", item.id, item.class.name, area)
  }
  scope :for_user, lambda {|user|
    where(:user_id => user.id)
  }
  scope :for_action, lambda {|action|
    raise "invalid action “#{action}”" unless action.match(/\Acan_[a-z]+\z/)
    where("(authorities.#{action} = ? OR authorities.is_owner = ?)", true, true)
  }
  scope :where_owner, where(:is_owner => true)
end
