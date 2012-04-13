# encoding: utf-8
require 'spec_helper'
require 'wayground_form_builder'

describe WaygroundFormBuilder, :type => :view do
  describe '#date_field' do
    let :template do
      <<-EOTEMPLATE
      <%= form_for(event, :builder => WaygroundFormBuilder) do |f| %>
      <%= f.date_field(:start_at) %>
      <% end %>
      EOTEMPLATE
    end

    it 'should generate a text field' do
      render :inline => template, :locals => {:event => Event.new}
      rendered.should match /<input ([^<>]* )?type="text"( [^<>]+)? \/>/
    end
    it 'should assign the right field name' do
      render :inline => template, :locals => {:event => Event.new}
      rendered.should match /<input ([^<>]+ )?name="event\[start_at\]"( [^<>]+)? \/>/
    end
    it 'should present dates in natural language' do
      render :inline => template, :locals => {:event => Event.new(:start_at => '2001-02-03')}
      rendered.should match /<input ([^<>]+ )?value="February +3, 2001"( [^<>]+)? \/>/
    end
  end

  describe '#datetime_field' do
    let :template do
      <<-EOTEMPLATE
      <%= form_for(event, :builder => WaygroundFormBuilder) do |f| %>
      <%= f.datetime_field(:start_at) %>
      <% end %>
      EOTEMPLATE
    end

    it 'should generate a text field' do
      render :inline => template, :locals => {:event => Event.new}
      rendered.should match /<input ([^<>]* )?type="text"( [^<>]+)? \/>/
    end
    it 'should assign the right field name' do
      render :inline => template, :locals => {:event => Event.new}
      rendered.should match /<input ([^<>]+ )?name="event\[start_at\]"( [^<>]+)? \/>/
    end
    it 'should present dates in natural language' do
      render :inline => template, :locals => {:event => Event.new(:start_at => '2001-02-03 04:05:00')}
      rendered.should match /<input ([^<>]+ )?value="February +3, 2001 at +4:05 AM"( [^<>]+)? \/>/
    end
  end
end
