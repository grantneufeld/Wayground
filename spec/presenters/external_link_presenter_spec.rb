# encoding: utf-8
require 'spec_helper'
require 'external_link_presenter'
require_relative 'view_double'

describe ExternalLinkPresenter do
  let(:view) { $view = ViewDouble.new }
  let(:item) { $item = Event.new(title: 'Event') }
  let(:link) do
    $link = item.external_links.build(title: 'External Link', url: 'http://external.link/')
    $link.item = item
    $link
  end

  let(:presenter) { $presenter = ExternalLinkPresenter.new(view: view, link: link) }

  describe 'initialization' do
    it 'should take a view parameter' do
      expect( ExternalLinkPresenter.new(view: :view).view ).to eq :view
    end
    it 'should take a link parameter' do
      expect( ExternalLinkPresenter.new(link: :link).link ).to eq :link
    end
    it 'should take a user parameter' do
      expect( ExternalLinkPresenter.new(user: :user).user ).to eq :user
    end
  end

  describe '#present_link_in' do
    it 'should default to a span element' do
      expect( presenter.present_link_in ).to match /\A<span /
    end
    it 'should be html safe' do
      expect( presenter.present_link_in.html_safe? ).to be_true
    end
    context 'with no site' do
      it 'should default to “website” as the tag class' do
        expect( presenter.present_link_in ).to match(/\A<[^>]+ class="website"/)
      end
      it 'should not have a label' do
        expect( presenter.present_link_in ).not_to match(/ class="label"/)
      end
    end
    context 'with a recognized site' do
      it 'should use the site as the tag class' do
        link.site = 'google'
        expect( presenter.present_link_in ).to match(/\A<[^>]+ class="google"/)
      end
      it 'should include a label' do
        link.site = 'google'
        expect( presenter.present_link_in ).to match /<span class="label">Google: <\/span>/
      end
      it 'should be html safe' do
        link.site = 'google'
        expect( presenter.present_link_in.html_safe? ).to be_true
      end
    end
    context 'with a tag type' do
      it 'should use the given tag type' do
        expect( presenter.present_link_in(:div) ).to match /\A<div /
      end
    end
    context 'loaded up' do
      it 'should return the tagged link with a label' do
        link.url = 'http://loaded.up/link'
        link.title = 'Loaded Up'
        link.site = 'linkedin'
        expect( presenter.present_link_in(:li) ).to eq(
          '<li class="linkedin">' +
          '<span class="label">LinkedIn: </span>' +
          '<a href="http://loaded.up/link" class="url" title="Loaded Up" target="_blank">Loaded Up</a>' +
          '</li>'
        )
      end
    end
  end

  describe '#present_label' do
    context 'with no site' do
      it 'should return an empty string' do
        expect( presenter.present_label ).to eq ''
      end
      it 'should be html safe' do
        expect( presenter.present_label.html_safe? ).to be_true
      end
    end
    context 'with an unrecognized site' do
      it 'should return an empty string' do
        link.site = 'unrecognized'
        expect( presenter.present_label ).to eq ''
      end
    end
    context 'with the site set to “flickr”' do
      it 'should return a span label element' do
        link.site = 'flickr'
        expect( presenter.present_label ).to eq '<span class="label">Flickr: </span>'
      end
      it 'should be html safe' do
        link.site = 'flickr'
        expect( presenter.present_label.html_safe? ).to be_true
      end
    end
  end

  describe '#present_link_as_url_class' do
    it 'should generate an “a” tag' do
      expect( presenter.present_link_as_url_class ).to eq(
        '<a href="http://external.link/" class="url" title="External Link" target="_blank">External Link</a>'
      )
    end
  end

  describe '#present_link' do
    it 'should generate an “a” tag' do
      expect( presenter.present_link ).to eq(
        '<a href="http://external.link/" class="url website" title="External Link" target="_blank">External Link</a>'
      )
    end
  end


  # protected methods

  describe '#label_text' do
    it 'should handle “facebook”' do
      link.site = 'facebook'
      expect( presenter.send(:label_text) ).to eq 'Facebook'
    end
    it 'should handle “flickr”' do
      link.site = 'flickr'
      expect( presenter.send(:label_text) ).to eq 'Flickr'
    end
    it 'should handle “google”' do
      link.site = 'google'
      expect( presenter.send(:label_text) ).to eq 'Google'
    end
    it 'should handle “instagram”' do
      link.site = 'instagram'
      expect( presenter.send(:label_text) ).to eq 'Instagram'
    end
    it 'should handle “linkedin”' do
      link.site = 'linkedin'
      expect( presenter.send(:label_text) ).to eq 'LinkedIn'
    end
    it 'should handle “twitter”' do
      link.site = 'twitter'
      expect( presenter.send(:label_text) ).to eq 'Twitter'
    end
    it 'should handle “vimeo”' do
      link.site = 'vimeo'
      expect( presenter.send(:label_text) ).to eq 'Vimeo'
    end
    it 'should handle “youtube”' do
      link.site = 'youtube'
      expect( presenter.send(:label_text) ).to eq 'YouTube'
    end
  end

end
