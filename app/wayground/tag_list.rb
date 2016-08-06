require 'tag'

module Wayground

  # Wrapper for the tags association on a model.
  # Supports conversion to a string (comma-separated list of tag titles) and back.
  class TagList
    attr_reader :tags, :editor

    def initialize(tags: nil, editor: nil)
      @tags = tags || []
      @editor = editor
      @modified = []
    end

    def to_s
      list = tags.map(&:title)
      list.join ', '
    end

    # Take a comma-separated string of tag titles,
    # add any tags that don’t already exist for the event,
    # update any changed titles of tags that do exist,
    # remove existing tags that are not in the supplied list.
    def tags=(value)
      determine_existing_tags
      figure_out_tags_to_include(value)
      remove_leftover_existing_tags
    end

    # protected - The rest of the methods would be protected, except I want to access them easily in testing

    # build a list of existing tags, indexed off of the taggified tag value (not the title)
    def determine_existing_tags
      @existing_tags = {}
      tags.each { |tag| @existing_tags[tag.tag] = tag }
      @existing_tags
    end

    # include each of the tags (by title) in the passed in string
    def figure_out_tags_to_include(value)
      tag_titles_from_string(value).each do |title|
        include_tag_title(title)
      end
    end

    # convert a string of comma-separated tag titles to an array
    def tag_titles_from_string(value)
      value.sub!(/^[ "']+/, '')
      value.sub!(/[ "']+$/, '')
      value.split(/[ "']*,[ "']*/)
    end

    # specify a tag to be included in the list
    def include_tag_title(title)
      # the @tagged list is used to keep track of tags we’ve already added/confirmed,
      # to prevent trying to create duplicate tags.
      @tagged ||= []
      tag_text = Tag.new.taggify_text(title)
      return if tag_text.blank? || @tagged.include?(tag_text)
      @tagged << tag_text
      ensure_tag_title(title)
    end

    def ensure_tag_title(title)
      new_tag(title) unless update_existing_tag(title)
    end

    def update_existing_tag(title)
      tag_text = Tag.new.taggify_text(title)
      tag = @existing_tags[tag_text]
      if tag
        if title != tag.title
          tag.title = title
          @modified << tag
        end
        @existing_tags.delete(tag_text)
      end
      tag
    end

    def new_tag(title)
      tag = tags.build(title: title)
      tag.user = editor
      @modified << tag
      tag
    end

    # destroy any existing tags that weren’t in the passed in tag list string
    def remove_leftover_existing_tags
      @existing_tags.each do |_key, tag|
        tags.delete(tag)
        tag.destroy
      end
      @existing_tags = {}
    end

    def save!
      @modified.each(&:save!)
      @modified = []
    end

    # convenience methods for testing only
    attr_accessor :existing_tags, :tagged, :modified
  end

end
