require 'spec_helper'
require 'time_presenter'

describe TimePresenter do
  describe 'initialization' do
    it 'should take a time parameter' do
      time = Time.zone.now
      presenter = TimePresenter.new(time)
      expect(presenter.time).to eq time
    end
  end

  describe '#brief' do
    context 'when at zero minutes past the hour' do
      it 'should present 12:00am as ‘midnight’' do
        time = Time.zone.parse('12am')
        presenter = TimePresenter.new(time)
        expect(presenter.brief).to eq 'midnight'
      end
      it 'should present 12:00pm as ‘noon’' do
        time = Time.zone.parse('12pm')
        presenter = TimePresenter.new(time)
        expect(presenter.brief).to eq 'noon'
      end
      it 'should not show the minutes' do
        time = Time.zone.parse('1:00 AM')
        presenter = TimePresenter.new(time)
        expect(presenter.brief).to eq '1am'
      end
    end
    context 'when not at zero minutes past the hour' do
      it 'should show the hour and the minutes' do
        time = Time.zone.parse('4:56 PM')
        presenter = TimePresenter.new(time)
        expect(presenter.brief).to eq '4:56pm'
      end
    end
  end

  describe '#brief_just_the_hour' do
    context 'when at zero minutes past the hour' do
      it 'should present 12am as ‘midnight’' do
        time = Time.zone.parse('12:01am')
        presenter = TimePresenter.new(time)
        expect(presenter.brief_just_the_hour).to eq 'midnight'
      end
      it 'should present 12pm as ‘noon’' do
        time = Time.zone.parse('12:02pm')
        presenter = TimePresenter.new(time)
        expect(presenter.brief_just_the_hour).to eq 'noon'
      end
      it 'should not show the minutes' do
        time = Time.zone.parse('1:03 AM')
        presenter = TimePresenter.new(time)
        expect(presenter.brief_just_the_hour).to eq '1am'
      end
    end
  end

  describe '#microformat_start' do
    let(:time) { $time = Time.zone.parse('2000-01-02 1:00 AM MST') }
    let(:presenter) { $presenter = TimePresenter.new(time) }
    it 'should show the time' do
      expect(presenter.microformat_start).to match(/>1:00am</)
    end
    it 'should set the html class to dtstart' do
      expect(presenter.microformat_start).to match(/<time [^>]*class="dtstart"/)
    end
    it 'should include the datetime' do
      expect(presenter.microformat_start).to match ' datetime="2000-01-02T01:00:00-07:00"'
    end
    it 'should accept a time format for the time' do
      expect(presenter.microformat_start(:plain_datetime)).to match(/>Sunday, January +2, 2000 at +1:00am</)
    end
  end

  describe '#microformat_end' do
    let(:time) { $time = Time.zone.parse('2000-01-02 1:00 AM MST') }
    let(:presenter) { $presenter = TimePresenter.new(time) }
    it 'should show the time' do
      expect(presenter.microformat_end).to match '>1:00am<'
    end
    it 'should set the html class to dtend' do
      expect(presenter.microformat_end).to match ' class="dtend"'
    end
    it 'should include the datetime' do
      expect(presenter.microformat_end).to match ' datetime="2000-01-02T01:00:00-07:00"'
    end
    it 'should accept a time format for the time' do
      expect(presenter.microformat_end(:plain_datetime)).to match(/>Sunday, January +2, 2000 at +1:00am</)
    end
  end

  describe '#microformat_hidden_start' do
    let(:time) { $time = Time.zone.parse('2000-01-02 1:00 AM MST') }
    let(:presenter) { $presenter = TimePresenter.new(time) }
    it 'should return a unary element' do
      expect(presenter.microformat_hidden_start).to match(%r{\A<time [^>]* />\z})
    end
    it 'should set the html class to dtstart' do
      expect(presenter.microformat_hidden_start).to match ' class="dtstart" '
    end
    it 'should include the datetime' do
      expect(presenter.microformat_hidden_start).to match ' datetime="2000-01-02T01:00:00-07:00" '
    end
  end

  describe '#microformat_hidden_end' do
    let(:time) { $time = Time.zone.parse('2000-01-02 1:00 AM MST') }
    let(:presenter) { $presenter = TimePresenter.new(time) }
    it 'should return a unary element' do
      expect(presenter.microformat_hidden_end).to match(%r{\A<time [^>]* />\z})
    end
    it 'should set the html class to dtend' do
      expect(presenter.microformat_hidden_end).to match ' class="dtend" '
    end
    it 'should include the datetime' do
      expect(presenter.microformat_hidden_end).to match ' datetime="2000-01-02T01:00:00-07:00" '
    end
  end

  describe '#microformat' do
    let(:time) { $time = Time.zone.parse('2000-01-02 1:00 AM MST') }
    let(:presenter) { $presenter = TimePresenter.new(time) }
    context 'with no block' do
      it 'should produce a unary time element' do
        expect(presenter.microformat).to match(%r{\A<time [^>]+ />\z})
      end
      it 'should correctly format the date' do
        expect(presenter.microformat).to match ' datetime="2000-01-02T01:00:00-07:00"'
      end
      it 'should accept an html_class' do
        expect(presenter.microformat(html_class: 'dtend')).to match ' class="dtend"'
      end
      it 'should return an html_safe string' do
        expect(presenter.microformat.html_safe).to be_truthy
      end
    end
    context 'with a content block' do
      it 'should embed the content in the element' do
        result =
          presenter.microformat do
            'content'
          end
        expect(result).to eq '<time class="dtstart" datetime="2000-01-02T01:00:00-07:00">content</time>'
      end
    end
  end
end
