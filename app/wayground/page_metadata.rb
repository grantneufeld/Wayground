# encoding: utf-8

module Wayground

  # title: Used in the <title> meta tag. If blank, defaults to the site title.
  # description: Plain text string to be used as the value for the <meta name="description"> tag.
  # nocache: A boolean that instructs browsers and search engines not to cache the content of this page.
  class PageMetadata
    attr_accessor :title, :description, :nocache

    def initialize(params={})
      @title = params[:title]
      @description = params[:description]
      @nocache = params[:nocache] || false
    end

    def merge_params(params={})
      @title = params[:title] if params[:title]
      @description = params[:description] if params[:description]
      @nocache = params[:nocache] unless params[:nocache].nil?
    end

  end

end
