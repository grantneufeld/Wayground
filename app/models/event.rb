# encoding: utf-8

# Details of a calendar event
class Event < ActiveRecord::Base
  acts_as_authority_controlled :authority_area => 'Calendar'
  attr_accessible(
    :start_at, :end_at, :is_allday,
    :is_draft, :is_wheelchair_accessible, :is_adults_only, :is_tentative, :is_featured,
    :title, :description, :content,
    :organizer, :organizer_url,
    :location, :address, :city, :province, :country, :location_url,
    :external_links_attributes
  )

  belongs_to :user
  has_many :external_links, :as => :item
  accepts_nested_attributes_for :external_links,
    :reject_if => lambda { |el| el[:url].blank? }, :allow_destroy => true

  validates_presence_of :start_at
  validate :validate_end_at_after_start_at,
    :validate_not_both_is_draft_and_is_approved
  validates_length_of :title, :within => 1..255
  validates_length_of :description, :within => 0..255, :allow_blank => true
  validates_length_of :content, :within => 0..8191, :allow_blank => true
  validates_length_of :organizer, :within => 0..255, :allow_blank => true
  validates_length_of :organizer_url, :within => 0..255, :allow_blank => true
  validates_length_of :location, :within => 0..255, :allow_blank => true
  validates_length_of :address, :within => 0..255, :allow_blank => true
  validates_length_of :city, :within => 0..255, :allow_blank => true
  validates_length_of :province, :within => 0..31, :allow_blank => true
  validates_length_of :country, :within => 0..2, :allow_blank => true
  validates_length_of :location_url, :within => 0..255, :allow_blank => true

  default_scope order('start_at')
  scope :approved, where(:is_approved => true)

  before_save :approve_if_authority

  # An event cannot end before, or when, it begins.
  def validate_end_at_after_start_at
    unless start_at.blank? || end_at.blank? || (start_at.to_datetime < end_at.to_datetime)
      errors.add(:end_at, 'must be after the start date and time')
    end
  end

  # An event cannot be both a draft and approved at the same time.
  def validate_not_both_is_draft_and_is_approved
    if is_draft && is_approved
      errors.add(:is_approved, 'cannot approve an event when it is still a draft')
    end
  end

  def approve_if_authority
    if !is_approved && user && user.has_authority_for_area('Calendar', :is_owner)
      self.is_approved = true
    end
  end

end
