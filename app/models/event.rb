# encoding: utf-8

# Details of a calendar event
class Event < ActiveRecord::Base
  acts_as_authority_controlled :authority_area => 'Calendar', :item_authority_flag_field => :always_viewable
  attr_accessor :editor, :edit_comment
  attr_accessible(
    :start_at, :end_at, :timezone, :is_allday,
    :is_draft, :is_wheelchair_accessible, :is_adults_only, :is_tentative, :is_cancelled, :is_featured,
    :title, :description, :content,
    :organizer, :organizer_url,
    :location, :address, :city, :province, :country, :location_url,
    :external_links_attributes, :edit_comment
  )

  belongs_to :user
  has_many :external_links, :as => :item
  accepts_nested_attributes_for :external_links,
    :reject_if => lambda { |el| el[:url].blank? }, :allow_destroy => true
  has_many :versions, :as => :item, :dependent => :delete_all

  validates_length_of :title, :within => 1..255
  validates_presence_of :start_at
  validate :validate_end_at_after_start_at,
    :validate_timezone,
    :validate_not_both_is_draft_and_is_approved
  validates_length_of :organizer, :within => 0..255, :allow_blank => true
  validates_length_of :organizer_url, :within => 0..255, :allow_blank => true
  validates_length_of :location, :within => 0..255, :allow_blank => true
  validates_length_of :address, :within => 0..255, :allow_blank => true
  validates_length_of :city, :within => 0..255, :allow_blank => true
  validates_length_of :province, :within => 0..31, :allow_blank => true
  validates_length_of :country, :within => 0..2, :allow_blank => true
  validates_length_of :location_url, :within => 0..255, :allow_blank => true
  validates_length_of :description, :within => 0..511, :allow_blank => true
  validates_length_of :content, :within => 0..8191, :allow_blank => true

  default_scope order('start_at')
  scope :approved, where(:is_approved => true)
  scope :upcoming, lambda { # use a lambda so the time is reloaded each time upcoming is called
    where(
      'start_at >= ? OR (end_at IS NOT NULL AND end_at >= ?)',
      Time.current.beginning_of_day, Time.current.beginning_of_day
    )
  }

  before_save :approve_if_authority
  before_create :set_timezone
  after_save :add_version

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

  # If the timezone is set for an event, it must be valid
  def validate_timezone
    if timezone.present? && ActiveSupport::TimeZone[timezone].nil?
      errors.add(:timezone, 'must be a recognized timezone name')
    end
  end

  def approve_if_authority
    if !is_approved && user && user.has_authority_for_area('Calendar', :is_owner)
      self.is_approved = true
    end
  end

  # Attempts to set the timezone based on the user’s timezone,
  # falling back to the default timezone.
  def set_timezone
    if timezone.blank?
      if user.present? && user.timezone?
        self.timezone = user.timezone
      else
        self.timezone = Time.zone_default.name
      end
    end
  end

  # Add a Version based on the current state of this item
  def add_version
    data = "timezone: #{timezone}\n" + \
      "is_allday: #{is_allday}\n" + \
      "is_draft: #{is_draft}\n" + \
      "is_approved: #{is_approved}\n" + \
      "is_wheelchair_accessible: #{is_wheelchair_accessible}\n" + \
      "is_adults_only: #{is_adults_only}\n" + \
      "is_tentative: #{is_tentative}\n" + \
      "is_cancelled: #{is_cancelled}\n" + \
      "is_featured: #{is_featured}\n" + \
      "organizer: #{organizer}\n" + \
      "organizer_url: #{organizer_url}\n" + \
      "location: #{location}\n" + \
      "address: #{address}\n" + \
      "city: #{city}\n" + \
      "province: #{province}\n" + \
      "country: #{country}\n" + \
      "location_url: #{location_url}\n" + \
      "content:\n#{content}"
    self.versions.create!(
      :user => editor, :edited_at => self.updated_at, :edit_comment => edit_comment,
      :filename => nil, :title => title, :url => nil, :description => description,
      :content => data, :content_type => 'text/plain',
      :start_on => start_at.to_date, :end_on => (end_at? ? end_at.to_date : nil)
    )
  end

end
