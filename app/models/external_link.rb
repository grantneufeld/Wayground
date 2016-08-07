require 'url_cleaner'
require 'http_url_validator'

# External weblinks representing an item in our system.
# E.g., a link to an event listing on another website might be for the same Event as listed on our site.
class ExternalLink < ApplicationRecord
  acts_as_authority_controlled authority_area: 'Content', inherits_from: :item

  belongs_to :item, polymorphic: true

  default_scope { order(:item_type, :item_id, :position) }

  # can’t require the item to be set before initial save when using nested attribute forms
  validates :item_type, :item_id, presence: { on: :update }
  validates :title, presence: true, length: { within: 1..255 }
  validates :url, presence: true, length: { in: 1..1023 }, http_url: true
  validates :position, numericality: { only_integer: true, greater_than: 0 }

  before_validation :set_default_position
  before_validation :set_title
  before_validation :set_site

  # Set the position to the end of the list of external links for the item,
  # if it is not already set.
  def set_default_position
    # only set the position if it isn’t already set
    unless position
      new_position = 1
      if item
        # get the external link on the item that has the highest position
        last_link = item.external_links.order('position DESC').first
        new_position = last_link.position + 1 if last_link
      end
      self.position = new_position
    end
  end

  # Add a title if not manually set
  def set_title
    self.title = title_from_url if title.blank? && url.present?
  end

  def title_from_url
    # TODO: scrape the title from the remote url?
    case url
    when %r{\Ahttps?://(?:[a-z0-9\.]*\.)facebook.com/events/[0-9]+}
      'Facebook event'
    when %r{\Ahttps?://(?:[a-z0-9\.\-]*\.)eventbrite.com/}
      'Event Registration (Eventbrite)'
    when %r{\Ahttps?://(?:[a-z0-9\.]*\.)meetup.com/(.+/)?events/.+}
      'Meetup event'
    when %r{\A[a-z]+:/*([^:/]+)}
      Regexp.last_match(1) # use the url’s domain
    end
  end

  def set_site
    if site.blank? && domain
      match = domain.match(/\A(?:.*\.)?(facebook|flickr|instagram|linkedin|twitter|vimeo|youtube).com\z/)
      self.site = match[1] if match
      self.site = 'google' if site.blank? && domain == 'plus.google.com'
    end
  end

  def url=(url_str)
    self[:url] = UrlCleaner.clean(url_str)
  end

  # Return an html anchor element using the ExternalLink’s url and title.
  # @attributes [hash] - optional `:class` and/or `:id` fields to go in the anchor tag.
  def to_html(attributes = {})
    attrs = []
    # id
    attributes_id = attributes[:id]
    attrs << " id=\"#{attributes_id}\"" unless attributes_id.blank?
    # class
    classes = [attributes[:class], site].delete_if(&:blank?)
    class_str = classes.join(' ')
    attrs << " class=\"#{class_str}\"" unless class_str.blank?
    # the element tag
    "<a href=\"#{url}\"#{attrs.join}>#{title}</a>"
  end

  def domain
    return unless url.present?
    match = url.match %r{\A[a-z]+:/*([^:/]+)}
    match[1] if match
  end

  def descriptor
    title
  end

  def items_for_path
    item.items_for_path << self
  end
end
