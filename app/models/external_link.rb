# encoding: utf-8

# External weblinks representing an item in our system.
# E.g., a link to an event listing on another website might be for the same Event as listed on our site.
class ExternalLink < ActiveRecord::Base
  acts_as_authority_controlled :authority_area => 'Content'
  attr_accessible :title, :url

  belongs_to :item, :polymorphic => true

  validates_presence_of :item_type, :item_id
  validates_presence_of :title
  validates_length_of :title, :within => 1..255
  validates_presence_of :url
  validates_length_of :url, :within => 1..1023
  validates_format_of :url,
    :with => /\Ahttps?:\/\/[A-Za-z0-9:\.\-]+(\/[\w%~_\?=&\.\#\/\-]*)?\z/,
    :message => 'must be a valid weblink (including ‘http://’)'
  validates_numericality_of :position, :only_integer => true, :greater_than => 0

  before_validation :set_default_position

  # Set the position to the end of the list of external links for the item,
  # if it is not already set.
  def set_default_position
    # only set the position if it isn’t already set
    if position.nil?
      new_position = 1
      unless item.nil?
        # get the external link on the item that has the highest position
        last_link = item.external_links.order('position DESC').first
        if last_link
          new_position = last_link.position + 1
        end
      end
      self.position = new_position
    end
  end

  # Return an html anchor element using the ExternalLink’s url and title.
  # @attributes [hash] - optional `:class` and/or `:id` fields to go in the anchor tag.
  def to_html(attributes = {})
    attrs = []
    # id
    attrs << " id=\"#{attributes[:id]}\"" unless attributes[:id].blank?
    # class
    classes = [attributes[:class], site].delete_if {|val| val.blank?}
    class_str = classes.join(' ')
    attrs << " class=\"#{class_str}\"" unless class_str.blank?
    # the element tag
    "<a href=\"#{url}\"#{attrs.join}>#{title}</a>"
  end
end
