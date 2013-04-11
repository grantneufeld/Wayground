# encoding: utf-8
require 'html_presenter'

# Meta elements to go in the head element.
class MetadataPresenter < HtmlPresenter
  attr_reader :view, :url, :title, :description, :image_url, :image_height, :image_width,
    :twitter_creator, :cache

  # Requires:
  # :view - generally passed in as `self` from a view
  # Accepts:
  # :title
  # :type - defaults to "article" (or "website" for root url)
  # :url - defaults to request.url
  # :description
  # :image_url
  # :image_height, :image_width
  # :twitter_creator - the @ username of the user responsible for the current page’s content, without the "@"
  # :cache - :no if the page is not to be remotely cached
  def initialize(params={})
    @view = params[:view]
    @graph_type = params[:type]
    @title = params[:title]
    set_url(params)
    @description = params[:description]
    set_image(params)
    set_twitter_creator(params)
    @cache = params[:cache]
  end

  def present_title
    html_tag(:title) { page_title }
  end

  def present_metatags
    present_description +
    present_open_graph_specific +
    present_open_graph_common +
    present_image +
    present_twitter +
    present_cache
  end

  def present_description
    meta_tag(:description, description)
  end

  # The tags that are just used by OpenGraph
  # og:type: “activity”?, Groups: “cause”, Organizations: “government”, “non_profit”, “school”, People: “author”, “politician”, “public_figure”, Places: “City”, “Country”, “state_province”, Websites: “website” site root, “article” site page.
  def present_open_graph_specific
    og_tag(:type, graph_type)
  end

  # The tags that are used by both OpenGraph and Twitter Cards (except image)
  # og:url: canonical url for the content
  # og:title: title for the page/content
  # og:description: max 200 characters
  # og:site_name: name of the website
  def present_open_graph_common
    og_tag(:title, title) +
    og_tag(:url, url) +
    og_tag(:description, description) +
    og_tag(:site_name, site_name)
  end

  # The Open Graph image tags. Shared with Twitter Cards.
  # TODO: allow for a separate Twitter Card specific image if there is an optimized variant
  # og:image: url to an image >60x60px, <1mb, Twitter will crop to max 120px per side
  # og:image:width: in pixels
  # og:image:height: in pixels
  def present_image
    og_tag(:image, image_url) +
    og_tag('image:height', image_height) +
    og_tag('image:width', image_width)
  end

  # Twitter Card metadata tags
  # twitter:site: the user’s @ username on Twitter
  # twitter:site:id: the user’s id number on Twitter
  # twitter:creator: the content creator’s @ username on Twitter
  # twitter:creator:id: the content creator’s id number on Twitter
  def present_twitter
    twitter_tag(:site, twitter_site) +
    twitter_tag(:creator, twitter_creator)
  end

  def present_cache
    if cache == :no
      html_tag_with_newline(:meta, name: 'robots', content: 'noindex')
    else
      html_blank
    end
  end

  protected

  def set_url(params)
    @url = params[:url]
    @url = @view.request.url if @url.blank?
  end

  def set_image(params)
    @image_url = params[:image_url]
    @image_height = params[:image_height]
    @image_width = params[:image_width]
  end

  def set_twitter_creator(params)
    @twitter_creator = params[:twitter_creator]
    unless @twitter_creator.blank? || @twitter_creator[0] == '@'
      @twitter_creator = "@#{@twitter_creator}"
    end
  end

  def is_root?
    @view.request.path == '/'
  end

  def page_title
    if title.blank? or is_root?
      site_name
    else
      "#{title} [#{site_name}]"
    end
  end

  def graph_type
    @graph_type ||= is_root? ? 'website' : 'article'
  end

  def site_name
    @site_name ||= Wayground::Application::NAME
  end

  def twitter_site
    @twitter_site ||= "@#{Wayground::Application::TWITTER_AT}"
  end

  def meta_tag(key, value)
    meta_tag_or_blank(name: key, content: value)
  end
  def og_tag(key, value)
    meta_tag_or_blank(property: "og:#{key}", content: value)
  end
  def twitter_tag(key, value)
    meta_tag_or_blank(name: "twitter:#{key}", value: value)
  end

  def meta_tag_or_blank(params)
    if params[:content].blank? && params[:value].blank?
      html_blank
    else
      html_tag_with_newline(:meta, params)
    end
  end
end
