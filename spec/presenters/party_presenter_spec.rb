require 'rails_helper'
require 'party_presenter'
require_relative 'view_double'

describe PartyPresenter do
  let(:view) { $view = ViewDouble.new }
  let(:level) { $level = Level.new(name: 'Test Level', filename: 'test_level') }
  let(:party_attrs) do
    $party_attrs = {
      name: 'Test Party', filename: 'test_party', abbrev: 'TP', colour: 'aqua',
      established_on: '2001-02-03'.to_date, registered_on: '2002-03-04'.to_date,
      is_registered: true
    }
  end
  let(:party_extra_attrs) { $party_extra_attrs = {} }
  let(:party) do
    $party = level.parties.build(party_attrs.merge(party_extra_attrs))
    $party.level = level
    $party
  end
  let(:user) { $user = nil }
  let(:presenter) { $presenter = PartyPresenter.new(view: view, party: party, user: user) }

  describe 'initialization' do
    it 'should take a view parameter' do
      expect( PartyPresenter.new(view: :view).view ).to eq :view
    end
    it 'should take an party parameter' do
      expect( PartyPresenter.new(party: :party).party ).to eq :party
    end
    it 'should take a user parameter' do
      expect( PartyPresenter.new(user: :user).user ).to eq :user
    end
  end

  describe '#present_as_list_item' do
    it 'should wrap the result in a “li” element' do
      result = presenter.present_as_list_item
      expect( result ).to match /\A<li[^>]*>/
      expect( result ).to match /<\/li>\z/
    end
    it 'should be html safe' do
      expect( presenter.present_as_list_item.html_safe? ).to be_truthy
    end
    context 'with an ended_on date' do
      let(:party_extra_attrs) { $party_extra_attrs = {ended_on: '2009-08-07'.to_date} }
      it 'should include the ended on date with a line break element' do
        expect( presenter.present_as_list_item ).to match /[\r\n]<br \/>August 7, 2009/
      end
    end
  end

  describe '#present_heading' do
    it 'should wrap the result in an h1 element' do
      result = presenter.present_heading
      expect( result ).to match /\A<h1[^>]*>/
      expect( result ).to match /<\/h1>[\r\n]*\z/
    end
    it 'should include “party-label” in the class of the h1 element' do
      expect( presenter.present_heading ).to match(
        /<h1 (?:|[^>]* )class="(?:|[^"]* )party-label(?:| [^"]*)"/
      )
    end
    it 'should set the border-color to the colour for the h1 element' do
      expect( presenter.present_heading ).to match(
        /<h1 (?:|[^>]* )style="border-color:aqua"/
      )
    end
    it 'should include the linked party name' do
      expect( presenter.present_heading ).to match(
        /<a href="\/levels\/test_level\/parties\/test_party">Test Party<\/a>/
      )
    end
    it 'should include the abbreviation' do
      expect( presenter.present_heading ).to match 'TP'
    end
    context 'with true passed as parameter' do
      it 'should not link the party name' do
        result = presenter.present_heading(true)
        expect(result).not_to match(
          /<a href="\/levels\/test_level\/parties\/test_party">Test Party<\/a>/
        )
        expect(result).to match(/Test Party/)
      end
    end
    context 'with a registered party' do
      let(:party_extra_attrs) { $party_extra_attrs = {is_registered: true} }
      it 'should not include “party-unregistered” in the class of the h1 element' do
        expect( presenter.present_heading.match(
          /<h1 (?:|[^>] )class="(?:|[^"]* )party-unregistered(?:| [^"]*)"/
        )).to be_falsey
      end
    end
    context 'with an unregistered party' do
      let(:party_extra_attrs) { $party_extra_attrs = {is_registered: false} }
      it 'should not include “party-unregistered” in the class of the h1 element' do
        expect( presenter.present_heading ).to match(
          /<h1 (?:|[^>] )class="(?:|[^"]* )party-unregistered(?:| [^"]*)"/
        )
      end
    end
    it 'should be html safe' do
      expect( presenter.present_heading.html_safe? ).to be_truthy
    end
  end

  describe '#present_dates' do
    context 'with no dates' do
      let(:party_extra_attrs) do
        $party_extra_attrs = {established_on: nil, registered_on: nil, ended_on: nil}
      end
      it 'should return nil' do
        expect( presenter.present_dates ).to be_nil
      end
    end
    context 'with just one date' do
      let(:party_extra_attrs) do
        $party_extra_attrs = {established_on: '2003-04-05'.to_date, registered_on: nil, ended_on: nil}
      end
      it 'should wrap the result in an h1 element' do
        result = presenter.present_dates
        expect( result ).to match /\A<p>/
        expect( result ).to match /<\/p>[\r\n]*\z/
      end
      it 'should return the plain date' do
        expect( presenter.present_dates ).to match /Established on April 5, 2003\./
      end
      it 'should be html safe' do
        expect( presenter.present_dates.html_safe? ).to be_truthy
      end
    end
    context 'with all 3 dates' do
      let(:party_extra_attrs) do
        $party_extra_attrs = {
          established_on: '2004-05-06'.to_date, registered_on: '2005-06-07'.to_date,
          ended_on: '2006-07-08'.to_date
        }
      end
      it 'should wrap the result in an h1 element' do
        result = presenter.present_dates
        expect( result ).to match /\A<p>/
        expect( result ).to match /<\/p>[\r\n]*\z/
      end
      it 'should return the plain dates, separated by line break elements' do
        expect( presenter.present_dates ).to match(
          /Established on May 6, 2004\.\n<br \/>Registered on June 7, 2005\.\n<br \/>Ended on July 8, 2006\./
        )
      end
      it 'should be html safe' do
        expect( presenter.present_dates.html_safe? ).to be_truthy
      end
      context 'with a custom separator' do
        it 'should return the plain dates, separated by the custom separator' do
          expect( presenter.present_dates(':') ).to match(
            /Established on May 6, 2004\.:Registered on June 7, 2005\.:Ended on July 8, 2006\./
          )
        end
        it 'should be html safe' do
          expect( presenter.present_dates.html_safe? ).to be_truthy
        end
      end
    end
  end

end
