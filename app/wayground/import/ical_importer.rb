require 'import/icalendar_reader'
require 'open-uri'
require 'event'
require 'user'

module Wayground
  module Import

    # Read iCalendar format files and generate/update applicable Event records.
    class IcalImporter
      attr_accessor :source, :io, :new_events, :updated_events, :skipped_ievents, :editor, :approve_by

      # Create an IcalImporter for a given Source and run the processing.
      # The optional :user param will be used to set the Editor on Version records
      # associated with the Events generated.
      # The optional :approve param flag determines if the generated items will be approved.
      def self.process_source(source, user: nil, approve: nil)
        processor = new
        processor.source = source
        processor.editor = user
        processor.approve_by = user if approve
        processor.process
        processor
      end

      def initialize
        @new_events = []
        @updated_events = []
        @skipped_ievents = []
      end

      # Requires self.source to be set
      def process
        # download the url
        @io = open(source.url) # source.method, source.post_args need to be handled, but open-uri doesn't
        # process the data from it
        process_data
        # cleanup
        @io.close
        self
      end

      # # Process an iCalendar format file retrieved from a remote URL.
      # def process_url(url)
      #   # download the url
      #   @io = open(url)
      #   # process the data from it
      #   process_data
      #   # cleanup
      #   @io.close
      #   self
      # end
      #
      # # Process an iCalendar format file at the given filepath.
      # def process_filepath(filepath)
      #   @io = File.open(filepath)
      #   process_data
      #   @io.close
      #   self
      # end

      # protected

      # Process an iCalendar format IO.
      # ical_processor.io must be set before this is called
      def process_data
        calendars = Wayground::Import::IcalendarReader.new(io: io).parse
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
          sourced_item = source.sourced_items.where(source_identifier: uid).first
        end
        if sourced_item && sourced_item.is_ignored
          # skip ignored items
          skipped_ievents << { ievent: ievent, sourced_item: sourced_item }
          return self
        end
        if sourced_item
          # check if our Event for it is in the past, but the ievent is in the future
          # if so, make a new sourced item
          current_time = Time.zone.now
          if sourced_item.item.start_at < current_time
            ievent_start = ievent['DTSTART'] ? ievent['DTSTART'][:value] : nil
            sourced_item = nil if ievent_start > current_time
          end
        end
        if sourced_item
          if sourced_item.item.update_from_icalendar(
            ievent,
            editor: editor,
            has_local_modifications: sourced_item.has_local_modifications,
            processor: self
          )
            updated_events << sourced_item.item
          else
            skipped_ievents << { ievent: ievent, sourced_item: sourced_item }
          end
        else
          event = create_event(ievent, editor: editor, approve_by: approve_by)
          new_events << event
          sourced_item = source.sourced_items.build(
            source_identifier: uid, last_sourced_at: source.last_updated_at
          )
          sourced_item.item = event
          sourced_item.save!
        end
        self
      end

      def create_event(ievent, editor: nil, approve_by: nil)
        # TODO: split out location details, from icalendar events, into applicable fields
        external_links_attributes = {}
        ievent_url = ievent['URL']
        external_links_attributes[:external_links_attributes] = [{ url: ievent_url[:value] }] if ievent_url
        event = ::Event.new(icalendar_field_mapping(ievent).merge(external_links_attributes))
        if editor
          event.editor = editor
          event.edit_comment = "Created from an iCalendar source by #{editor.name}"
        else
          event.editor ||= ::User.main_admin
          event.edit_comment = 'Created from an iCalendar source'
        end
        event.is_approved = true if approve_by && approve_by.authority_for_area('Calendar', :can_approve)
        event.perform_from_source { event.save! }
      end

      # Map the fields from an icalendar VEVENT into a hash for use in
      # creating or updating an Event.
      def icalendar_field_mapping(ievent)
        result = {}
        # Title (summary)
        if ievent['SUMMARY']
          title = ievent['SUMMARY'][:value]
          title.force_encoding('UTF-8') if title.encoding.name =~ /ASCII/
          result[:title] = title
        end
        # Description
        if ievent['DESCRIPTION']
          description = ievent['DESCRIPTION'][:value]
          # description.force_encoding('UTF-8') if description.encoding.name.match /ASCII/
          # strip away the url from the description if it’s been appended to the end
          url = ievent['URL'][:value]
          if url.present?
            description.sub!(/([ \t\r\n]*Details:)?[ \t\r\n]*#{url.gsub('.', "\\.")}[ \t\r\n]*\z/, '')
          end
          # Make sure to keep the description within our size limits
          if description.size > 510
            # TODO: split long icalendar event descriptions into description and content fields
            # find the first paragraph break after the first 100 characters
            line_break_idx = description.index "\n", 100
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
            result[:description] = description[0..(line_break_idx - 1)].strip
            # copy the content portion from the description
            result[:content] = description[line_break_idx..-1].strip
          else
            result[:description] = description
          end
        end
        # Location
        if ievent['LOCATION']
          location = ievent['LOCATION'][:value]
          location.force_encoding('UTF-8') if location.encoding.name =~ /ASCII/
          result[:location] = location
        end
        # Organizer
        if ievent['ORGANIZER']
          organizer = ievent['ORGANIZER']['CN'] || ievent['ORGANIZER'][:value]
          organizer.force_encoding('UTF-8') if organizer.encoding.name =~ /ASCII/
          result[:organizer] = organizer
        end
        # Dates & Times
        result[:start_at] = ievent['DTSTART'][:value] if ievent['DTSTART']
        result[:end_at] = ievent['DTEND'][:value] if ievent['DTEND']

        # The hash of field mappings to ical values:
        result
      end
    end

  end
end
