require 'active_record'
require 'authority_controlled'
require 'tag_list'
require 'user'
require 'text_cleaner'
require 'url_cleaner'
require 'import/ical_importer'

# Details of a calendar event
class Event < ApplicationRecord
  acts_as_authority_controlled authority_area: 'Calendar', item_authority_flag_field: :always_viewable
  # editor and edit_comment are used for Version records
  # is_sourcing is set when generating or updating from a Source (and SourcedItem)
  attr_accessor :editor, :edit_comment, :is_sourcing

  belongs_to :user
  belongs_to :image
  has_many :external_links, as: :item
  accepts_nested_attributes_for(
    :external_links,
    reject_if: ->(el) { el[:url].blank? }, allow_destroy: true
  )
  has_many :sourced_items, as: :item
  has_many :tags, as: :item, dependent: :delete_all
  has_many :versions, as: :item, dependent: :delete_all

  validates :title, length: { within: 1..255 }
  validates :start_at, presence: true
  validates :organizer, length: { within: 0..255, allow_blank: true }
  validates :organizer_url, length: { within: 0..255, allow_blank: true }
  validates :location, length: { within: 0..255, allow_blank: true }
  validates :address, length: { within: 0..255, allow_blank: true }
  validates :city, length: { within: 0..255, allow_blank: true }
  validates :province, length: { within: 0..31, allow_blank: true }
  validates :country, length: { within: 0..2, allow_blank: true }
  validates :location_url, length: { within: 0..255, allow_blank: true }
  validates :description, length: { within: 0..511, allow_blank: true }
  validates :content, length: { within: 0..8191, allow_blank: true }
  validate(
    :validate_end_at_not_before_start_at,
    :validate_timezone,
    :validate_not_both_is_draft_and_is_approved
  )

  default_scope { order('start_at') }
  scope :approved, -> { where(is_approved: true) }
  scope :upcoming, lambda { # use a lambda so the time is reloaded each time upcoming is called
    where(
      'start_at >= :day_start OR (end_at IS NOT NULL AND end_at >= :day_start)',
      day_start: Time.current.beginning_of_day
    )
  }
  scope :past, lambda { # use a lambda so the time is reloaded each time upcoming is called
    where(
      'start_at < :day_start AND (end_at IS NULL OR end_at < :day_start)',
      day_start: Time.current.beginning_of_day
    )
  }
  scope :falls_between_dates, lambda { |start_date, end_date|
    start_time = Time.zone.local(start_date.year, start_date.month, start_date.day, 0, 0, 0)
    end_time = Time.zone.local(end_date.year, end_date.month, end_date.day, 0, 0, 0) + 1.day
    where(
      # matches if event#start_at falls within the given dates
      '(start_at >= :start_time AND start_at < :end_time)' +
      # matches if event#end_at is set and falls within the given dates
      ' OR (end_at IS NOT NULL AND end_at > :start_time AND end_at < :end_time)' +
      # matches if event#start_at is before the dates and event#end_at is after the dates
      ' OR (end_at IS NOT NULL AND start_at < :start_time AND end_at >= :end_time)',
      start_time: start_time, end_time: end_time
    )
  }
  scope :falls_on_date, lambda { |the_date|
    start_time = Time.zone.local(the_date.year, the_date.month, the_date.day, 0, 0, 0)
    end_time = start_time + 1.day
    where(
      '(start_at >= :start_time AND start_at < :end_time)' \
      ' OR ' \
      '(end_at IS NOT NULL AND start_at < :end_time AND end_at >= :start_time)',
      start_time: start_time, end_time: end_time
    )
  }
  scope :tagged, lambda { |tag|
    tag = Tag.new.taggify_text(tag)
    joins(:tags).where(tags: { tag: tag })
  }

  before_create :set_timezone
  before_save :approve_if_authority
  after_update :flag_as_modified_for_sourcing
  after_save :add_version
  after_save :save_tag_list
  before_destroy :ignore_sourced_items_on_destroy

  def initialize(*args)
    super(*args)
    # if city, province and country are all blank
    if country.blank? && province.blank? && city.blank?
      # use defaults
      self.city ||= Wayground::Application::DEFAULT_CITY
      self.province ||= Wayground::Application::DEFAULT_PROVINCE
      self.country ||= Wayground::Application::DEFAULT_COUNTRY
    end
  end

  # VALIDATION METHODS

  # An event cannot end before it begins.
  def validate_end_at_not_before_start_at
    have_both_dates = start_at.present? && end_at.present?
    end_before_start = have_both_dates && start_at.to_datetime > end_at.to_datetime
    errors.add(:end_at, 'must be after the start date and time') if end_before_start
  end

  # An event cannot be both a draft and approved at the same time.
  def validate_not_both_is_draft_and_is_approved
    errors.add(:is_approved, 'cannot approve an event when it is still a draft') if is_draft && is_approved
  end

  # If the timezone is set for an event, it must be valid
  def validate_timezone
    timezone_invalid = timezone.present? && !(ActiveSupport::TimeZone[timezone])
    errors.add(:timezone, 'must be a recognized timezone name') if timezone_invalid
  end

  # BEFORE/AFTER CALLBACKS

  # Attempts to set the timezone based on the user’s timezone,
  # falling back to the default timezone.
  # Called before save on create.
  def set_timezone
    if timezone.blank?
      self.timezone =
        if user.present? && user.timezone?
          user.timezone
        else
          Time.zone_default.name
        end
    end
  end

  # Called before save.
  def approve_if_authority
    self.is_approved = true if !is_approved && user && user.authority_for_area('Calendar', :can_approve)
  end

  # Called after save on update.
  def flag_as_modified_for_sourcing
    unless is_sourcing
      sourced_items.each { |sourced_item| sourced_item.update(has_local_modifications: true) }
    end
  end

  # Add a Version based on the current state of this item.
  # Called after save.
  def add_version
    previous_version = versions.last
    version = new_version
    if previous_version
      diff = previous_version.diff_with(version)
      unless diff.size.positive?
        version.destroy
        return
      end
    end
    version.save!
  end

  # set the sourced_items to ignore when destroying this event
  def ignore_sourced_items_on_destroy
    sourced_items.update_all(
      is_ignored: true, item_type: nil, item_id: nil
    )
  end

  # VERSIONS

  def new_version
    versions.build(
      user: editor, edited_at: updated_at, edit_comment: edit_comment,
      title: title, values: values_for_version
    )
  end

  def values_for_version
    {
      timezone: timezone,
      is_allday: is_allday,
      is_draft: is_draft,
      is_approved: is_approved,
      is_wheelchair_accessible: is_wheelchair_accessible,
      is_adults_only: is_adults_only,
      is_tentative: is_tentative,
      is_cancelled: is_cancelled,
      is_featured: is_featured,
      organizer: organizer,
      organizer_url: organizer_url,
      location: location,
      address: address,
      city: city,
      province: province,
      country: country,
      location_url: location_url,
      content: content,
      description: description,
      tag_list: tag_list.to_s,
      start_at: start_at,
      end_at: end_at
    }
  end

  # Setters
  # pre-flight cleaners for attributes passed in

  def title=(title_str)
    self[:title] = TextCleaner.clean(title_str)
  end

  def description=(description_str)
    self[:description] = TextCleaner.clean(description_str)
  end

  def content=(content_str)
    self[:content] = TextCleaner.clean(content_str)
  end

  def organizer=(organizer_str)
    self[:organizer] = TextCleaner.clean(organizer_str)
  end

  def organizer_url=(organizer_url_str)
    self[:organizer_url] = UrlCleaner.clean(organizer_url_str)
  end

  def location=(location_str)
    self[:location] = TextCleaner.clean(location_str)
  end

  def address=(address_str)
    self[:address] = TextCleaner.clean(address_str)
  end

  def city=(city_str)
    self[:city] = TextCleaner.clean(city_str)
  end

  def province=(province_str)
    self[:province] = TextCleaner.clean(province_str)
  end

  def location_url=(location_url_str)
    self[:location_url] = UrlCleaner.clean(location_url_str)
  end

  def tag_list
    @tag_list ||= Wayground::TagList.new(tags: tags, editor: editor)
  end

  # Take a comma-separated string of tag titles,
  # add any tags that don’t already exist for the event,
  # update any changed titles of tags that do exist,
  # remove existing tags that are not in the supplied list.
  def tag_list=(value)
    @tag_list = nil
    tag_list.tags = value
  end

  def save_tag_list
    tag_list.save!
  end

  # VALUES

  # return the earliest date that an event occurs on
  def self.earliest_date
    event = first
    event.start_at.to_date if event
  end

  # return the last date that an event occurs on
  def self.last_date
    # TODO: potentially take into account the last end_date if it is > the last start_date
    event = last
    event.start_at.to_date if event
  end

  def multi_day?
    end_at? && start_at.to_date != end_at.to_date
  end

  # APPROVAL

  # If the event is not already approved,
  # and the given user has authority to approve events,
  # set the is_approved flag
  # (without triggering any sourced_items to be flagged as locally modified).
  def approve_by(user)
    if is_approved?
      true
    elsif user && user.authority_for_area('Calendar', :can_approve)
      # approvals should not affect sourced_items’ locally modified status
      self.is_sourcing = !changed?
      # parameters for the version record to be associated with this approval
      self.editor = user
      self.edit_comment = "Approved by #{user.name}"
      # approve it
      self.is_approved = true
      success = save
      # cleanup
      self.is_sourcing = false
      success # did the record successfully update?
    else
      false
    end
  end

  # iCalendar SOURCE/IMPORT PROCESSING

  # Wrap an operation that needs to be handled with the event coming from a source.
  # Takes a block.
  def perform_from_source(&block)
    self.is_sourcing = true
    yield block
    self.is_sourcing = false
    self
  end

  # Given an iCalendar event hash, try to update this Event.
  # If this Event has local modifications, return false.
  # (That previous bit should eventually change if we come up with a
  # good way to merge remote/sourced changes and local changes.)
  def update_from_icalendar(ievent, has_local_modifications: false, editor: nil, processor: nil)
    if has_local_modifications
      # TODO: handle updating a locally modified, sourced event
      false
    else
      # move this conditional to the start of the method when
      # handling of has_local_modifications is updated above.
      editor = editor
      if editor
        self.editor = editor
        self.edit_comment = "Updated from an iCalendar source by #{editor.name}"
      else
        self.editor ||= User.main_admin
        self.edit_comment = 'Updated from an iCalendar source'
      end
      # TODO: handle updating the associated url from the icalendar event (for external_links)
      success = false
      import_processor = processor || Wayground::Import::IcalImporter.new
      import_processor.editor = self.editor
      perform_from_source do
        success = update(import_processor.icalendar_field_mapping(ievent))
      end
      success
    end
  end

  # General

  def descriptor
    title
  end

  def items_for_path
    [self]
  end
end
