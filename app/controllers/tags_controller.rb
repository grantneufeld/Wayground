require 'tag'

# View information about tags, and access content through tags.
class TagsController < ApplicationController
  before_action :set_section, except: [:index]

  def index
    @tags_with_counts = Tag.tag_labels.grouped_with_counts
  end

  def tag
    @tag = Tag.where(tag: params[:tag]).first
    # TODO: display the items tagged with the tag
  end

  protected

  def set_section
    @site_section = :tags
  end
end
