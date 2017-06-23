require 'spec_helper'
require_relative '../../app/wayground/merger'

describe Merger::Base do
  describe 'initialization' do
    it 'should accept a source' do
      source = double('source')
      expect(Merger::Base.new(source).source).to eq source
    end
  end

  describe '#merge_into!' do
    it 'should call all the merge into methods, delete the source, and return the conflicts' do
      source = double('source')
      expect(source).to receive(:delete)
      dest = double('destination')
      merger = Merger::Base.new(source)
      expect(merger).to receive(:merge_fields_into).with(dest).and_return(:conflicts)
      expect(merger).to receive(:merge_authorities_into).with(dest)
      expect(merger).to receive(:merge_external_links_into).with(dest)
      expect(merger).to receive(:merge_tags_into).with(dest)
      expect(merger).to receive(:merge_sourced_items_into).with(dest)
      expect(merger).to receive(:merge_versions_into).with(dest)
      expect(merger.merge_into!(dest)).to eq :conflicts
    end
  end

  describe '#merge_fields_into' do
    it 'should save the changes to the destination' do
      dest = double('destination')
      expect(dest).to receive(:save!)
      Merger::Base.new(nil).merge_fields_into(dest)
    end
    it 'should return a hash' do
      dest = double('destination')
      allow(dest).to receive(:save!)
      expect(Merger::Base.new(nil).merge_fields_into(dest)).to eq({})
    end
  end

  describe '#merge_authorities_into' do
    it 'should move over any non-duplate authorities' do
      # set up the source
      source = double('source')
      authorities = []
      allow(source).to receive(:authorities).and_return(authorities)
      # set up the destination
      dest = double('destination')
      allow(dest).to receive(:id).and_return(123)
      # what we’re testing for:
      rspec_stubs_lazy
      expect(authorities).to receive(:update_all).with(item_id: 123)
      rspec_stubs_strict
      # Do the merger operation
      merger = Merger::Base.new(source)
      merger.merge_authorities_into(dest)
    end

    it 'should merge the details of any duplicate authorities' do
      # set up the source
      user = double('user')
      allow(user).to receive(:id).and_return(234)
      source = double('source')
      source_authority = double('authority')
      allow(source_authority).to receive(:user).and_return(user)
      authorities = [source_authority]
      rspec_stubs_lazy
      allow(authorities).to receive(:update_all)
      rspec_stubs_strict
      allow(source).to receive(:authorities).and_return(authorities)
      # set up the destination
      dest = double('destination')
      allow(dest).to receive(:id).and_return(0)
      destination_authority = double('destination authority')
      dest_authorities_where = double('authorities where')
      allow(dest_authorities_where).to receive(:first).and_return(destination_authority)
      dest_authorities = double('authorities')
      allow(dest_authorities).to receive(:where).with(user_id: 234).and_return(dest_authorities_where)
      allow(dest).to receive(:authorities).and_return(dest_authorities)
      # What we’re testing for:
      expect(source_authority).to receive(:merge_into!).with(destination_authority)
      # Do the merger operation
      merger = Merger::Base.new(source)
      merger.merge_authorities_into(dest)
    end
  end

  describe '#merge_external_links_into' do
    it 'should move over any non-duplate external links' do
      # set up the source
      source = double('source')
      links = []
      allow(source).to receive(:external_links).and_return(links)
      # set up the destination
      dest = double('destination')
      allow(dest).to receive(:id).and_return(345)
      # what we’re testing for:
      rspec_stubs_lazy
      expect(links).to receive(:update_all).with(item_id: 345)
      rspec_stubs_strict
      # Do the merger operation
      merger = Merger::Base.new(source)
      merger.merge_external_links_into(dest)
    end

    it 'should delete any duplicate external links on the source' do
      # set up the source
      source = double('source')
      source_link = double('link')
      allow(source_link).to receive(:url).and_return('url')
      links = [source_link]
      rspec_stubs_lazy
      allow(links).to receive(:update_all)
      rspec_stubs_strict
      allow(source).to receive(:external_links).and_return(links)
      # set up the destination
      dest = double('destination')
      allow(dest).to receive(:id).and_return(0)
      destination_link = double('destination link')
      dest_links_where = double('links where')
      allow(dest_links_where).to receive(:first).and_return(destination_link)
      dest_links = double('links')
      allow(dest_links).to receive(:where).with(url: 'url').and_return(dest_links_where)
      allow(dest).to receive(:external_links).and_return(dest_links)
      # What we’re testing for:
      expect(source_link).to receive(:delete)
      # Do the merger operation
      merger = Merger::Base.new(source)
      merger.merge_external_links_into(dest)
    end
  end

  describe '#merge_tags_into' do
    it 'should move over any non-duplate tags' do
      # set up the source
      source = double('source')
      tags = []
      allow(source).to receive(:tags).and_return(tags)
      # set up the destination
      dest = double('destination')
      allow(dest).to receive(:id).and_return(345)
      # what we’re testing for:
      rspec_stubs_lazy
      expect(tags).to receive(:update_all).with(item_id: 345)
      rspec_stubs_strict
      # Do the merger operation
      merger = Merger::Base.new(source)
      merger.merge_tags_into(dest)
    end

    it 'should delete any duplicate tags on the source' do
      # set up the source
      source = double('source')
      source_tag = double('tag')
      allow(source_tag).to receive(:tag).and_return('tag')
      tags = [source_tag]
      rspec_stubs_lazy
      allow(tags).to receive(:update_all)
      rspec_stubs_strict
      allow(source).to receive(:tags).and_return(tags)
      # set up the destination
      dest = double('destination')
      allow(dest).to receive(:id).and_return(0)
      destination_tag = double('destination tag')
      dest_tags_where = double('tags where')
      allow(dest_tags_where).to receive(:first).and_return(destination_tag)
      dest_tags = double('tags')
      allow(dest_tags).to receive(:where).with(tag: 'tag').and_return(dest_tags_where)
      allow(dest).to receive(:tags).and_return(dest_tags)
      # What we’re testing for:
      expect(source_tag).to receive(:delete)
      # Do the merger operation
      merger = Merger::Base.new(source)
      merger.merge_tags_into(dest)
    end
  end

  describe '#merge_sourced_items_into' do
    it 'should reassign sourced_items to the other event with local modifications flag set' do
      # set up the source
      source = double('source')
      sourced_items = []
      allow(source).to receive(:sourced_items).and_return(sourced_items)
      # set up the destination
      dest = double('destination')
      allow(dest).to receive(:id).and_return(456)
      # what we’re testing for:
      rspec_stubs_lazy
      expect(sourced_items).to receive(:update_all).with(item_id: 456, has_local_modifications: true)
      rspec_stubs_strict
      # Do the merger operation
      merger = Merger::Base.new(source)
      merger.merge_sourced_items_into(dest)
    end
  end

  describe '#merge_versions_into' do
    it 'should reassign versions to the destination' do
      # set up the source
      source = double('source')
      versions = []
      allow(source).to receive(:versions).and_return(versions)
      # set up the destination
      dest = double('destination')
      allow(dest).to receive(:id).and_return(567)
      # what we’re testing for:
      rspec_stubs_lazy
      expect(versions).to receive(:update_all).with(item_id: 567)
      rspec_stubs_strict
      # Do the merger operation
      merger = Merger::Base.new(source)
      merger.merge_versions_into(dest)
    end
  end
end

describe Merger::EventMerger do
  describe '#merge_fields_into' do
    # TODO: DRY up the EventMerger#merge_fields_into method since it’s a bit unwieldy and repetitious

    it 'should set the field values on the destination when the destination is blank' do
      source = double('source')
      dest = double('destination')
      allow(dest).to receive(:save!)
      # ignore flag fields
      allow(dest).to receive(:is_allday).and_return(true)
      allow(dest).to receive(:is_draft).and_return(false)
      allow(dest).to receive(:is_approved).and_return(true)
      allow(dest).to receive(:is_wheelchair_accessible).and_return(true)
      allow(dest).to receive(:is_adults_only).and_return(true)
      allow(dest).to receive(:is_tentative).and_return(false)
      allow(dest).to receive(:is_cancelled).and_return(true)
      allow(dest).to receive(:is_featured).and_return(true)
      # what we’re testing for:
      allow(source).to receive(:user).and_return(:user)
      allow(dest).to receive(:user).and_return(nil)
      expect(dest).to receive(:user=).with(:user)
      allow(source).to receive(:start_at?).and_return(true)
      allow(source).to receive(:start_at).and_return(:start_at)
      allow(dest).to receive(:start_at).and_return(nil)
      allow(dest).to receive(:start_at?).and_return(false)
      expect(dest).to receive(:start_at=).with(:start_at)
      allow(source).to receive(:end_at?).and_return(true)
      allow(source).to receive(:end_at).and_return(:end_at)
      allow(dest).to receive(:end_at).and_return(nil)
      allow(dest).to receive(:end_at?).and_return(false)
      expect(dest).to receive(:end_at=).with(:end_at)
      allow(source).to receive(:timezone?).and_return(true)
      allow(source).to receive(:timezone).and_return(:timezone)
      allow(dest).to receive(:timezone).and_return(nil)
      allow(dest).to receive(:timezone?).and_return(false)
      expect(dest).to receive(:timezone=).with(:timezone)
      allow(source).to receive(:title?).and_return(true)
      allow(source).to receive(:title).and_return(:title)
      allow(dest).to receive(:title).and_return(nil)
      allow(dest).to receive(:title?).and_return(false)
      expect(dest).to receive(:title=).with(:title)
      allow(source).to receive(:description?).and_return(true)
      allow(source).to receive(:description).and_return(:description)
      allow(dest).to receive(:description).and_return(nil)
      allow(dest).to receive(:description?).and_return(false)
      expect(dest).to receive(:description=).with(:description)
      allow(source).to receive(:content?).and_return(true)
      allow(source).to receive(:content).and_return(:content)
      allow(dest).to receive(:content).and_return(nil)
      allow(dest).to receive(:content?).and_return(false)
      expect(dest).to receive(:content=).with(:content)
      allow(source).to receive(:organizer?).and_return(true)
      allow(source).to receive(:organizer).and_return(:organizer)
      allow(dest).to receive(:organizer).and_return(nil)
      allow(dest).to receive(:organizer?).and_return(false)
      expect(dest).to receive(:organizer=).with(:organizer)
      allow(source).to receive(:organizer_url?).and_return(true)
      allow(source).to receive(:organizer_url).and_return(:organizer_url)
      allow(dest).to receive(:organizer_url).and_return(nil)
      allow(dest).to receive(:organizer_url?).and_return(false)
      expect(dest).to receive(:organizer_url=).with(:organizer_url)
      allow(source).to receive(:location?).and_return(true)
      allow(source).to receive(:location).and_return(:location)
      allow(dest).to receive(:location).and_return(nil)
      allow(dest).to receive(:location?).and_return(false)
      expect(dest).to receive(:location=).with(:location)
      allow(source).to receive(:address?).and_return(true)
      allow(source).to receive(:address).and_return(:address)
      allow(dest).to receive(:address).and_return(nil)
      allow(dest).to receive(:address?).and_return(false)
      expect(dest).to receive(:address=).with(:address)
      allow(source).to receive(:city?).and_return(true)
      allow(source).to receive(:city).and_return(:city)
      allow(dest).to receive(:city).and_return(nil)
      allow(dest).to receive(:city?).and_return(false)
      expect(dest).to receive(:city=).with(:city)
      allow(source).to receive(:province?).and_return(true)
      allow(source).to receive(:province).and_return(:province)
      allow(dest).to receive(:province).and_return(nil)
      allow(dest).to receive(:province?).and_return(false)
      expect(dest).to receive(:province=).with(:province)
      allow(source).to receive(:country?).and_return(true)
      allow(source).to receive(:country).and_return(:country)
      allow(dest).to receive(:country).and_return(nil)
      allow(dest).to receive(:country?).and_return(false)
      expect(dest).to receive(:country=).with(:country)
      allow(source).to receive(:location_url?).and_return(true)
      allow(source).to receive(:location_url).and_return(:location_url)
      allow(dest).to receive(:location_url).and_return(nil)
      allow(dest).to receive(:location_url?).and_return(false)
      expect(dest).to receive(:location_url=).with(:location_url)
      # Do the merger operation
      merger = Merger::EventMerger.new(source)
      merger.merge_fields_into(dest)
    end

    it 'should return conflicts where there are differing values in both the source and destination' do
      source = double('source')
      dest = double('destination')
      allow(dest).to receive(:save!)
      # ignore flag fields
      allow(dest).to receive(:is_allday).and_return(true)
      allow(dest).to receive(:is_draft).and_return(false)
      allow(dest).to receive(:is_approved).and_return(true)
      allow(dest).to receive(:is_wheelchair_accessible).and_return(true)
      allow(dest).to receive(:is_adults_only).and_return(true)
      allow(dest).to receive(:is_tentative).and_return(false)
      allow(dest).to receive(:is_cancelled).and_return(true)
      allow(dest).to receive(:is_featured).and_return(true)
      # the fields
      allow(source).to receive(:user).and_return(:user)
      allow(dest).to receive(:user).and_return(:dest_user)
      allow(dest).to receive(:user=).and_return(nil)
      allow(source).to receive(:start_at?).and_return(true)
      allow(source).to receive(:start_at).and_return(:start_at)
      allow(dest).to receive(:start_at).and_return(:dest_start_at)
      allow(dest).to receive(:start_at?).and_return(true)
      allow(source).to receive(:end_at?).and_return(true)
      allow(source).to receive(:end_at).and_return(:end_at)
      allow(dest).to receive(:end_at).and_return(:dest_end_at)
      allow(dest).to receive(:end_at?).and_return(true)
      allow(source).to receive(:timezone?).and_return(true)
      allow(source).to receive(:timezone).and_return(:timezone)
      allow(dest).to receive(:timezone).and_return(:dest_timezone)
      allow(dest).to receive(:timezone?).and_return(true)
      allow(source).to receive(:title?).and_return(true)
      allow(source).to receive(:title).and_return(:title)
      allow(dest).to receive(:title).and_return(:dest_title)
      allow(dest).to receive(:title?).and_return(true)
      allow(source).to receive(:description?).and_return(true)
      allow(source).to receive(:description).and_return(:description)
      allow(dest).to receive(:description).and_return(:dest_description)
      allow(dest).to receive(:description?).and_return(true)
      allow(source).to receive(:content?).and_return(true)
      allow(source).to receive(:content).and_return(:content)
      allow(dest).to receive(:content).and_return(:dest_content)
      allow(dest).to receive(:content?).and_return(true)
      allow(source).to receive(:organizer?).and_return(true)
      allow(source).to receive(:organizer).and_return(:organizer)
      allow(dest).to receive(:organizer).and_return(:dest_organizer)
      allow(dest).to receive(:organizer?).and_return(true)
      allow(source).to receive(:organizer_url?).and_return(true)
      allow(source).to receive(:organizer_url).and_return(:organizer_url)
      allow(dest).to receive(:organizer_url).and_return(:dest_organizer_url)
      allow(dest).to receive(:organizer_url?).and_return(true)
      allow(source).to receive(:location?).and_return(true)
      allow(source).to receive(:location).and_return(:location)
      allow(dest).to receive(:location).and_return(:dest_location)
      allow(dest).to receive(:location?).and_return(true)
      allow(source).to receive(:address?).and_return(true)
      allow(source).to receive(:address).and_return(:address)
      allow(dest).to receive(:address).and_return(:dest_address)
      allow(dest).to receive(:address?).and_return(true)
      allow(source).to receive(:city?).and_return(true)
      allow(source).to receive(:city).and_return(:city)
      allow(dest).to receive(:city).and_return(:dest_city)
      allow(dest).to receive(:city?).and_return(true)
      allow(source).to receive(:province?).and_return(true)
      allow(source).to receive(:province).and_return(:province)
      allow(dest).to receive(:province).and_return(:dest_province)
      allow(dest).to receive(:province?).and_return(true)
      allow(source).to receive(:country?).and_return(true)
      allow(source).to receive(:country).and_return(:country)
      allow(dest).to receive(:country).and_return(:dest_country)
      allow(dest).to receive(:country?).and_return(true)
      allow(source).to receive(:location_url?).and_return(true)
      allow(source).to receive(:location_url).and_return(:location_url)
      allow(dest).to receive(:location_url).and_return(:dest_location_url)
      allow(dest).to receive(:location_url?).and_return(true)
      # Do the merger operation
      merger = Merger::EventMerger.new(source)
      expect(merger.merge_fields_into(dest)).to eq(
        start_at: :start_at, end_at: :end_at, timezone: :timezone,
        title: :title, description: :description, content: :content,
        organizer: :organizer, organizer_url: :organizer_url, location: :location,
        address: :address, city: :city, province: :province,
        country: :country, location_url: :location_url
      )
    end

    it 'should do nothing when the source value matches the destination value' do
      source = double('source')
      dest = double('destination')
      allow(dest).to receive(:save!)
      # ignore flag fields
      allow(dest).to receive(:is_allday).and_return(true)
      allow(dest).to receive(:is_draft).and_return(false)
      allow(dest).to receive(:is_approved).and_return(true)
      allow(dest).to receive(:is_wheelchair_accessible).and_return(true)
      allow(dest).to receive(:is_adults_only).and_return(true)
      allow(dest).to receive(:is_tentative).and_return(false)
      allow(dest).to receive(:is_cancelled).and_return(true)
      allow(dest).to receive(:is_featured).and_return(true)
      # the fields
      allow(source).to receive(:user).and_return(:user)
      allow(dest).to receive(:user).and_return(:user)
      allow(dest).to receive(:user=).and_return(nil)
      allow(source).to receive(:start_at?).and_return(true)
      allow(source).to receive(:start_at).and_return(:start_at)
      allow(dest).to receive(:start_at).and_return(:start_at)
      allow(source).to receive(:end_at?).and_return(true)
      allow(source).to receive(:end_at).and_return(:end_at)
      allow(dest).to receive(:end_at).and_return(:end_at)
      allow(source).to receive(:timezone?).and_return(true)
      allow(source).to receive(:timezone).and_return(:timezone)
      allow(dest).to receive(:timezone).and_return(:timezone)
      allow(source).to receive(:title?).and_return(true)
      allow(source).to receive(:title).and_return(:title)
      allow(dest).to receive(:title).and_return(:title)
      allow(source).to receive(:description?).and_return(true)
      allow(source).to receive(:description).and_return(:description)
      allow(dest).to receive(:description).and_return(:description)
      allow(source).to receive(:content?).and_return(true)
      allow(source).to receive(:content).and_return(:content)
      allow(dest).to receive(:content).and_return(:content)
      allow(source).to receive(:organizer?).and_return(true)
      allow(source).to receive(:organizer).and_return(:organizer)
      allow(dest).to receive(:organizer).and_return(:organizer)
      allow(source).to receive(:organizer_url?).and_return(true)
      allow(source).to receive(:organizer_url).and_return(:organizer_url)
      allow(dest).to receive(:organizer_url).and_return(:organizer_url)
      allow(source).to receive(:location?).and_return(true)
      allow(source).to receive(:location).and_return(:location)
      allow(dest).to receive(:location).and_return(:location)
      allow(source).to receive(:address?).and_return(true)
      allow(source).to receive(:address).and_return(:address)
      allow(dest).to receive(:address).and_return(:address)
      allow(source).to receive(:city?).and_return(true)
      allow(source).to receive(:city).and_return(:city)
      allow(dest).to receive(:city).and_return(:city)
      allow(source).to receive(:province?).and_return(true)
      allow(source).to receive(:province).and_return(:province)
      allow(dest).to receive(:province).and_return(:province)
      allow(source).to receive(:country?).and_return(true)
      allow(source).to receive(:country).and_return(:country)
      allow(dest).to receive(:country).and_return(:country)
      allow(source).to receive(:location_url?).and_return(true)
      allow(source).to receive(:location_url).and_return(:location_url)
      allow(dest).to receive(:location_url).and_return(:location_url)
      # Do the merger operation
      merger = Merger::EventMerger.new(source)
      expect(merger.merge_fields_into(dest)).to eq({})
    end

    it 'should leave the flag fields false if both source and destination are false' do
      source = double('source')
      dest = double('destination')
      allow(dest).to receive(:save!)
      # other fields - just ignore them
      allow(dest).to receive(:user).and_return(:user)
      allow(source).to receive(:start_at?).and_return(nil)
      allow(source).to receive(:end_at?).and_return(nil)
      allow(source).to receive(:timezone?).and_return(nil)
      allow(source).to receive(:title?).and_return(nil)
      allow(source).to receive(:description?).and_return(nil)
      allow(source).to receive(:content?).and_return(nil)
      allow(source).to receive(:organizer?).and_return(nil)
      allow(source).to receive(:organizer_url?).and_return(nil)
      allow(source).to receive(:location?).and_return(nil)
      allow(source).to receive(:address?).and_return(nil)
      allow(source).to receive(:city?).and_return(nil)
      allow(source).to receive(:province?).and_return(nil)
      allow(source).to receive(:country?).and_return(nil)
      allow(source).to receive(:location_url?).and_return(nil)
      # flags
      # or-equals flags
      allow(source).to receive(:is_allday).and_return(nil)
      allow(dest).to receive(:is_allday).and_return(nil)
      expect(dest).to receive(:is_allday=).and_return(nil)
      allow(source).to receive(:is_approved).and_return(nil)
      allow(dest).to receive(:is_approved).and_return(nil)
      expect(dest).to receive(:is_approved=).and_return(nil)
      allow(source).to receive(:is_wheelchair_accessible).and_return(nil)
      allow(dest).to receive(:is_wheelchair_accessible).and_return(nil)
      expect(dest).to receive(:is_wheelchair_accessible=).and_return(nil)
      allow(source).to receive(:is_adults_only).and_return(nil)
      allow(dest).to receive(:is_adults_only).and_return(nil)
      expect(dest).to receive(:is_adults_only=).and_return(nil)
      allow(source).to receive(:is_cancelled).and_return(nil)
      allow(dest).to receive(:is_cancelled).and_return(nil)
      expect(dest).to receive(:is_cancelled=).and_return(nil)
      allow(source).to receive(:is_featured).and_return(nil)
      allow(dest).to receive(:is_featured).and_return(nil)
      expect(dest).to receive(:is_featured=).and_return(nil)
      # and-equals flags
      allow(source).to receive(:is_draft).and_return(nil)
      allow(dest).to receive(:is_draft).and_return(nil)
      expect(dest).not_to receive(:is_draft=)
      allow(source).to receive(:is_tentative).and_return(nil)
      allow(dest).to receive(:is_tentative).and_return(nil)
      expect(dest).not_to receive(:is_tentative=)
      # Do the merger operation
      merger = Merger::EventMerger.new(source)
      merger.merge_fields_into(dest)
    end

    it 'should set the flag fields when source is true and destination is false' do
      source = double('source')
      dest = double('destination')
      allow(dest).to receive(:save!)
      # other fields - just ignore them
      allow(dest).to receive(:user).and_return(:user)
      allow(source).to receive(:start_at?).and_return(nil)
      allow(source).to receive(:end_at?).and_return(nil)
      allow(source).to receive(:timezone?).and_return(nil)
      allow(source).to receive(:title?).and_return(nil)
      allow(source).to receive(:description?).and_return(nil)
      allow(source).to receive(:content?).and_return(nil)
      allow(source).to receive(:organizer?).and_return(nil)
      allow(source).to receive(:organizer_url?).and_return(nil)
      allow(source).to receive(:location?).and_return(nil)
      allow(source).to receive(:address?).and_return(nil)
      allow(source).to receive(:city?).and_return(nil)
      allow(source).to receive(:province?).and_return(nil)
      allow(source).to receive(:country?).and_return(nil)
      allow(source).to receive(:location_url?).and_return(nil)
      # flags
      # or-equals flags
      allow(source).to receive(:is_allday).and_return(:is_allday)
      allow(dest).to receive(:is_allday)
      expect(dest).to receive(:is_allday=).with(:is_allday)
      allow(source).to receive(:is_approved).and_return(:is_approved)
      allow(dest).to receive(:is_approved).and_return(nil)
      expect(dest).to receive(:is_approved=).with(:is_approved)
      allow(source).to receive(:is_wheelchair_accessible).and_return(:is_wheelchair_accessible)
      allow(dest).to receive(:is_wheelchair_accessible).and_return(nil)
      expect(dest).to receive(:is_wheelchair_accessible=).with(:is_wheelchair_accessible)
      allow(source).to receive(:is_adults_only).and_return(:is_adults_only)
      allow(dest).to receive(:is_adults_only).and_return(nil)
      expect(dest).to receive(:is_adults_only=).with(:is_adults_only)
      allow(source).to receive(:is_cancelled).and_return(:is_cancelled)
      allow(dest).to receive(:is_cancelled).and_return(nil)
      expect(dest).to receive(:is_cancelled=).with(:is_cancelled)
      allow(source).to receive(:is_featured).and_return(:is_featured)
      allow(dest).to receive(:is_featured).and_return(nil)
      expect(dest).to receive(:is_featured=).with(:is_featured)
      # and-equals flags
      # allow(source).to receive(:is_tentative).and_return(:is_tentative)
      allow(dest).to receive(:is_tentative).and_return(nil)
      expect(dest).not_to receive(:is_tentative=) # .with(:is_tentative)
      # allow(source).to receive(:is_draft).and_return(:is_draft)
      allow(dest).to receive(:is_draft).and_return(nil)
      expect(dest).not_to receive(:is_draft=) # .with(:is_draft)
      # Do the merger operation
      merger = Merger::EventMerger.new(source)
      merger.merge_fields_into(dest)
    end

    it 'should set the flag fields true if source is false and destination is true' do
      source = double('source')
      dest = double('destination')
      allow(dest).to receive(:save!)
      # other fields - just ignore them
      allow(dest).to receive(:user).and_return(:user)
      allow(source).to receive(:start_at?).and_return(nil)
      allow(source).to receive(:end_at?).and_return(nil)
      allow(source).to receive(:timezone?).and_return(nil)
      allow(source).to receive(:title?).and_return(nil)
      allow(source).to receive(:description?).and_return(nil)
      allow(source).to receive(:content?).and_return(nil)
      allow(source).to receive(:organizer?).and_return(nil)
      allow(source).to receive(:organizer_url?).and_return(nil)
      allow(source).to receive(:location?).and_return(nil)
      allow(source).to receive(:address?).and_return(nil)
      allow(source).to receive(:city?).and_return(nil)
      allow(source).to receive(:province?).and_return(nil)
      allow(source).to receive(:country?).and_return(nil)
      allow(source).to receive(:location_url?).and_return(nil)
      # flags
      # or-equals flags
      allow(dest).to receive(:is_allday).and_return(:dest_is_allday)
      expect(dest).not_to receive(:is_allday=)
      allow(dest).to receive(:is_approved).and_return(:dest_is_approved)
      expect(dest).not_to receive(:is_approved=)
      allow(dest).to receive(:is_wheelchair_accessible).and_return(:dest_is_wheelchair_accessible)
      expect(dest).not_to receive(:is_wheelchair_accessible=)
      allow(dest).to receive(:is_adults_only).and_return(:dest_is_adults_only)
      expect(dest).not_to receive(:is_adults_only=)
      allow(dest).to receive(:is_cancelled).and_return(:dest_is_cancelled)
      expect(dest).not_to receive(:is_cancelled=)
      allow(dest).to receive(:is_featured).and_return(:dest_is_featured)
      expect(dest).not_to receive(:is_featured=)
      # and-equals flags
      allow(source).to receive(:is_draft).and_return(nil)
      allow(dest).to receive(:is_draft).and_return(:dest_is_draft)
      expect(dest).to receive(:is_draft=).with(nil)
      allow(source).to receive(:is_tentative).and_return(nil)
      allow(dest).to receive(:is_tentative).and_return(:dest_is_tentative)
      expect(dest).to receive(:is_tentative=).with(nil)
      # Do the merger operation
      merger = Merger::EventMerger.new(source)
      merger.merge_fields_into(dest)
    end

    it 'should leave the flag fields true if source is true and destination is true' do
      source = double('source')
      dest = double('destination')
      allow(dest).to receive(:save!)
      # other fields - just ignore them
      allow(dest).to receive(:user).and_return(:user)
      allow(source).to receive(:start_at?).and_return(nil)
      allow(source).to receive(:end_at?).and_return(nil)
      allow(source).to receive(:timezone?).and_return(nil)
      allow(source).to receive(:title?).and_return(nil)
      allow(source).to receive(:description?).and_return(nil)
      allow(source).to receive(:content?).and_return(nil)
      allow(source).to receive(:organizer?).and_return(nil)
      allow(source).to receive(:organizer_url?).and_return(nil)
      allow(source).to receive(:location?).and_return(nil)
      allow(source).to receive(:address?).and_return(nil)
      allow(source).to receive(:city?).and_return(nil)
      allow(source).to receive(:province?).and_return(nil)
      allow(source).to receive(:country?).and_return(nil)
      allow(source).to receive(:location_url?).and_return(nil)
      # flags
      # or-equals flags
      allow(dest).to receive(:is_allday).and_return(:dest_is_allday)
      expect(dest).not_to receive(:is_allday=)
      allow(dest).to receive(:is_approved).and_return(:dest_is_approved)
      expect(dest).not_to receive(:is_approved=)
      allow(dest).to receive(:is_wheelchair_accessible).and_return(:dest_is_wheelchair_accessible)
      expect(dest).not_to receive(:is_wheelchair_accessible=)
      allow(dest).to receive(:is_adults_only).and_return(:dest_is_adults_only)
      expect(dest).not_to receive(:is_adults_only=)
      allow(dest).to receive(:is_cancelled).and_return(:dest_is_cancelled)
      expect(dest).not_to receive(:is_cancelled=)
      allow(dest).to receive(:is_featured).and_return(:dest_is_featured)
      expect(dest).not_to receive(:is_featured=)
      # and-equals flags
      allow(source).to receive(:is_tentative).and_return(:is_tentative)
      allow(dest).to receive(:is_tentative).and_return(:dest_is_tentative)
      expect(dest).to receive(:is_tentative=).with(:is_tentative)
      allow(source).to receive(:is_draft).and_return(:is_draft)
      allow(dest).to receive(:is_draft).and_return(:dest_is_draft)
      expect(dest).to receive(:is_draft=).with(:is_draft)
      # Do the merger operation
      merger = Merger::EventMerger.new(source)
      merger.merge_fields_into(dest)
    end

    it 'should save the changes to the destination' do
      source = double('source')
      dest = double('destination')
      # ignore the fields
      allow(dest).to receive(:user).and_return(:user)
      allow(source).to receive(:start_at?).and_return(nil)
      allow(source).to receive(:end_at?).and_return(nil)
      allow(source).to receive(:timezone?).and_return(nil)
      allow(source).to receive(:title?).and_return(nil)
      allow(source).to receive(:description?).and_return(nil)
      allow(source).to receive(:content?).and_return(nil)
      allow(source).to receive(:organizer?).and_return(nil)
      allow(source).to receive(:organizer_url?).and_return(nil)
      allow(source).to receive(:location?).and_return(nil)
      allow(source).to receive(:address?).and_return(nil)
      allow(source).to receive(:city?).and_return(nil)
      allow(source).to receive(:province?).and_return(nil)
      allow(source).to receive(:country?).and_return(nil)
      allow(source).to receive(:location_url?).and_return(nil)
      # ignore flag fields
      allow(dest).to receive(:is_allday).and_return(true)
      allow(dest).to receive(:is_draft).and_return(false)
      allow(dest).to receive(:is_approved).and_return(true)
      allow(dest).to receive(:is_wheelchair_accessible).and_return(true)
      allow(dest).to receive(:is_adults_only).and_return(true)
      allow(dest).to receive(:is_tentative).and_return(false)
      allow(dest).to receive(:is_cancelled).and_return(true)
      allow(dest).to receive(:is_featured).and_return(true)
      # test - what we expect
      expect(dest).to receive(:save!)
      # Do the merger operation
      merger = Merger::EventMerger.new(source)
      merger.merge_fields_into(dest)
    end
  end
end
