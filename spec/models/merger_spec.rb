# encoding: utf-8
require 'spec_helper'

describe Merger::Base do

  describe "initialization" do
    it "should accept a source" do
      source = double('source')
      Merger::Base.new(source).source.should eq source
    end
  end

  describe "#merge_into!" do
    it "should call all the merge into methods, delete the source, and return the conflicts" do
      source = double('source')
      source.should_receive(:delete)
      dest = double('destination')
      merger = Merger::Base.new(source)
      merger.should_receive(:merge_fields_into).with(dest).and_return(:conflicts)
      merger.should_receive(:merge_authorities_into).with(dest)
      merger.should_receive(:merge_external_links_into).with(dest)
      merger.should_receive(:merge_sourced_items_into).with(dest)
      merger.should_receive(:merge_versions_into).with(dest)
      merger.merge_into!(dest).should eq :conflicts
    end
  end

  describe "#merge_fields_into" do
    it "should save the changes to the destination" do
      dest = double('destination')
      dest.should_receive(:save!)
      Merger::Base.new(nil).merge_fields_into(dest)
    end
    it "should return a hash" do
      dest = double('destination')
      dest.stub(:save!)
      Merger::Base.new(nil).merge_fields_into(dest).should eq({})
    end
  end

  describe "#merge_authorities_into" do
    it "should move over any non-duplate authorities" do
      # set up the source
      source = double('source')
      authorities = []
      source.stub(authorities: authorities)
      # set up the destination
      dest = double('destination')
      dest.stub(id: 123)
      # what we’re testing for:
      authorities.should_receive(:update_all).with(item_id: 123)
      # Do the merger operation
      merger = Merger::Base.new(source)
      merger.merge_authorities_into(dest)
    end

    it "should merge the details of any duplicate authorities" do
      # set up the source
      user = double('user')
      user.stub(id: 234)
      source = double('source')
      source_authority = double('authority')
      source_authority.stub(user: user)
      authorities = [source_authority]
      authorities.stub(:update_all)
      source.stub(authorities: authorities)
      # set up the destination
      dest = double('destination')
      dest.stub(id: 0)
      destination_authority = double('destination authority')
      dest_authorities_where = double('authorities where')
      dest_authorities_where.stub(:first).and_return(destination_authority)
      dest_authorities = double('authorities')
      dest_authorities.stub(:where).with(user_id: 234).and_return(dest_authorities_where)
      dest.stub(authorities: dest_authorities)
      # What we’re testing for:
      source_authority.should_receive(:merge_into!).with(destination_authority)
      # Do the merger operation
      merger = Merger::Base.new(source)
      merger.merge_authorities_into(dest)
    end
  end

  describe "#merge_external_links_into" do
    it "should move over any non-duplate external links" do
      # set up the source
      source = double('source')
      links = []
      source.stub(external_links: links)
      # set up the destination
      dest = double('destination')
      dest.stub(id: 345)
      # what we’re testing for:
      links.should_receive(:update_all).with(item_id: 345)
      # Do the merger operation
      merger = Merger::Base.new(source)
      merger.merge_external_links_into(dest)
    end

    it "should delete any duplicate external links on the source" do
      # set up the source
      source = double('source')
      source_link = double('link')
      source_link.stub(url: 'url')
      links = [source_link]
      links.stub(:update_all)
      source.stub(external_links: links)
      # set up the destination
      dest = double('destination')
      dest.stub(id: 0)
      destination_link = double('destination link')
      dest_links_where = double('links where')
      dest_links_where.stub(:first).and_return(destination_link)
      dest_links = double('links')
      dest_links.stub(:where).with(url: 'url').and_return(dest_links_where)
      dest.stub(external_links: dest_links)
      # What we’re testing for:
      source_link.should_receive(:delete)
      # Do the merger operation
      merger = Merger::Base.new(source)
      merger.merge_external_links_into(dest)
    end
  end

  describe "#merge_sourced_items_into" do
    it "should reassign sourced_items to the other event with local modifications flag set" do
      # set up the source
      source = double('source')
      sourced_items = []
      source.stub(sourced_items: sourced_items)
      # set up the destination
      dest = double('destination')
      dest.stub(id: 456)
      # what we’re testing for:
      sourced_items.should_receive(:update_all).with(item_id: 456, has_local_modifications: true)
      # Do the merger operation
      merger = Merger::Base.new(source)
      merger.merge_sourced_items_into(dest)
    end
  end

  describe "#merge_versions_into" do
    it "should reassign versions to the destination" do
      # set up the source
      source = double('source')
      versions = []
      source.stub(versions: versions)
      # set up the destination
      dest = double('destination')
      dest.stub(id: 567)
      # what we’re testing for:
      versions.should_receive(:update_all).with(item_id: 567)
      # Do the merger operation
      merger = Merger::Base.new(source)
      merger.merge_versions_into(dest)
    end
  end
end

describe Merger::EventMerger do
  describe "#merge_fields_into" do
    # TODO: DRY up the EventMerger#merge_fields_into method since it’s a bit unwieldy and repetitious

    it "should set the field values on the destination when the destination is blank" do
      source = double('source')
      dest = double('destination')
      dest.stub(:save!)
      # ignore flag fields
      dest.stub(is_allday: true)
      dest.stub(is_draft: false)
      dest.stub(is_approved: true)
      dest.stub(is_wheelchair_accessible: true)
      dest.stub(is_adults_only: true)
      dest.stub(is_tentative: false)
      dest.stub(is_cancelled: true)
      dest.stub(is_featured: true)
      # what we’re testing for:
      source.stub(user: :user)
      dest.stub(user: nil)
      dest.should_receive(:user=).with(:user)
      source.stub(:start_at? => true)
      source.stub(start_at: :start_at)
      dest.stub(start_at: nil)
      dest.stub(:start_at? => false)
      dest.should_receive(:start_at=).with(:start_at)
      source.stub(:end_at? => true)
      source.stub(end_at: :end_at)
      dest.stub(end_at: nil)
      dest.stub(:end_at? => false)
      dest.should_receive(:end_at=).with(:end_at)
      source.stub(:timezone? => true)
      source.stub(timezone: :timezone)
      dest.stub(timezone: nil)
      dest.stub(:timezone? => false)
      dest.should_receive(:timezone=).with(:timezone)
      source.stub(:title? => true)
      source.stub(title: :title)
      dest.stub(title: nil)
      dest.stub(:title? => false)
      dest.should_receive(:title=).with(:title)
      source.stub(:description? => true)
      source.stub(description: :description)
      dest.stub(description: nil)
      dest.stub(:description? => false)
      dest.should_receive(:description=).with(:description)
      source.stub(:content? => true)
      source.stub(content: :content)
      dest.stub(content: nil)
      dest.stub(:content? => false)
      dest.should_receive(:content=).with(:content)
      source.stub(:organizer? => true)
      source.stub(organizer: :organizer)
      dest.stub(organizer: nil)
      dest.stub(:organizer? => false)
      dest.should_receive(:organizer=).with(:organizer)
      source.stub(:organizer_url? => true)
      source.stub(organizer_url: :organizer_url)
      dest.stub(organizer_url: nil)
      dest.stub(:organizer_url? => false)
      dest.should_receive(:organizer_url=).with(:organizer_url)
      source.stub(:location? => true)
      source.stub(location: :location)
      dest.stub(location: nil)
      dest.stub(:location? => false)
      dest.should_receive(:location=).with(:location)
      source.stub(:address? => true)
      source.stub(address: :address)
      dest.stub(address: nil)
      dest.stub(:address? => false)
      dest.should_receive(:address=).with(:address)
      source.stub(:city? => true)
      source.stub(city: :city)
      dest.stub(city: nil)
      dest.stub(:city? => false)
      dest.should_receive(:city=).with(:city)
      source.stub(:province? => true)
      source.stub(province: :province)
      dest.stub(province: nil)
      dest.stub(:province? => false)
      dest.should_receive(:province=).with(:province)
      source.stub(:country? => true)
      source.stub(country: :country)
      dest.stub(country: nil)
      dest.stub(:country? => false)
      dest.should_receive(:country=).with(:country)
      source.stub(:location_url? => true)
      source.stub(location_url: :location_url)
      dest.stub(location_url: nil)
      dest.stub(:location_url? => false)
      dest.should_receive(:location_url=).with(:location_url)
      # Do the merger operation
      merger = Merger::EventMerger.new(source)
      merger.merge_fields_into(dest)
    end

    it "should return conflicts where there are differing values in both the source and destination" do
      source = double('source')
      dest = double('destination')
      dest.stub(:save!)
      # ignore flag fields
      dest.stub(is_allday: true)
      dest.stub(is_draft: false)
      dest.stub(is_approved: true)
      dest.stub(is_wheelchair_accessible: true)
      dest.stub(is_adults_only: true)
      dest.stub(is_tentative: false)
      dest.stub(is_cancelled: true)
      dest.stub(is_featured: true)
      # the fields
      source.stub(user: :user)
      dest.stub(user: :dest_user)
      dest.stub(:user= => nil)
      source.stub(:start_at? => true)
      source.stub(start_at: :start_at)
      dest.stub(start_at: :dest_start_at)
      dest.stub(:start_at? => true)
      source.stub(:end_at? => true)
      source.stub(end_at: :end_at)
      dest.stub(end_at: :dest_end_at)
      dest.stub(:end_at? => true)
      source.stub(:timezone? => true)
      source.stub(timezone: :timezone)
      dest.stub(timezone: :dest_timezone)
      dest.stub(:timezone? => true)
      source.stub(:title? => true)
      source.stub(title: :title)
      dest.stub(title: :dest_title)
      dest.stub(:title? => true)
      source.stub(:description? => true)
      source.stub(description: :description)
      dest.stub(description: :dest_description)
      dest.stub(:description? => true)
      source.stub(:content? => true)
      source.stub(content: :content)
      dest.stub(content: :dest_content)
      dest.stub(:content? => true)
      source.stub(:organizer? => true)
      source.stub(organizer: :organizer)
      dest.stub(organizer: :dest_organizer)
      dest.stub(:organizer? => true)
      source.stub(:organizer_url? => true)
      source.stub(organizer_url: :organizer_url)
      dest.stub(organizer_url: :dest_organizer_url)
      dest.stub(:organizer_url? => true)
      source.stub(:location? => true)
      source.stub(location: :location)
      dest.stub(location: :dest_location)
      dest.stub(:location? => true)
      source.stub(:address? => true)
      source.stub(address: :address)
      dest.stub(address: :dest_address)
      dest.stub(:address? => true)
      source.stub(:city? => true)
      source.stub(city: :city)
      dest.stub(city: :dest_city)
      dest.stub(:city? => true)
      source.stub(:province? => true)
      source.stub(province: :province)
      dest.stub(province: :dest_province)
      dest.stub(:province? => true)
      source.stub(:country? => true)
      source.stub(country: :country)
      dest.stub(country: :dest_country)
      dest.stub(:country? => true)
      source.stub(:location_url? => true)
      source.stub(location_url: :location_url)
      dest.stub(location_url: :dest_location_url)
      dest.stub(:location_url? => true)
      # Do the merger operation
      merger = Merger::EventMerger.new(source)
      merger.merge_fields_into(dest).should eq(
        start_at: :start_at, end_at: :end_at, timezone: :timezone,
        title: :title, description: :description, content: :content,
        organizer: :organizer, organizer_url: :organizer_url, location: :location,
        address: :address, city: :city, province: :province,
        country: :country, location_url: :location_url
      )
    end

    it "should do nothing when the source value matches the destination value" do
      source = double('source')
      dest = double('destination')
      dest.stub(:save!)
      # ignore flag fields
      dest.stub(is_allday: true)
      dest.stub(is_draft: false)
      dest.stub(is_approved: true)
      dest.stub(is_wheelchair_accessible: true)
      dest.stub(is_adults_only: true)
      dest.stub(is_tentative: false)
      dest.stub(is_cancelled: true)
      dest.stub(is_featured: true)
      # the fields
      source.stub(user: :user)
      dest.stub(user: :user)
      dest.stub(:user= => nil)
      source.stub(:start_at? => true)
      source.stub(start_at: :start_at)
      dest.stub(start_at: :start_at)
      source.stub(:end_at? => true)
      source.stub(end_at: :end_at)
      dest.stub(end_at: :end_at)
      source.stub(:timezone? => true)
      source.stub(timezone: :timezone)
      dest.stub(timezone: :timezone)
      source.stub(:title? => true)
      source.stub(title: :title)
      dest.stub(title: :title)
      source.stub(:description? => true)
      source.stub(description: :description)
      dest.stub(description: :description)
      source.stub(:content? => true)
      source.stub(content: :content)
      dest.stub(content: :content)
      source.stub(:organizer? => true)
      source.stub(organizer: :organizer)
      dest.stub(organizer: :organizer)
      source.stub(:organizer_url? => true)
      source.stub(organizer_url: :organizer_url)
      dest.stub(organizer_url: :organizer_url)
      source.stub(:location? => true)
      source.stub(location: :location)
      dest.stub(location: :location)
      source.stub(:address? => true)
      source.stub(address: :address)
      dest.stub(address: :address)
      source.stub(:city? => true)
      source.stub(city: :city)
      dest.stub(city: :city)
      source.stub(:province? => true)
      source.stub(province: :province)
      dest.stub(province: :province)
      source.stub(:country? => true)
      source.stub(country: :country)
      dest.stub(country: :country)
      source.stub(:location_url? => true)
      source.stub(location_url: :location_url)
      dest.stub(location_url: :location_url)
      # Do the merger operation
      merger = Merger::EventMerger.new(source)
      merger.merge_fields_into(dest).should eq({})
    end

    it "should leave the flag fields false if both source and destination are false" do
      source = double('source')
      dest = double('destination')
      dest.stub(:save!)
      # other fields - just ignore them
      dest.stub(user: :user)
      source.stub(:start_at? => nil)
      source.stub(:end_at? => nil)
      source.stub(:timezone? => nil)
      source.stub(:title? => nil)
      source.stub(:description? => nil)
      source.stub(:content? => nil)
      source.stub(:organizer? => nil)
      source.stub(:organizer_url? => nil)
      source.stub(:location? => nil)
      source.stub(:address? => nil)
      source.stub(:city? => nil)
      source.stub(:province? => nil)
      source.stub(:country? => nil)
      source.stub(:location_url? => nil)
      # flags
      # or-equals flags
      source.stub(is_allday: nil)
      dest.stub(is_allday: nil)
      dest.should_receive(:is_allday=).with(nil)
      source.stub(is_approved: nil)
      dest.stub(is_approved: nil)
      dest.should_receive(:is_approved=).with(nil)
      source.stub(is_wheelchair_accessible: nil)
      dest.stub(is_wheelchair_accessible: nil)
      dest.should_receive(:is_wheelchair_accessible=).with(nil)
      source.stub(is_adults_only: nil)
      dest.stub(is_adults_only: nil)
      dest.should_receive(:is_adults_only=).with(nil)
      source.stub(is_cancelled: nil)
      dest.stub(is_cancelled: nil)
      dest.should_receive(:is_cancelled=).with(nil)
      source.stub(is_featured: nil)
      dest.stub(is_featured: nil)
      dest.should_receive(:is_featured=).with(nil)
      # and-equals flags
      source.stub(is_draft: nil)
      dest.stub(is_draft: nil)
      dest.should_not_receive(:is_draft=)
      source.stub(is_tentative: nil)
      dest.stub(is_tentative: nil)
      dest.should_not_receive(:is_tentative=)
      # Do the merger operation
      merger = Merger::EventMerger.new(source)
      merger.merge_fields_into(dest)
    end

    it "should set the flag fields when source is true and destination is false" do
      source = double('source')
      dest = double('destination')
      dest.stub(:save!)
      # other fields - just ignore them
      dest.stub(user: :user)
      source.stub(:start_at? => nil)
      source.stub(:end_at? => nil)
      source.stub(:timezone? => nil)
      source.stub(:title? => nil)
      source.stub(:description? => nil)
      source.stub(:content? => nil)
      source.stub(:organizer? => nil)
      source.stub(:organizer_url? => nil)
      source.stub(:location? => nil)
      source.stub(:address? => nil)
      source.stub(:city? => nil)
      source.stub(:province? => nil)
      source.stub(:country? => nil)
      source.stub(:location_url? => nil)
      # flags
      # or-equals flags
      source.stub(is_allday: :is_allday)
      dest.stub(is_allday: nil)
      dest.should_receive(:is_allday=).with(:is_allday)
      source.stub(is_approved: :is_approved)
      dest.stub(is_approved: nil)
      dest.should_receive(:is_approved=).with(:is_approved)
      source.stub(is_wheelchair_accessible: :is_wheelchair_accessible)
      dest.stub(is_wheelchair_accessible: nil)
      dest.should_receive(:is_wheelchair_accessible=).with(:is_wheelchair_accessible)
      source.stub(is_adults_only: :is_adults_only)
      dest.stub(is_adults_only: nil)
      dest.should_receive(:is_adults_only=).with(:is_adults_only)
      source.stub(is_cancelled: :is_cancelled)
      dest.stub(is_cancelled: nil)
      dest.should_receive(:is_cancelled=).with(:is_cancelled)
      source.stub(is_featured: :is_featured)
      dest.stub(is_featured: nil)
      dest.should_receive(:is_featured=).with(:is_featured)
      # and-equals flags
      #source.stub(is_tentative: :is_tentative)
      dest.stub(is_tentative: nil)
      dest.should_not_receive(:is_tentative=) #.with(:is_tentative)
      #source.stub(is_draft: :is_draft)
      dest.stub(is_draft: nil)
      dest.should_not_receive(:is_draft=) #.with(:is_draft)
      # Do the merger operation
      merger = Merger::EventMerger.new(source)
      merger.merge_fields_into(dest)
    end

    it "should set the flag fields true if source is false and destination is true" do
      source = double('source')
      dest = double('destination')
      dest.stub(:save!)
      # other fields - just ignore them
      dest.stub(user: :user)
      source.stub(:start_at? => nil)
      source.stub(:end_at? => nil)
      source.stub(:timezone? => nil)
      source.stub(:title? => nil)
      source.stub(:description? => nil)
      source.stub(:content? => nil)
      source.stub(:organizer? => nil)
      source.stub(:organizer_url? => nil)
      source.stub(:location? => nil)
      source.stub(:address? => nil)
      source.stub(:city? => nil)
      source.stub(:province? => nil)
      source.stub(:country? => nil)
      source.stub(:location_url? => nil)
      # flags
      # or-equals flags
      dest.stub(is_allday: :dest_is_allday)
      dest.should_not_receive(:is_allday=)
      dest.stub(is_approved: :dest_is_approved)
      dest.should_not_receive(:is_approved=)
      dest.stub(is_wheelchair_accessible: :dest_is_wheelchair_accessible)
      dest.should_not_receive(:is_wheelchair_accessible=)
      dest.stub(is_adults_only: :dest_is_adults_only)
      dest.should_not_receive(:is_adults_only=)
      dest.stub(is_cancelled: :dest_is_cancelled)
      dest.should_not_receive(:is_cancelled=)
      dest.stub(is_featured: :dest_is_featured)
      dest.should_not_receive(:is_featured=)
      # and-equals flags
      source.stub(is_draft: nil)
      dest.stub(is_draft: :dest_is_draft)
      dest.should_receive(:is_draft=).with(nil)
      source.stub(is_tentative: nil)
      dest.stub(is_tentative: :dest_is_tentative)
      dest.should_receive(:is_tentative=).with(nil)
      # Do the merger operation
      merger = Merger::EventMerger.new(source)
      merger.merge_fields_into(dest)
    end

    it "should leave the flag fields true if source is true and destination is true" do
      source = double('source')
      dest = double('destination')
      dest.stub(:save!)
      # other fields - just ignore them
      dest.stub(user: :user)
      source.stub(:start_at? => nil)
      source.stub(:end_at? => nil)
      source.stub(:timezone? => nil)
      source.stub(:title? => nil)
      source.stub(:description? => nil)
      source.stub(:content? => nil)
      source.stub(:organizer? => nil)
      source.stub(:organizer_url? => nil)
      source.stub(:location? => nil)
      source.stub(:address? => nil)
      source.stub(:city? => nil)
      source.stub(:province? => nil)
      source.stub(:country? => nil)
      source.stub(:location_url? => nil)
      # flags
      # or-equals flags
      dest.stub(is_allday: :dest_is_allday)
      dest.should_not_receive(:is_allday=)
      dest.stub(is_approved: :dest_is_approved)
      dest.should_not_receive(:is_approved=)
      dest.stub(is_wheelchair_accessible: :dest_is_wheelchair_accessible)
      dest.should_not_receive(:is_wheelchair_accessible=)
      dest.stub(is_adults_only: :dest_is_adults_only)
      dest.should_not_receive(:is_adults_only=)
      dest.stub(is_cancelled: :dest_is_cancelled)
      dest.should_not_receive(:is_cancelled=)
      dest.stub(is_featured: :dest_is_featured)
      dest.should_not_receive(:is_featured=)
      # and-equals flags
      source.stub(is_tentative: :is_tentative)
      dest.stub(is_tentative: :dest_is_tentative)
      dest.should_receive(:is_tentative=).with(:is_tentative)
      source.stub(is_draft: :is_draft)
      dest.stub(is_draft: :dest_is_draft)
      dest.should_receive(:is_draft=).with(:is_draft)
      # Do the merger operation
      merger = Merger::EventMerger.new(source)
      merger.merge_fields_into(dest)
    end

    it "should save the changes to the destination" do
      source = double('source')
      dest = double('destination')
      # ignore the fields
      dest.stub(user: :user)
      source.stub(:start_at? => nil)
      source.stub(:end_at? => nil)
      source.stub(:timezone? => nil)
      source.stub(:title? => nil)
      source.stub(:description? => nil)
      source.stub(:content? => nil)
      source.stub(:organizer? => nil)
      source.stub(:organizer_url? => nil)
      source.stub(:location? => nil)
      source.stub(:address? => nil)
      source.stub(:city? => nil)
      source.stub(:province? => nil)
      source.stub(:country? => nil)
      source.stub(:location_url? => nil)
      # ignore flag fields
      dest.stub(is_allday: true)
      dest.stub(is_draft: false)
      dest.stub(is_approved: true)
      dest.stub(is_wheelchair_accessible: true)
      dest.stub(is_adults_only: true)
      dest.stub(is_tentative: false)
      dest.stub(is_cancelled: true)
      dest.stub(is_featured: true)
      # test - what we expect
      dest.should_receive(:save!)
      # Do the merger operation
      merger = Merger::EventMerger.new(source)
      merger.merge_fields_into(dest)
    end

  end

end
