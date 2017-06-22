require 'spec_helper'
require 'event/year'
require 'event'

describe Wayground::Event::Year do
  describe 'initialization' do
    it 'should accept a year parameter' do
      year = Wayground::Event::Year.new(year: 2000)
      expect(year.year).to eq 2000
    end
  end

  describe 'monthly_event_counts' do
    it 'should return a hash with the event counts for each month' do
      allow(Event).to receive_message_chain(:falls_between_dates, :count) { 3 }
      expect(Wayground::Event::Year.new(year: 2001).monthly_event_counts).to eq(
        1 => 3, 2 => 3, 3 => 3, 4 => 3, 5 => 3, 6 => 3, 7 => 3, 8 => 3, 9 => 3, 10 => 3, 11 => 3, 12 => 3
      )
    end
  end
end
