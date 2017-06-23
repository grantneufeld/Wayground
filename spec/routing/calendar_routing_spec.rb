require 'rails_helper'

describe CalendarController, type: :routing do
  describe 'routing' do
    it 'handles the index path' do
      expect(get: '/calendar').to route_to(
        controller: 'calendar', action: 'index'
      )
    end
    it 'handles the subscription path' do
      expect(get: '/calendar/subscribe').to route_to(
        controller: 'calendar', action: 'subscribe'
      )
    end
    it 'handles paths to a given calendar year' do
      expect(get: '/calendar/1999').to route_to(
        controller: 'calendar', action: 'year', year: '1999'
      )
    end
    it 'handles paths to a given calendar month' do
      expect(get: '/calendar/2001/02').to route_to(
        controller: 'calendar', action: 'month', year: '2001', month: '02'
      )
    end
    it 'handles paths to a given calendar day' do
      expect(get: '/calendar/2123/11/30').to route_to(
        controller: 'calendar', action: 'day', year: '2123', month: '11', day: '30'
      )
    end
  end
end
