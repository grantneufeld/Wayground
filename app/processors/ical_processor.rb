# encoding: utf-8
require 'icalendar_reader'
require 'open-uri'

# Read iCalendar format files and generate/update applicable Event records.
class IcalProcessor
  attr_accessor :source, :io, :new_events, :updated_events, :skipped_ievents, :editor, :approve_by

  # Create an IcalProcessor for a given Source and run the processing.
  # The optional user arg will be used to set the Editor on Version records
  # associated with the Events generated.
  def self.process_source(source, user = nil, approve = false)
    processor = self.new
    processor.source = source
    processor.editor = user
    processor.approve_by = user if approve
    processor.process
    processor
  end

  def initialize
    self.new_events = []
    self.updated_events = []
    self.skipped_ievents = []
  end

  # Requires self.source to be set
  def process
    # download the url
    self.io = open(source.url) # source.method, source.post_args need to be handled, but open-uri doesn't
    # process the data from it
    process_data
    # cleanup
    self.io.close
    self
  end

  ## Process an iCalendar format file retrieved from a remote URL.
  #def process_url(url)
  #  # download the url
  #  self.io = open(url)
  #  # process the data from it
  #  process_data
  #  # cleanup
  #  self.io.close
  #  self
  #end
  #
  ## Process an iCalendar format file at the given filepath.
  #def process_filepath(filepath)
  #  self.io = File.open(filepath)
  #  process_data
  #  self.io.close
  #  self
  #end

  #protected

  # Process an iCalendar format IO.
  # ical_processor.io must be set before this is called
  def process_data
    calendars = IcalendarReader.new.parse(io)
    calendars.each do |calendar|
      process_icalendar(calendar)
    end
    self
  end

  # Generate or update Events from the VEVENTs in an iCalendar.
  def process_icalendar(icalendar)
    if icalendar['VEVENT']
      icalendar['VEVENT'].each do |ievent|
        process_event(ievent)
      end
    end
    self
  end

  # Generate or update an Event from a VEVENT (iCalendar event).
  def process_event(ievent)
    uid = ievent['UID'] ? ievent['UID'][:value] : nil
    sourced_item = nil
    if uid
      # check for pre-existing Event matching the ievent.uid
      sourced_item = source.sourced_items.find_by_source_identifier(uid)
    end
    if sourced_item
      if sourced_item.item.update_from_icalendar(ievent, editor, sourced_item.has_local_modifications)
        updated_events << sourced_item.item
      else
        skipped_ievents << {ievent: ievent, sourced_item: sourced_item}
      end
    else
      event = Event.create_from_icalendar(ievent, editor, approve_by)
      new_events << event
      sourced_item = source.sourced_items.new(
        source_identifier: uid, last_sourced_at: source.last_updated_at
      )
      sourced_item.item = event
      sourced_item.save!
    end
    self
  end

end
