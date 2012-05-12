# encoding: utf-8

# Sources for data, linking to processors to use to generate local items from that data.
# Types of sources might include RSS feeds, iCalendars, APIs, microformat scrapings, etc.
# May be dynamically maintained so the local items generated from the Source
# can be updated based on changes to the Source.
class Source < ActiveRecord::Base
  acts_as_authority_controlled :authority_area => 'Source', :item_authority_flag_field => :always_private
  attr_accessible :description, :method, :options, :post_args, :processor, :refresh_after_at, :title, :url

  belongs_to :container_item, :polymorphic => true
  belongs_to :datastore

  before_validation :set_defaults, :on => :create

  #validates_presence_of :processor
  validates_inclusion_of :processor, :in => %w( IcalProcessor )
  validates_inclusion_of :method, :in => %w( get post )
  validates_format_of :url, :with => /\A[a-z]+:\/+[^ \r\n\t]+\z/,
    :message => 'must begin with a valid URL (starting with ‘http://’ or equivalent)'
  validate :validate_dates

  # Set default values for the Source. Should only be called once on create.
  def set_defaults
    self.method = 'get' unless method?
  end

  # last_update_at should not be set in the future.
  def validate_dates
    if last_updated_at? && (last_updated_at.to_datetime > Time.now.to_datetime)
      errors.add(:last_updated_at, 'must not be in the future')
    end
  end

  # Get a human readable string to describe the Source.
  def name
    if title?
      title
    else
      "Source #{id}"
    end
  end

  # Run the processor defined by this Source.
  def process
    case processor
    when 'IcalProcessor'
      #ical_processor = IcalProcessor.process_source(self)
      #ical_processor.result
    end
    nil
  end
end
