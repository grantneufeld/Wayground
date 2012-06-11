# encoding: utf-8

# Details of a calendar event
class Event < ActiveRecord::Base
  acts_as_authority_controlled :authority_area => 'Calendar', :item_authority_flag_field => :always_viewable
  # editor and edit_comment are used for Version records
  # is_sourcing is set when generating or updating from a Source (and SourcedItem)
  attr_accessor :editor, :edit_comment, :is_sourcing
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
  has_many :sourced_items, :as => :item, :dependent => :delete_all
  has_many :versions, :as => :item, :dependent => :delete_all

  validates_length_of :title, :within => 1..255
  validates_presence_of :start_at
  validate :validate_end_at_not_before_start_at,
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

  before_create :set_timezone
  before_save :approve_if_authority
  after_update :flag_for_sourcing
  after_save :add_version

  def initialize(*args)
    super(*args)
    # if city, province and country are all blank
    if self.country.blank? && self.province.blank? && self.city.blank?
      # use defaults
      self.city ||= Wayground::Application::DEFAULT_CITY
      self.province ||= Wayground::Application::DEFAULT_PROVINCE
      self.country ||= Wayground::Application::DEFAULT_COUNTRY
    end
  end

  # VALIDATION METHODS

  # An event cannot end before it begins.
  def validate_end_at_not_before_start_at
    unless start_at.blank? || end_at.blank? || (start_at.to_datetime <= end_at.to_datetime)
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

  # BEFORE/AFTER CALLBACKS

  # Attempts to set the timezone based on the user’s timezone,
  # falling back to the default timezone.
  # Called before save on create.
  def set_timezone
    if timezone.blank?
      if user.present? && user.timezone?
        self.timezone = user.timezone
      else
        self.timezone = Time.zone_default.name
      end
    end
  end

  # Called before save.
  def approve_if_authority
    if !is_approved && user && user.has_authority_for_area('Calendar', :can_approve)
      self.is_approved = true
    end
  end

  # Called after save on update.
  def flag_for_sourcing
    unless is_sourcing
      sourced_items.each {|sourced_item| sourced_item.update_attributes(has_local_modifications: true) }
    end
  end

  # Add a Version based on the current state of this item.
  # Called after save.
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

  # APPROVAL

  # If the event is not already approved,
  # and the given user has authority to approve events,
  # set the is_approved flag
  # (without triggering any sourced_items to be flagged as locally modified).
  def approve_by(user)
    if is_approved?
      true
    elsif user && user.has_authority_for_area('Calendar', :can_approve)
      # approvals should not affect sourced_items’ locally modified status
      self.is_sourcing = !(self.changed?)
      # parameters for the version record to be associated with this approval
      self.editor = user
      self.edit_comment = "Approved by #{user.name}"
      # approve it
      self.is_approved = true
      success = self.save
      # cleanup
      self.is_sourcing = false
      success # did the record successfully update?
    else
      false
    end
  end

  # iCalendar SOURCE/IMPORT PROCESSING

  # Map the fields from an icalendar VEVENT into a hash for use in
  # creating or updating an Event.
  def self.icalendar_field_mapping(ievent)
    hash = {}
    # Title (summary)
    if ievent['SUMMARY']
      title = ievent['SUMMARY'][:value]
      title.force_encoding('UTF-8') if title.encoding.name.match /ASCII/
      hash[:title] = title
    end
    # Description
    if ievent['DESCRIPTION']
      description = ievent['DESCRIPTION'][:value]
      description.force_encoding('UTF-8') if description.encoding.name.match /ASCII/
      # strip away the url from the description if it’s been appended to the end
      url = ievent['URL'][:value]
      description.sub!(/[ \t\r\n]*#{url.gsub('.', "\\.")}[ \t\r\n]*\z/, '') if url.present?
      # Make sure to keep the description within our size limits
      if description.size > 510
        # TODO: split long icalendar event descriptions into description and content fields
        # find the first paragraph break after the first 100 characters
        line_break_idx = description.index "\n", 100
        content_idx = nil
        if line_break_idx.nil? || line_break_idx > 509
          # first paragraph of description is waaaay too long.
          # Find last sentence break, instead.
          line_break_idx = description.rindex(/[\.\!\?]/, 509)
          line_break_idx += 1 if line_break_idx
        end
        if line_break_idx.nil? || line_break_idx > 509
          # There’s not even a sentence break before the 510th character.
          # So, find last space, instead.
          line_break_idx = description.rindex(' ', 509)
        end
        if line_break_idx.nil? || line_break_idx > 509
          # There’s not even a sentence break before the 510th character.
          # So, arbitrarily break it a short way in...
          line_break_idx = 100
        end
        # copy the description
        hash[:description] = description[0..(line_break_idx - 1)].strip
        # copy the content portion from the description
        hash[:content] = description[line_break_idx..-1].strip
      else
        hash[:description] = description
      end
    end
    # Location
    if ievent['LOCATION']
      location = ievent['LOCATION'][:value]
      location.force_encoding('UTF-8') if location.encoding.name.match /ASCII/
      hash[:location] = location
    end
    # Organizer
    if ievent['ORGANIZER']
      organizer = ievent['ORGANIZER']['CN'] || ievent['ORGANIZER'][:value]
      organizer.force_encoding('UTF-8') if organizer.encoding.name.match /ASCII/
      hash[:organizer] = organizer
    end
    # Dates & Times
    hash[:start_at] = ievent['DTSTART'][:value] if ievent['DTSTART']
    hash[:end_at] = ievent['DTEND'][:value] if ievent['DTEND']

    # The hash of field mappings to ical values:
    hash
  end

  # Create a new Event from an icalendar event hash.
  def self.create_from_icalendar(ievent, ical_editor = nil, approve_by = nil)
    # TODO: split out location details, from icalendar events, into applicable fields
    external_links_attributes = {}
    if ievent['URL']
      external_links_attributes[:external_links_attributes] = [{url: ievent['URL'][:value]}]
    end
    event = Event.new(
      icalendar_field_mapping(ievent).merge(external_links_attributes)
    )
    if ical_editor
      event.editor = ical_editor
      event.edit_comment = "Created from an iCalendar source by #{ical_editor.name}"
    else
      event.editor ||= User.main_admin
      event.edit_comment = "Created from an iCalendar source"
    end
    if !(approve_by.nil?) && !(approve_by.nil?) && approve_by.has_authority_for_area('Calendar', :can_approve)
      event.is_approved = true
    end
    event.is_sourcing = true
    event.save!
    event.is_sourcing = false
    event
  end

  # Given an iCalendar event hash, try to update this Event.
  # If this Event has local modifications, return false.
  # (That previous bit should eventually change if we come up with a
  # good way to merge remote/sourced changes and local changes.)
  def update_from_icalendar(ievent, ical_editor = nil, has_local_modifications = false)
    if has_local_modifications
      # TODO: handle updating a locally modified, sourced event
      false
    else
      # move this conditional to the start of the method when
      # handling of has_local_modifications is updated above.
      if ical_editor
        self.editor = ical_editor
        self.edit_comment = "Updated from an iCalendar source by #{ical_editor.name}"
      else
        self.editor ||= User.main_admin
        self.edit_comment = "Updated from an iCalendar source"
      end
      # TODO: handle updating the associated url from the icalendar event (for external_links)
      self.is_sourcing = true
      success = self.update_attributes(self.class.icalendar_field_mapping(ievent))
      self.is_sourcing = false
      success
    end
  end

  # MERGING

  # Merge the values from this event into the destination event,
  # move this event’s associated records to the destination event,
  # and delete this event.
  def merge_into!(destination_event)
    raise TypeError unless destination_event.is_a? Event
    conflicts = merge_fields_into(destination_event)
    destination_event.save!
    merge_authorities_into(destination_event)
    merge_external_links_into(destination_event)
    move_sourced_items_to(destination_event)
    move_versions_to(destination_event)
    self.reload
    self.delete
    conflicts
  end

  # Merge the values of this Event into the destination event.
  def merge_fields_into(destination_event)
    raise TypeError unless destination_event.is_a? Event
    conflicts = {}
    # This is a “Big Ugly Method” that would probably benefit from some
    # clever coding to DRY it up. But, I’m kind of tired as I write this,
    # so I’m leaving it messy (though functional).
    destination_event.user ||= user
    if start_at? && (start_at != destination_event.start_at)
      if destination_event.start_at?
        conflicts[:start_at] = start_at
      else
        destination_event.start_at = start_at
      end
    end
    if end_at? && (end_at != destination_event.end_at)
      if destination_event.end_at?
        conflicts[:end_at] = end_at
      else
        destination_event.end_at = end_at
      end
    end
    if timezone? && (timezone != destination_event.timezone)
      if destination_event.timezone?
        conflicts[:timezone] = timezone
      else
        destination_event.timezone = timezone
      end
    end
    destination_event.is_allday ||= is_allday
    destination_event.is_draft &&= is_draft
    destination_event.is_approved ||= is_approved
    destination_event.is_wheelchair_accessible ||= is_wheelchair_accessible
    destination_event.is_adults_only ||= is_adults_only
    destination_event.is_tentative &&= is_tentative
    destination_event.is_cancelled ||= is_cancelled
    destination_event.is_featured ||= is_featured
    if title? && (title != destination_event.title)
      if destination_event.title?
        conflicts[:title] = title
      else
        destination_event.title = title
      end
    end
    if description? && (description != destination_event.description)
      if destination_event.description?
        conflicts[:description] = description
      else
        destination_event.description = description
      end
    end
    if content? && (content != destination_event.content)
      if destination_event.content?
        conflicts[:content] = content
      else
        destination_event.content = content
      end
    end
    if organizer? && (organizer != destination_event.organizer)
      if destination_event.organizer?
        conflicts[:organizer] = organizer
      else
        destination_event.organizer = organizer
      end
    end
    if organizer_url? && (organizer_url != destination_event.organizer_url)
      if destination_event.organizer_url?
        conflicts[:organizer_url] = organizer_url
      else
        destination_event.organizer_url = organizer_url
      end
    end
    if location? && (location != destination_event.location)
      if destination_event.location?
        conflicts[:location] = location
      else
        destination_event.location = location
      end
    end
    if address? && (address != destination_event.address)
      if destination_event.address?
        conflicts[:address] = address
      else
        destination_event.address = address
      end
    end
    if city? && (city != destination_event.city)
      if destination_event.city?
        conflicts[:city] = city
      else
        destination_event.city = city
      end
    end
    if province? && (province != destination_event.province)
      if destination_event.province?
        conflicts[:province] = province
      else
        destination_event.province = province
      end
    end
    if country? && (country != destination_event.country)
      if destination_event.country?
        conflicts[:country] = country
      else
        destination_event.country = country
      end
    end
    if location_url? && (location_url != destination_event.location_url)
      if destination_event.location_url?
        conflicts[:location_url] = location_url
      else
        destination_event.location_url = location_url
      end
    end
    conflicts
  end

  # Move non-duplicate authority records associated with this event to another event.
  # Merge the permissions of any duplicates, then remove our duplicate
  def merge_authorities_into(destination_event)
    raise TypeError unless destination_event.is_a? Event
    authorities.each do |authority|
      duplicate_authority = destination_event.authorities.find_by_user_id(authority.user.id)
      if duplicate_authority
        # this merge will delete the authority, keeping the one for the destination
        authority.merge_into!(duplicate_authority)
      end
    end
    authorities.update_all(item_id: destination_event.id)
    destination_event.reload
  end

  # Move non-duplicate external link records associated with this event to another event.
  def merge_external_links_into(destination_event)
    raise TypeError unless destination_event.is_a? Event
    external_links.each do |external_link|
      duplicate_link = destination_event.external_links.find_by_url(external_link.url)
      # dispose of the link if it has a duplicate in the destination
      external_link.delete if duplicate_link
    end
    # we got rid of duplicates, now move over any remaining external links
    external_links.update_all(item_id: destination_event.id)
    destination_event.reload
  end

  # Move all of the sourced item records associated with this event to another event.
  def move_sourced_items_to(destination_event)
    raise TypeError unless destination_event.is_a? Event
    sourced_items.update_all(item_id: destination_event.id, has_local_modifications: true)
    destination_event.reload
  end

  # Move all of the versions records associated with this event to another event.
  def move_versions_to(destination_event)
    raise TypeError unless destination_event.is_a? Event
    versions.update_all(item_id: destination_event.id)
    destination_event.reload
  end

end
